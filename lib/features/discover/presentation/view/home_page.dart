import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:malla_stock_mgt/config/constants/config.dart';
import 'package:malla_stock_mgt/config/router/app_route.dart';
import 'package:malla_stock_mgt/features/discover/data/model/product_model.dart';
import 'package:malla_stock_mgt/features/discover/data/repository/product_repository.dart';
import 'package:malla_stock_mgt/features/discover/presentation/widget/bottom_sheet.dart';
import 'package:malla_stock_mgt/features/filter/presentation/view/edit_page.dart';
import 'package:malla_stock_mgt/widgets/buttons.dart';
import 'package:malla_stock_mgt/widgets/searchFilter.dart';

class HomePageView extends ConsumerStatefulWidget {
  const HomePageView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageViewState();
}

String selectedCategory = 'Recents';

class _HomePageViewState extends ConsumerState<HomePageView> {
  bool isAscending = false;
  String searchTerm = '';
  String? selectedProductType = "All Product";
  String? selectedCompany = "All Company";
  String? selectedRoom = "All Room";
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<Map<String, List<String>>> loadData() async {
    final ProductController controller = Get.find<ProductController>();
    // final productTypes = await controller.getDistinctProductTypes();
    // final companies = await controller.getDistinctCompanies();

    // productTypes.sort((a, b) => a.compareTo(b));
    // companies.sort((a, b) => a.compareTo(b));

    // productTypes.insert(0, 'All Product');
    // companies.insert(0, 'All Company');

    final List<String> productTypes = [
      "All Product",
      'Product 1',
      'Product 2',
      'Product 3',
      'Product 4',
    ];
    final List<String> companies = [
      "All Product",
      'Company 1',
      'Company 2',
      'Company 3',
      'Company 4',
    ];

    return {
      'productTypes': productTypes,
      'companies': companies,
    };
  }

  final List<String> rooms = [
    "All Room",
    'Room 1',
    'Room 2',
    'Room 3',
    'Room 4',
  ];

