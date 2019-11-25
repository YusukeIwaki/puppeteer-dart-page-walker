import 'package:puppeteer_page_walker/src/type_aliases.dart';

class InternalPageHandler {
  final UrlPredicate urlPredicate;
  final PageHandler pageHandler;
  InternalPageHandler(this.urlPredicate, this.pageHandler);
}
