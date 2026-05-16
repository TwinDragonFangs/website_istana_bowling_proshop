import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';

import '../../sections/banner_section.dart';
import '../../sections/footer.dart';
import '../../sections/navbar.dart';
import '../../sections/product_section.dart';

import '../../services/firebase_service.dart';
import '../../services/whatsapp_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirebaseService _service =
      FirebaseService();

  @override
  Widget build(BuildContext context) {

    final cart =
        Provider.of<CartProvider>(context);

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Istana Bowling Proshop",
        ),

        actions: [

          Padding(
            padding:
                const EdgeInsets.only(right: 20),

            child: Stack(

              alignment: Alignment.center,

              children: [

                IconButton(

                  onPressed: () {

                    if (cart.items.isEmpty) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content:
                              Text("Keranjang kosong"),
                        ),
                      );

                      return;
                    }

                    WhatsAppService.checkout(
                      cart.items,
                      cart.totalPrice,
                    );
                  },

                  icon: const Icon(
                    Icons.shopping_cart,
                  ),
                ),

                Positioned(

                  right: 0,
                  top: 0,

                  child: Container(

                    padding:
                        const EdgeInsets.all(5),

                    decoration:
                        const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),

                    child: Text(
                      cart.items.length.toString(),

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: FutureBuilder<List<Product>>(

        future: _service.getProducts(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final products =
              snapshot.data ?? [];

          if (products.isEmpty) {

            return const Center(
              child: Text(
                'Belum ada produk',
              ),
            );
          }

          return SingleChildScrollView(

            child: Column(

              children: [

                const Navbar(),

                const BannerSection(),

                ProductSection(
                  title:
                      "Hottest Bowling Balls",

                  products: products,
                ),

                ProductSection(
                  title:
                      "Recommended Products",

                  products: products,
                ),

                const Footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}