[![Pub](https://img.shields.io/pub/v/puppeteer_page_walker)](https://pub.dev/packages/puppeteer_page_walker)

# puppeteer-page-walker

A wrapper library of [puppeteer](https://pub.dev/packages/puppeteer) for humane scraping :)
Let's write the scraping scenario separately for each browsing URL.

## Install

Just add dependency into pubspec.yaml,

```yml
dependencies:
  puppeteer_page_walker: ^0.1.0
```

or specify the github url for using the latest functions.

```yml
dependencies:
  puppeteer_page_walker:
    git:
      url: git://github.com/YusukeIwaki/puppeteer-dart-page-walker.git
```

## Enjoy!


```dart
import 'dart:io';

import 'package:puppeteer/puppeteer.dart';
import 'package:puppeteer_page_walker/puppeteer_page_walker.dart';

main(List<String> args) async {
  final browser = await puppeteer.launch();

  await PageWalker(browser).initWith((page) async {
    // browse github.com.
    await page.setViewport(DeviceViewport(width: 1200, height: 480));
    await page.goto("https://github.com/");
  }).forEachPage((page) async {
    // debug print page url for each access.
    print("[${DateTime.now()}] ${page.url}");
  }).andIfUrlIs("https://github.com/", (page) async {
    // search "puppeteer" in github.com.
    final form = await page.$("form.js-site-search-form");
    final searchInput = await form.$("input.header-search-input");
    await searchInput.type("puppeteer");
    await searchInput.press(Key.enter);
  }).andIf((url) => url.startsWith("https://github.com/search"), (page) async {
    // extract repo title from search results.
    final repoList = await page.$("ul.repo-list");
    final repoItems = await repoList.$$("h3");
    await Future.forEach(repoItems, (item) async {
      final String title = await item.$eval("a", "a => a.innerText");
      print("==> $title");
    });

    // goodbye!
    await browser.close();
  }).startWalking();
}
```
