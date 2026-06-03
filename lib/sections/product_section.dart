import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/product_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final bool isAdmin;
  final bool isGuest;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    this.isAdmin = false,
    this.isGuest = false,
  });

  int _getCrossAxisCount(double width) {
    if (width > 1400) return 5;
    if (width > 1100) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 30,
                color: Colors.orange,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  _getCrossAxisCount(width),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio:
                  isAdmin ? 0.85 : 0.65,
            ),
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                isAdmin: isAdmin,
                isGuest: isGuest,
              );
            },
          ),
        ],
      ),
    );
  }
}