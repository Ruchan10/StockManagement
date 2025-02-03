import 'package:malla_stock_mgt/features/discover/presentation/view/home_page.dart';
import 'package:malla_stock_mgt/features/filter/presentation/view/add_product.dart';

class AppRoute {
  AppRoute._();

  static const String homeRoute = '/home';
  static const String addRoute = '/addProduct';

  static getAppRoutes() {
    return {
      homeRoute: (context) => const HomePageView(),
      addRoute: (context) => const AddProductView(),
    };
  }
}