  double calculateTotalMRP(List<ProductModel> products) {
    double totalMRP = 0.0;
    for (ProductModel product in products) {
      try {
        double productMRP = double.parse(product.saleCP);
        double productQuantity = double.parse(product.quantity);
        totalMRP += productMRP * productQuantity;
      } catch (e) {
        print(
            'Error parsing saleCP or quantity for product: ${product.productName}, saleCP: ${product.saleCP}, quantity: ${product.quantity}. Error: $e');
      }
    }
    return totalMRP;
  }

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: GestureDetector(
            onTap: () {
              setState(() {
                selectedProductType = "All Product";
                selectedCompany = "All Company";
                selectedRoom = "All Room";
                selectedCategory = 'Recents';
                isAscending = false;
              });
            },
            child: Text(
              'Discover',
              style: TextStyle(
                color: Color(0xFF0F0F0F),
                fontSize: screenWidth > 600 ? 30 : 28,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.30,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                height: 40,
                width: screenWidth > 600 ? 250 : 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  focusNode: _focusNode,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchTerm = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, List<String>>>(
            future: loadData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final productTypes = snapshot.data!['productTypes']!;
              final companies = snapshot.data!['companies']!;
              Config.setCompanies(companies);
              Config.setProducts(productTypes);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SearchableFilterDropdown(
                            label: 'All Product',
                            selectedValue: selectedProductType,
                            options: productTypes,
                            onSelected: (value) {
                              setState(() {
                                selectedProductType = value;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          SearchableFilterDropdown(
                            label: 'All Company',
                            selectedValue: selectedCompany,
                            options: companies,
                            onSelected: (value) {
                              setState(() {
                                selectedCompany = value;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          // Room Filter
                          SearchableFilterDropdown(
                            label: 'All Room',
                            selectedValue: selectedRoom,
                            options: rooms,
                            onSelected: (value) {
                              setState(() {
                                selectedRoom = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  CategorySelector(
                    selectedCategory: selectedCategory,
                    isAscending: isAscending,
                    onCategorySelected: (category) {
                      setState(() {
                        if (selectedCategory == category) {
                          isAscending = !isAscending;
                        } else {
                          isAscending = true;
                        }
                        selectedCategory = category;
                      });
                    },
                  ),
                  Expanded(
                    child: StreamBuilder<List<ProductModel>>(
                      stream: controller.getProductsStream(),
                      builder: (context, snapshot) {
                        List<ProductModel> products = [
                          ProductModel(
                            productName: "Himstar LED Bulb",
                            productImage: "0",
                            company: "Himstar",
                            date: "2025/01/02",
                            quantity: "100",
                            netCP: "Rs. 50",
                            saleCP: "Rs. 70",
                            sellerContact: "9876543210",
                            totalCP: "Rs. 5000",
                            room: "Living Room",
                            productType: "LED Bulb",
                          ),
                          ProductModel(
                            productName: "Himstar Tube Light",
                            productImage: "1",
                            company: "Himstar",
                            date: "2025/01/02",
                            quantity: "50",
                            netCP: "Rs. 200",
                            saleCP: "Rs. 250",
                            sellerContact: "9876543211",
                            totalCP: "Rs. 10000",
                            room: "Bedroom",
                            productType: "Tube Light",
                          ),
                          ProductModel(
                            productName: "Himstar Ceiling Fan",
                            productImage: "2",
                            company: "Himstar",
                            date: "2025/01/02",
                            quantity: "30",
                            netCP: "Rs. 1500",
                            saleCP: "Rs. 1800",
                            sellerContact: "9876543212",
                            totalCP: "Rs. 45000",
                            room: "Hall",
                            productType: "Fan",
                          ),

                          // Electronics
                          ProductModel(
                            productName: "Samsung Galaxy S21",
                            productImage: "3",
                            company: "Samsung",
                            date: "2025-01-10",
                            quantity: "25",
                            netCP: "700",
                            saleCP: "850",
                            sellerContact: "9876543210",
                            totalCP: "17500",
                            room: "Warehouse 1",
                            productType: "Smartphone",
                          ),
                          ProductModel(
                            productName: "Dell Inspiron Laptop",
                            productImage: "4",
                            company: "Dell",
                            date: "2025-01-12",
                            quantity: "10",
                            netCP: "800",
                            saleCP: "1000",
                            sellerContact: "9876543211",
                            totalCP: "8000",
                            room: "Warehouse 2",
                            productType: "Laptop",
                          ),
                          ProductModel(
                            productName: "Sony 4K Television",
                            productImage: "5",
                            company: "Sony",
                            date: "2025-01-05",
                            quantity: "15",
                            netCP: "1200",
                            saleCP: "1500",
                            sellerContact: "9876543212",
                            totalCP: "18000",
                            room: "Showroom",
                            productType: "Television",
                          ),

                          // Furniture
                          ProductModel(
                            productName: "Wooden Office Chair",
                            productImage: "6",
                            company: "Furniture Co.",
                            date: "2025-01-18",
                            quantity: "30",
                            netCP: "60",
                            saleCP: "80",
                            sellerContact: "9876543213",
                            totalCP: "1800",
                            room: "Warehouse 3",
                            productType: "Furniture",
                          ),
                          ProductModel(
                            productName: "Modern Coffee Table",
                            productImage: "7",
                            company: "HomeDecor",
                            date: "2025-01-15",
                            quantity: "20",
                            netCP: "100",
                            saleCP: "150",
                            sellerContact: "9876543214",
                            totalCP: "2000",
                            room: "Warehouse 4",
                            productType: "Furniture",
                          ),

                          // Appliances
                          ProductModel(
                            productName: "LG Washing Machine",
                            productImage: "8",
                            company: "LG",
                            date: "2025-01-08",
                            quantity: "5",
                            netCP: "500",
                            saleCP: "700",
                            sellerContact: "9876543215",
                            totalCP: "2500",
                            room: "Warehouse 1",
                            productType: "Appliance",
                          ),
                          ProductModel(
                            productName: "Whirlpool Refrigerator",
                            productImage: "9",
                            company: "Whirlpool",
                            date: "2025-01-09",
                            quantity: "8",
                            netCP: "800",
                            saleCP: "1000",
                            sellerContact: "9876543216",
                            totalCP: "6400",
                            room: "Showroom",
                            productType: "Appliance",
                          ),

                          // Tools
                          ProductModel(
                            productName: "Bosch Power Drill",
                            productImage: "10",
                            company: "Bosch",
                            date: "2025-02-03",
                            quantity: "20",
                            netCP: "150",
                            saleCP: "200",
                            sellerContact: "9876543217",
                            totalCP: "3000",
                            room: "Tool Room",
                            productType: "Tool",
                          ),
                          ProductModel(
                            productName: "Stanley Hammer",
                            productImage: "11",
                            company: "Stanley",
                            date: "2025-01-14",
                            quantity: "50",
                            netCP: "15",
                            saleCP: "25",
                            sellerContact: "9876543218",
                            totalCP: "750",
                            room: "Tool Room",
                            productType: "Tool",
                          ),

                          // Miscellaneous
                          ProductModel(
                            productName: "Canon EOS Camera",
                            productImage: "12",
                            company: "Canon",
                            date: "2025-01-20",
                            quantity: "10",
                            netCP: "1200",
                            saleCP: "1500",
                            sellerContact: "9876543219",
                            totalCP: "12000",
                            room: "Showroom",
                            productType: "Camera",
                          ),
                          ProductModel(
                            productName: "Apple AirPods",
                            productImage: "13",
                            company: "Apple",
                            date: "2025-01-19",
                            quantity: "40",
                            netCP: "150",
                            saleCP: "200",
                            sellerContact: "9876543220",
                            totalCP: "6000",
                            room: "Warehouse 5",
                            productType: "Accessory",
                          ),
                        ];

                        products
                            .where(
                              (product) =>
                                  product.productName
                                      .toLowerCase()
                                      .contains(searchTerm.toLowerCase()) &&
                                  (selectedProductType == 'All Product' ||
                                      product.productType ==
                                          selectedProductType) &&
                                  (selectedCompany == 'All Company' ||
                                      product.company == selectedCompany) &&
                                  (selectedRoom == 'All Room' ||
                                      product.room == selectedRoom),
                            )
                            .toList();

                        // Sort the products based on selected category
                        products.sort((a, b) {
                          try {
                            switch (selectedCategory) {
                              case 'Recents':
                                return isAscending
                                    ? a.date.compareTo(b.date)
                                    : b.date.compareTo(a.date);
                              case 'Cost Price':
                                return isAscending
                                    ? double.parse(b.netCP)
                                        .compareTo(double.parse(a.netCP))
                                    : double.parse(a.netCP)
                                        .compareTo(double.parse(b.netCP));
                              case 'MRP':
                                return isAscending
                                    ? double.parse(b.saleCP)
                                        .compareTo(double.parse(a.saleCP))
                                    : double.parse(a.saleCP)
                                        .compareTo(double.parse(b.saleCP));
                              case 'Quantity':
                                return isAscending
                                    ? double.parse(b.quantity)
                                        .compareTo(double.parse(a.quantity))
                                    : double.parse(a.quantity)
                                        .compareTo(double.parse(b.quantity));
                              case 'Name':
                                return isAscending
                                    ? b.productName.compareTo(a.productName)
                                    : a.productName.compareTo(b.productName);
                              default:
                                return 0;
                            }
                          } catch (e) {
                            print(
                                'Error sorting products by $selectedCategory. Error: $e');
                            return 0;
                          }
                        });

                        // Calculate total NetCP and total quantity
                        double totalNetCP = calculateTotalNetCP(products);
                        double totalSalesCP = calculateTotalMRP(products);
                        return Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount =
                                      constraints.maxWidth > 1200
                                          ? 4
                                          : constraints.maxWidth > 600
                                              ? 3
                                              : 2;

                                  return GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio:
                                          screenWidth > 600 ? 0.71 : 0.65,
                                      crossAxisSpacing: 8.0,
                                      mainAxisSpacing: 8.0,
                                    ),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      final product = products[index];

                                      return GetCard(product: product);
                                    },
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Total NetCP: Rs. $totalNetCP',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (selectedCategory != "Cost Price") ...[
                                    Text(
                                      'Total MRP: Rs. $totalSalesCP',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            //   },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoute.addRoute);
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class GetCard extends StatelessWidget {
  final ProductModel product;

  const GetCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final dateString = product.date;
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                                "assets/images/${product.productImage}.webp"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Net Cost Price: Rs.${product.netCP}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'MRP: ${(product.saleCP)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Product Type: ${product.productType}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Seller Contact: ${product.sellerContact}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Total CP: ${(product.totalCP)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Quantity: ${product.quantity}',
                                style: TextStyle(
                                  fontSize: double.parse(product.quantity) < 11
                                      ? 15
                                      : 14,
                                  fontWeight:
                                      double.parse(product.quantity) < 11
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: double.parse(product.quantity) < 11
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Room: ${product.room}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Company: ${product.company}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Date: $dateString',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) => SureDelete(
                                name: product.productName,
                                image: product.productImage,
                              ),
                            );
                          },
                          child: const IconAndButton(
                            icon: Icons.delete_forever,
                            label: "Delete",
                            textColor: Colors.white,
                            fillColor: Colors.red,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProductView(product: product),
                              ),
                            );
                          },
                          child: const IconAndButton(
                            icon: Icons.edit,
                            label: "Edit",
                            textColor: Colors.white,
                            fillColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child:
                    Image.asset("assets/images/${product.productImage}.webp"),
              ),
              const SizedBox(height: 7.0),
              Text(
                product.productName.length > 53
                    ? '${product.productName.substring(0, 35)}...'
                    : product.productName,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3.0),
              Text('Net CP: Rs. ${(product.netCP)}'),
              const SizedBox(height: 3.0),
              if (selectedCategory == "Recents" ||
                  selectedCategory == "MRP") ...[
                Text('MRP: Rs. ${(product.saleCP)}'),
                const SizedBox(height: 3.0),
              ],
              Text(
                'Quantity: ${product.quantity}',
                style: TextStyle(
                  fontSize: double.parse(product.quantity) < 11 ? 15 : 14,
                  fontWeight: double.parse(product.quantity) < 11
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: double.parse(product.quantity) < 11
                      ? Colors.red
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 3.0),
              if (selectedCategory == "Name") ...[
                Text('Date: $dateString'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final bool isAscending;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.isAscending,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    List<String> categories = [
      'Recents',
      'Cost Price',
      'MRP',
      'Quantity',
      'Name'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final bool isSelected = category == selectedCategory;
            return GestureDetector(
              onTap: () {
                onCategorySelected(category);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        letterSpacing: 0.20,
                        fontSize: 18,
                        fontFamily: 'Urbanist',
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

double calculateTotalNetCP(List<ProductModel> products) {
  double totalNetCP = 0.0;
  for (ProductModel product in products) {
    try {
      double productNetCP = double.parse(product.netCP);
      double productQuantity = double.parse(product.quantity);
      totalNetCP += productNetCP * productQuantity;
    } catch (e) {
      print(
          'Error parsing netCP or quantity for product: ${product.productName}, netCP: ${product.netCP}, quantity: ${product.quantity}. Error: $e');
    }
  }
  return totalNetCP;
}
