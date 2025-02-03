import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:malla_stock_mgt/core/common/snackbar/my_snackbar.dart';
import 'package:malla_stock_mgt/features/discover/data/model/product_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final RxList<ProductModel> _products = <ProductModel>[].obs; // Reactive list

  Stream<List<ProductModel>> getProductsStream() {
    // Returning the reactive list as a stream
    return _products.stream;
  }

  Future<List<ProductModel>> allProducts() async {
    // Demo data to initialize the list
    List<ProductModel> demoProducts = [
      ProductModel(
        productName: "Himstar LED Bulb",
        productImage: "https://example.com/images/led_bulb.png",
        company: "Himstar",
        date: "2025-01-22",
        quantity: "100",
        netCP: "50",
        saleCP: "70",
        sellerContact: "9876543210",
        totalCP: "5000",
        room: "Living Room",
        productType: "LED Bulb",
      ),
      ProductModel(
        productName: "Himstar Tube Light",
        productImage: "https://example.com/images/tube_light.png",
        company: "Himstar",
        date: "2025-01-20",
        quantity: "50",
        netCP: "200",
        saleCP: "250",
        sellerContact: "9876543211",
        totalCP: "10000",
        room: "Bedroom",
        productType: "Tube Light",
      ),
      ProductModel(
        productName: "Himstar Ceiling Fan",
        productImage: "https://example.com/images/ceiling_fan.png",
        company: "Himstar",
        date: "2025-01-15",
        quantity: "30",
        netCP: "1500",
        saleCP: "1800",
        sellerContact: "9876543212",
        totalCP: "45000",
        room: "Hall",
        productType: "Fan",
      ),
    ];

    // Update the reactive list
    _products.assignAll(demoProducts);

    return demoProducts;
  }

  Future<void> addItem(ProductModel product, BuildContext context) async {
    try {

      // Add product to the local list
      _products.add(product);

      showSnackBar(
        message: 'Item Added Successfully',
        context: context,
        color: Colors.green,
      );
    } catch (e) {
      showSnackBar(
        message: 'Error adding item',
        context: context,
        color: Colors.red,
      );
    }
  }

  Future<List<String>> getDistinctProductTypes() async {
    List<ProductModel> products = _products;
    return products.map((p) => p.productType).toSet().toList();
  }

  Future<List<String>> getDistinctCompanies() async {
    List<ProductModel> products = _products;
    return products.map((p) => p.company).toSet().toList();
  }

  Future<void> deleteProduct(
      String productName, String imageUrl, BuildContext context, bool isEdit) async {
    try {

        // Remove product from local list
        _products.removeWhere((product) => product.productName == productName);

        try {
          print("Image deleted successfully: $imageUrl");
        } catch (e) {
          print("Failed to delete image: $imageUrl, error: $e");
        }

        if (!isEdit) {
          showSnackBar(
            message: 'Product Deleted Successfully',
            context: context,
            color: Colors.red,
          );
        }

    } catch (e) {
      print("Error deleting product: $e");
      showSnackBar(
        message: 'Error deleting product',
        context: context,
        color: Colors.green,
      );
    }
  }
}
