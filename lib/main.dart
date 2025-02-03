import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:malla_stock_mgt/core/app.dart';
import 'package:malla_stock_mgt/features/discover/data/repository/product_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FilePicker.platform;

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
  Get.put(ProductController());
}
