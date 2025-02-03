import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malla_stock_mgt/config/constants/config.dart';
import 'package:malla_stock_mgt/core/common/snackbar/my_snackbar.dart';
import 'package:malla_stock_mgt/features/discover/data/model/product_model.dart';
import 'package:malla_stock_mgt/features/discover/data/repository/product_repository.dart';
import 'package:malla_stock_mgt/widgets/buttons.dart';
import 'package:permission_handler/permission_handler.dart';

class AddProductView extends ConsumerStatefulWidget {
  const AddProductView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddProductViewState();
}

class _AddProductViewState extends ConsumerState<AddProductView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _netCostPriceController = TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();
  final TextEditingController _sellerContactController =
      TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productTypeController.text = "";
    _sellerContactController.text = "";
    _salePriceController.text = "";
  }

  final ProductController controller = Get.find<ProductController>();

  bool _isLoading = false;

  List<String> _filteredCompanies = [];
  List<String> _filteredProducts = [];
  bool _showCompanySuggestions = false;
  bool _showProductSuggestions = false;

  void _filterCompanies(String input) {
    setState(() {
      if (input.isEmpty) {
        _showCompanySuggestions = false;
        _filteredCompanies = [];
      } else {
        _showCompanySuggestions = true;
        _filteredCompanies = Config.getCompanies()
            .where((company) =>
                company.toLowerCase().contains(input.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterProducts(String input) {
    setState(() {
      if (input.isEmpty) {
        _showProductSuggestions = false;
        _filteredProducts = [];
      } else {
        _showProductSuggestions = true;
        _filteredProducts = Config.getProducts()
            .where((product) =>
                product.toLowerCase().contains(input.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> checkCameraPermission() async {
    if (await Permission.camera.request().isGranted) {
      // Permission granted
    } else {
      // Permission denied
      print("Camera permission denied");
    }
  }

  File? _image;

  Future<void> _pickImage(WidgetRef ref, ImageSource imageSource) async {
    await checkCameraPermission();

    try {
      final pickedFile = await ImagePicker().pickImage(source: imageSource);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } catch (e) {
      print("Error picking image $e");
    }
  }

  Future<String> _uploadImage(File image) async {
    return await 'snapshot.ref.getDownloadURL()';
  }

  void _clearForm() {
    // _formKey.currentState?.reset();
    // _productNameController.clear();
    _quantityController.clear();
    _netCostPriceController.clear();
    // _productTypeController.clear();
    // _sellerContactController.clear();
    // _companyController.clear();
    _salePriceController.clear();
    setState(() {
      _image = null;
    });
  }

  final List<String> _categories = [
    'Room 1','Room 2', 'Room 3', 'Room 4', 'Room 5', 'Room 6'
  ];
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: Color(0xFF0F0F0F),
            fontSize: 24,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildImageUploadField(),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildFormColumn(),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildFormColumn0(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  _isLoading = true;
                                });
                                double tcp = double.parse(
                                        _quantityController.text) *
                                    double.parse(_netCostPriceController.text);

                                final newProduct = ProductModel(
                                  productName:
                                      _productNameController.text.trim(),
                                  quantity: _quantityController.text.trim(),
                                  netCP: _netCostPriceController.text.trim(),
                                  productType:
                                      _productTypeController.text.trim(),
                                  sellerContact:
                                      _sellerContactController.text.trim(),
                                  room: _selectedCategory!,
                                  company: _companyController.text.trim(),
                                  saleCP: _salePriceController.text.trim(),
                                  totalCP: tcp.toString(),
                                  date: "2025/01/02",
                                  productImage: _image != null
                                      ? await _uploadImage(_image!)
                                      : "",
                                );
                                try {
                                  await addItem(newProduct);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            child: const Button(
                              label: "ADD PRODUCT",
                              textColor: Colors.white,
                              width: double.infinity,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildFormColumn(),
                          const SizedBox(height: 20),
                          _buildFormColumn0(),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  _isLoading = true;
                                });
                                double tcp = double.parse(
                                        _quantityController.text.trim()) *
                                    double.parse(
                                        _netCostPriceController.text.trim());
                                final newProduct = ProductModel(
                                  productName:
                                      _productNameController.text.trim(),
                                  quantity: _quantityController.text.trim(),
                                  netCP: _netCostPriceController.text.trim(),
                                  productType:
                                      _productTypeController.text.trim(),
                                  sellerContact:
                                      _sellerContactController.text.trim(),
                                  company: _companyController.text.trim(),
                                  saleCP: _salePriceController.text.trim(),
                                  room: _selectedCategory!,
                                  totalCP: tcp.toString(),
                                  date: "2025/01/02",
                                  productImage: _image != null
                                      ? await _uploadImage(_image!)
                                      : "",
                                );
                                try {
                                  await addItem(newProduct);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            child: const Button(
                              label: "ADD PRODUCT",
                              textColor: Colors.white,
                              width: double.infinity,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _productNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            label: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Product Name',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  TextSpan(
                    text: ' *',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Fields marked with * is required.';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            label: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Quantity',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  TextSpan(
                    text: ' *',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Fields marked with * is required.';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _netCostPriceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            label: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Net Cost Price',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  TextSpan(
                    text: ' *',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Fields marked with * is required.';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _productTypeController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Product Type',
            labelStyle: const TextStyle(color: Colors.grey),
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          onChanged: (value) => _filterProducts(value),
        ),
        Visibility(
          visible: _showProductSuggestions,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_filteredProducts[index]),
                onTap: () {
                  setState(() {
                    _productTypeController.text = _filteredProducts[index];
                    _showProductSuggestions = false;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormColumn0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _salePriceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            label: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'MRP',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  TextSpan(
                    text: ' *',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Fields marked with * is required.';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _sellerContactController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Seller Contact',
            labelStyle: const TextStyle(color: Colors.grey),
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _companyController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Company',
            labelStyle: const TextStyle(color: Colors.grey),
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          onChanged: (value) => _filterCompanies(value),
        ),
        Visibility(
          visible: _showCompanySuggestions,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredCompanies.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_filteredCompanies[index]),
                onTap: () {
                  setState(() {
                    _companyController.text = _filteredCompanies[index];
                    _showCompanySuggestions = false;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          hint: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Store Room',
                  style: const TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: ' *',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Fields marked with * is required.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImageUploadField() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera),
                    title: const Text('Take a photo'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ref, ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ref, ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: _image == null
            ? Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.add_a_photo, color: Colors.grey, size: 50),
              )
            : Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> addItem(ProductModel product) async {
    final existingProducts = false;
    // Product does not exist, add it directly
    try {
      showSnackBar(
        message: 'Product added successfully',
        context: context,
        color: Colors.green,
      );
      _clearForm();
    } catch (e) {
      showSnackBar(
        message: 'Error adding product',
        context: context,
        color: Colors.red,
      );
    }
  }
}
