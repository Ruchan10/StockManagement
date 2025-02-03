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

class EditProductView extends ConsumerStatefulWidget {
  final ProductModel product;
  const EditProductView({super.key, required this.product});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProductViewState();
}

class _EditProductViewState extends ConsumerState<EditProductView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _netCostPriceController = TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();
  final TextEditingController _sellerContactController =
      TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final ProductController controller = Get.find<ProductController>();

  String? _selectedCategory;
  List<String> _filteredCompanies = [];
  List<String> _filteredProducts = [];
  bool _showCompanySuggestions = false;
  bool _showProductSuggestions = false;

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.product.productName;
    _quantityController.text = widget.product.quantity;
    _netCostPriceController.text = widget.product.netCP;
    _productTypeController.text = widget.product.productType;
    _sellerContactController.text = widget.product.sellerContact;
    _companyController.text = widget.product.company;
    _salePriceController.text = widget.product.saleCP;
    _selectedCategory = widget.product.room;
  }

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
    _formKey.currentState?.reset();
    _productNameController.clear();
    _quantityController.clear();
    _netCostPriceController.clear();
    _productTypeController.clear();
    _sellerContactController.clear();
    _companyController.clear();
    _salePriceController.clear();
    setState(() {
      _image = null;
    });
  }

  final List<String> _categories = [
    'Room 1',
    'Room 2',
    'Room 3',
    'Room 4',
    'Room 5',
    'Room 6'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Product',
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
                                  totalCP: tcp.toString(),
                                  date: "2025/01/02",
                                  productImage: _image == null
                                      ? widget.product.productImage
                                      : await _uploadImage(_image!),
                                  room: _selectedCategory!,
                                );
                                try {
                                  controller.deleteProduct(
                                      widget.product.productName,
                                      widget.product.productImage,
                                      context,
                                      true);
                                  await addItem(newProduct, context);
                                } catch (e) {
                                  showSnackBar(
                                    context: context,
                                    message: 'Error editing product',
                                    color: Colors.red,
                                  );
                                }
                                _clearForm();
                              }
                            },
                            child: const Button(
                              label: "Edit",
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
                          _buildFormColumn0(),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState?.validate() ?? false) {
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
                                  totalCP: tcp.toString(),
                                  date: "2025/01/02",
                                  productImage: _image == null
                                      ? widget.product.productImage
                                      : await _uploadImage(_image!),
                                  room: _selectedCategory!,
                                );
                                try {
                                  controller.deleteProduct(
                                      widget.product.productName,
                                      widget.product.productImage,
                                      context,
                                      true);
                                  await addItem(newProduct, context);
                                } catch (e) {}
                              }
                            },
                            child: const Button(
                              label: "EDIT PRODUCT",
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
            border: InputBorder.none,
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
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          keyboardType: TextInputType.number,
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
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter seller contact';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _salePriceController,
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
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          keyboardType: TextInputType.number,
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

  Widget _buildFormColumn0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _quantityController,
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
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          keyboardType: TextInputType.number,
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
            border: InputBorder.none,
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
        const SizedBox(height: 10),
        TextFormField(
          controller: _companyController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Company',
            labelStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
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
                    title: const Text('Camera'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ref, ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
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
        child: _image != null
            ? Container(
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
              )
            : widget.product.productImage != ''
                ? Container(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      widget.product.productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset("assets/images/empty.webp");
                      },
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_a_photo,
                        color: Colors.grey, size: 50),
                  ),
      ),
    );
  }

  Future<void> addItem(ProductModel product, BuildContext context) async {
    try {
      // await _db.collection("products").add(product.toJson()).then((_) {
      //   showSnackBar(
      //     message: 'Product edited successfully!',
      //     context: context,
      //     color: Colors.green,
      //   );
      //   Navigator.pushNamed(context, AppRoute.homeRoute);
      // }).catchError((error) {
      //   showSnackBar(
      //     message: 'Failed to edit product: $error',
      //     context: context,
      //     color: Colors.red,
      //   );
      // });
    } catch (e) {
      showSnackBar(message: 'Error: $e', context: context, color: Colors.red);
    }
  }
}
