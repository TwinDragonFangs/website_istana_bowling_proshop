import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/firebase_service.dart';
import '../../sections/navbar.dart';
import '../../sections/banner_section.dart';
import '../../sections/product_section.dart';
import '../../sections/footer.dart';
import './user_orders_page.dart';
import '../cart_page.dart';
import '../user_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {
  final FirebaseService _service =
      FirebaseService();

  String selectedCategory = "All";
  String selectedWeight = "All";
  String searchQuery = "";

  List<Product> filterProducts(
    List<Product> products,
  ) {
    return products.where((p) {
      final name =
          p.name.toLowerCase();

      final query =
          searchQuery.toLowerCase();

      final matchSearch =
          name.contains(query);

      final matchCategory =
          selectedCategory == "All" ||
              p.category ==
                  selectedCategory;

      final matchWeight =
          selectedWeight == "All" ||
              p.variants.any(
                (variant) =>
                    variant
                        .toLowerCase()
                        .contains(
                          selectedWeight
                              .toLowerCase(),
                        ),
              );

      return matchSearch &&
          matchCategory &&
          matchWeight;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<CartProvider>(
      context,
    );

    return Scaffold(
      backgroundColor:
          const Color(0xfff5f5f5),

      body:
          FutureBuilder<List<Product>>(
        future:
            _service.getProducts(),

        builder:
            (context, snapshot) {
          if (snapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          final products =
              filterProducts(
            snapshot.data ?? [],
          );

          return Column(
            children: [
              Navbar(
                isAdmin: false,

                onCategorySelected:
                    (c) {
                  setState(() {
                    selectedCategory =
                        c;
                  });
                },

                onProfileUser: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const UserProfilePage(),
                    ),
                  );
                },

                onOrdersUser: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const UserOrdersPage(),
                    ),
                  );
                },

                onCart: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CartPage(),
                    ),
                  );
                },
              ),

              Expanded(
                child:
                    SingleChildScrollView(
                  child: Column(
                    children: [
                      const BannerSection(),

                      const SizedBox(
                        height: 10,
                      ),

                      Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                        ),

                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,

                              child:
                                  TextField(
                                onChanged:
                                    (
                                      value,
                                    ) {
                                  setState(
                                    () {
                                      searchQuery =
                                          value;
                                    },
                                  );
                                },

                                decoration:
                                    InputDecoration(
                                  prefixIcon:
                                      const Icon(
                                    Icons
                                        .search,
                                  ),

                                  hintText:
                                      "Cari produk...",

                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      10,
                                    ),
                                  ),

                                  filled:
                                      true,

                                  fillColor:
                                      Colors.white,

                                  isDense:
                                      true,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              flex: 2,

                              child:
                                  DropdownButtonFormField<
                                      String>(
                                value:
                                    selectedCategory,

                                items: [
                                  "All",
                                  "Ball",
                                  "Shoes",
                                  "Accessories",
                                  "Bag",
                                ]
                                    .map(
                                      (
                                        e,
                                      ) =>
                                          DropdownMenuItem(
                                        value:
                                            e,
                                        child:
                                            Text(
                                          e,
                                        ),
                                      ),
                                    )
                                    .toList(),

                                onChanged:
                                    (
                                      value,
                                    ) {
                                  setState(
                                    () {
                                      selectedCategory =
                                          value!;
                                    },
                                  );
                                },

                                decoration:
                                    const InputDecoration(
                                  border:
                                      OutlineInputBorder(),
                                  filled:
                                      true,
                                  fillColor:
                                      Colors.white,
                                  isDense:
                                      true,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              flex: 2,

                              child:
                                  DropdownButtonFormField<
                                      String>(
                                value:
                                    selectedWeight,

                                items: [
                                  "All",
                                  "10",
                                  "12",
                                  "14",
                                  "16",
                                ]
                                    .map(
                                      (
                                        e,
                                      ) =>
                                          DropdownMenuItem(
                                        value:
                                            e,
                                        child:
                                            Text(
                                          e ==
                                                  "All"
                                              ? e
                                              : "$e lbs",
                                        ),
                                      ),
                                    )
                                    .toList(),

                                onChanged:
                                    (
                                      value,
                                    ) {
                                  setState(
                                    () {
                                      selectedWeight =
                                          value!;
                                    },
                                  );
                                },

                                decoration:
                                    const InputDecoration(
                                  border:
                                      OutlineInputBorder(),
                                  filled:
                                      true,
                                  fillColor:
                                      Colors.white,
                                  isDense:
                                      true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      ProductSection(
                        title:
                            selectedCategory ==
                                    "All"
                                ? "All Products"
                                : selectedCategory,

                        products:
                            products,
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