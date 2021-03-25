import 'package:puppeteer/puppeteer.dart';

// Used as predicate in PageWalker#andIf.
//
// examples:
//   (url) => url == "https://www.google.com/"
//   (url) => url.endsWith(".png")
typedef UrlPredicate = bool Function(String url);

// Represents the operation for specific url.
//
// example:
//    (page) async {
//      await page.type("#username", "admin");
//      await page.type("#password", "hogehoge");
//      await page.click("input[type='submit']");
//    }
typedef PageHandler = Future<void> Function(Page page);
