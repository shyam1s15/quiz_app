import 'package:get/get.dart';
import 'bindings/app_bindings.dart';
import 'views/splash/splash_page.dart';
import 'views/category/category_page.dart';
import 'views/quiz/quiz_page.dart';
import 'views/result/result_page.dart';

abstract class Routes {
  static const splash = '/';
  static const category = '/category';
  static const quiz = '/quiz';
  static const result = '/result';

  static final pages = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: category,
      page: () => const CategoryPage(),
    ),
    GetPage(
      name: quiz,
      page: () => const QuizPage(),
      binding: QuizBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: result,
      page: () => const ResultPage(),
      binding: ResultBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}
