import 'dart:async';

import 'package:puppeteer/puppeteer.dart';
import 'package:puppeteer_page_walker/src/dom_content_loaded_waiter.dart';

import './internal_page_handler.dart';
import './last_event_listener.dart';
import './type_aliases.dart';
import './throttled_value.dart';

class PageWalker {
  final Browser _puppeteerBrowser;
  late PageHandler _initialPageHandler;
  final _handlers = <InternalPageHandler>[];
  final _lastUrl = ThrottledValue<String>();
  late LastEventListener<Target> _lastTargetListener;

  PageWalker(Browser browser) : _puppeteerBrowser = browser;

  PageWalker initWith(PageHandler pageHandler) {
    _initialPageHandler = pageHandler;
    return this;
  }

  PageWalker forEachPage(PageHandler pageHandler) {
    return andIf((pageUrl) => true, pageHandler);
  }

  PageWalker andIfUrlIs(String url, PageHandler pageHandler) {
    return andIf((pageUrl) => pageUrl == url, pageHandler);
  }

  PageWalker andIf(UrlPredicate urlFilter, PageHandler pageHandler) {
    _handlers.add(InternalPageHandler(urlFilter, pageHandler));
    return this;
  }

  Future<void> startWalking() async {
    _lastTargetListener = LastEventListener<Target>();
    final targetChangeSubscriptions = <StreamSubscription>[];
    targetChangeSubscriptions.add(
        _puppeteerBrowser.onTargetCreated.listen(_lastTargetListener.update));
    targetChangeSubscriptions.add(
        _puppeteerBrowser.onTargetChanged.listen(_lastTargetListener.update));

    final pages = await _puppeteerBrowser.pages;
    final page =
        pages.isEmpty ? (await _puppeteerBrowser.newPage()) : pages.first;

    _lastTargetListener.reset();
    await _initialPageHandler(page);
    while (_puppeteerBrowser.isConnected) {
      final lastTarget = await _lastTargetListener.lastEvent;
      _lastTargetListener.reset();
      await _handleTargetAsync(lastTarget);
    }
    await Future.wait(targetChangeSubscriptions.map((s) => s.cancel()));
  }

  Future<void> _handleTargetAsync(Target target) async {
    final page = await target.page;
    final url = target.url;
    await _handlePageAsync(url, page);
  }

  Future<void> _handlePageAsync(String url, Page page) async {
    if (!_lastUrl.update(url)) {
      return;
    }

    final handlersForUrl = _handlers.where((h) => h.urlPredicate(url));
    if (handlersForUrl.isEmpty) return;

    await DomContentLoadedWaiter(page).waitForDomContentLoaded();
    await Future.forEach(
        handlersForUrl, (InternalPageHandler h) => h.pageHandler(page));
  }
}
