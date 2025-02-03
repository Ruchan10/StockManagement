import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:malla_stock_mgt/config/router/app_route.dart';


class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory Management',
      initialRoute: AppRoute.homeRoute,
      routes: AppRoute.getAppRoutes(),
    );
  }
}
