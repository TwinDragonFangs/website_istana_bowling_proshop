import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  State<ProductCard> createState() =>
      _ProductCardState();
}

class _ProductCardState
    extends State<ProductCard> {
  late String selectedVariant;

  int qty = 1;

  @override
  void initState() {
    super.initState();

    selectedVariant =
        widget.product.variants.first;
  }

  @override
  Widget build(BuildContext context) {
    final cart =
        Provider.of<CartProvider>(
      context,
      listen: false,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Image.memory(
                base64Decode(
                  widget.product.imageBase64,
                ),
                fit: BoxFit.cover,
              )
            ),

            const SizedBox(height: 10),

            Text(
              widget.product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Rp ${widget.product.price}",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButton<String>(
              value: selectedVariant,
              isExpanded: true,
              items: widget.product.variants
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(v),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedVariant = value!;
                });
              },
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (qty > 1) {
                      setState(() {
                        qty--;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(qty.toString()),
                IconButton(
                  onPressed: () {
                    setState(() {
                      qty++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cart.addToCart(
                    widget.product,
                    selectedVariant,
                    qty,
                  );

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Ditambahkan ke keranjang",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Tambah ke Keranjang",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}