import 'package:flutter/material.dart';
import 'manage_orders_page.dart';
import '../../services/firebase_service.dart';
import '../../sections/navbar.dart';
import '../../sections/banner_section.dart';
import '../../sections/product_section.dart';
import '../../sections/footer.dart';

import '../../models/product.dart';

import 'add_product_page.dart';
import 'manage_products_page.dart';
import 'admin_profile_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _service = FirebaseService();

  String selectedCategory = "All";
  String selectedWeight = "All";
  String searchQuery = "";

  List<Product> filterProducts(List<Product> products) {
    return products.where((p) {
      final name = p.name.toLowerCase();
      final query = searchQuery.toLowerCase();

      final matchSearch = name.contains(query);

      final matchCategory =
          selectedCategory == "All" || p.category == selectedCategory;

      final matchWeight =
          selectedWeight == "All" ||
          p.variants.contains(selectedWeight);

      return matchSearch && matchCategory && matchWeight;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      body: FutureBuilder<List<Product>>(
        future: _service.getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = filterProducts(snapshot.data!);

          return Column(
            children: [
                Navbar(
                  isAdmin: true,

                  onOrdersAdmin: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageOrdersPage(),
                      ),
                    );
                  },

                  onCategorySelected: (c) {
                    setState(() {
                      selectedCategory = c;
                    });
                  },

                  onAdd: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddProductPage(),
                      ),
                    );
                  },

                  onManage: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageProductsPage(),
                      ),
                    );
                  },

                  onProfileAdmin: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminProfilePage(),
                      ),
                    );
                  },
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      
                const BannerSection(
                  isAdmin: true,
                ),

                const SizedBox(height: 10),

                // SEARCH + FILTER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: "Cari produk...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: ["All", "Ball", "Shoes", "Accessories", "Bag"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: selectedWeight,
                          items: ["All", "10", "12", "14", "16"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e == "All" ? e : "$e lbs"),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedWeight = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 🔥 INI PENTING: PRODUCTSECTION HARUS MODE ADMIN
                ProductSection(
                  title: "Produk",
                  products: products,
                  isAdmin: true,
                ),

                    const Footer(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}