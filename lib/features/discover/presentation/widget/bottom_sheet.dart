import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:malla_stock_mgt/config/router/app_route.dart';
import 'package:malla_stock_mgt/features/discover/data/repository/product_repository.dart';
import 'package:malla_stock_mgt/widgets/buttons.dart';

class SureDelete extends StatelessWidget {
  final String name;
  final String image;
  const SureDelete({super.key, required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_forever_rounded,
              size: 48,
              color: Colors.black,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Button(
                    label: "No",
                    fillColor: Colors.green,
                    textColor: Colors.white,
                    width: 154,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.deleteProduct(name, image, context, false);
                    Navigator.pushNamed(context, AppRoute.homeRoute);
                  },
                  child: const Button(
                    label: "Yes",
                    textColor: Colors.white,
                    fillColor: Colors.red,
                    width: 154,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
