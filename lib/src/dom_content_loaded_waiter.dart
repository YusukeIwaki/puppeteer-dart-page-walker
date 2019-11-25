import 'package:puppeteer/protocol/network.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:puppeteer_page_walker/src/first_event_listener.dart';

// Utility class for waiting "domcontentloaded" event.
// if page is already dom content loaded, .waitForDomContentLoaded() returns soon.
class DomContentLoadedWaiter {
  final Page page;
  DomContentLoadedWaiter(this.page);

  Future<bool> get isDomContentLoaded async {
    try {
      final String readyState =
          await page.evaluate("() => document.readyState");
      return readyState == "interactive" || readyState == "complete";
    } catch (err) {
      if (err.toString() ==
          "Execution context was destroyed, most likely because of a navigation.") {
        return false;
      }
      rethrow;
    }
  }

  Future<void> waitForDomContentLoaded() async {
    final firstDomContentLoaded = FirstEventListener<MonotonicTime>();
    final subscription = page.onDomContentLoaded.listen((monotonicTime) {
      firstDomContentLoaded.update(monotonicTime);
    });
    if (!(await isDomContentLoaded)) {
      await firstDomContentLoaded.firstEvent;
    }
    await subscription.cancel();
  }
}
