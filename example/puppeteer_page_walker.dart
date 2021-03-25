import 'dart:io';

import 'package:puppeteer/puppeteer.dart';
import 'package:puppeteer_page_walker/puppeteer_page_walker.dart';

Future<void> main(List<String> args) async {
  final browser = await puppeteer.launch(
    executablePath: Platform.environment['PUPPETEER_EXECUTABLE_PATH'],
    headless: false,
  );

  await PageWalker(browser).initWith((page) async {
    // browse github.com.
    await page.setViewport(DeviceViewport(width: 1200, height: 480));
    await page.goto('https://github.com/');
  }).forEachPage((page) async {
    // debug print page url for each access.
    print('[${DateTime.now()}] ${page.url}');
  }).andIfUrlIs('https://github.com/', (page) async {
    // search "puppeteer" in github.com.
    final form = await page.$('form.js-site-search-form');
    final searchInput = await form.$('input.header-search-input');
    await searchInput.type('puppeteer');
    await searchInput.press(Key.enter);
  }).andIf((url) => url.startsWith('https://github.com/search'), (page) async {
    // extract repo title from search results.
    final repoList = await page.$('ul.repo-list');
    final repoItems = await repoList.$$('div.f4');
    await Future.forEach(repoItems, (ElementHandle item) async {
      final String title = await item.$eval('a', 'a => a.innerText');
      print('==> $title');
    });

    // goodbye!
    await browser.close();
  }).startWalking();
}
