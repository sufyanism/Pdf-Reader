import 'package:get/get.dart';
import '../views/home_page.dart';
import '../views/reader_page.dart';
import '../views/bookmarks_page.dart';
import '../views/splash_page.dart';

class Routes {
  static const splash = '/';
  static const home = '/home';
  static const reader = '/reader';
  static const bookmarks = '/bookmarks';
}

class AppRoutes {
  static final pages = [
    GetPage(name: Routes.splash, page: () => const SplashPage()),
    GetPage(name: Routes.home, page: () => HomePage()),
    GetPage(name: Routes.reader, page: () => const ReaderPage()),
    GetPage(name: Routes.bookmarks, page: () => BookmarksPage()),
  ];
}