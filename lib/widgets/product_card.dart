import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../pages/auth/login_page.dart';
import '../pages/admin/admin_product_detail_page.dart';
import '../pages/user/product_detail_page.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool isAdmin;
  final bool isGuest;

  const ProductCard({
    super.key,
    required this.product,
    this.isAdmin = false,
    this.isGuest = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  void showLoginRequired() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Login Diperlukan"),
        content: const Text(
          "Silakan login terlebih dahulu untuk menambahkan produk ke keranjang.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
            child: const Text("Login"),
          ),
        ],
      );
    },
  );
}
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
return InkWell(
  borderRadius: BorderRadius.circular(12),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          product: widget.product,
          isGuest: widget.isGuest,
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
          ],
        ),
      ),
    ),
  );
  }
}