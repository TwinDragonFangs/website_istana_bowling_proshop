import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

import '../pages/admin/admin_product_detail_page.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool isAdmin;

  const ProductCard({
    super.key,
    required this.product,
    this.isAdmin = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late String selectedVariant;

  int qty = 1;

  String formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  void initState() {
    super.initState();

    selectedVariant = widget.product.variants.isNotEmpty
        ? widget.product.variants.first
        : "";
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(
      context,
      listen: false,
    );

    // ==========================
    // ADMIN MODE
    // ==========================
    if (widget.isAdmin) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminProductDetailPage(
                product: widget.product,
              ),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: Image.memory(
                    base64Decode(
                      widget.product.imageBase64,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.product.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  formatRupiah(widget.product.price),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ==========================
    // USER MODE
    // ==========================
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Image.memory(
                base64Decode(
                  widget.product.imageBase64,
                ),
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              widget.product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              formatRupiah(widget.product.price),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (widget.product.variants.isNotEmpty)
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

                Text(
                  qty.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

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