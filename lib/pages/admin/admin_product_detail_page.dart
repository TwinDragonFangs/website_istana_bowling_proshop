import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';

class AdminProductDetailPage extends StatelessWidget {
  final Product product;

  const AdminProductDetailPage({
    super.key,
    required this.product,
  });

  String formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget buildProductImage() {
    if (product.imageBase64.isEmpty) {
      return Container(
        height: 450,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Image.memory(
            base64Decode(product.imageBase64),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              formatRupiah(product.price),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 10),

            const Text(
              "Kategori",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 5),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.category,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Varian / Berat",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.variants.map((variant) {
                return Chip(
                  label: Text(variant),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            const Text(
              "Deskripsi Produk",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              product.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isDesktop = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(product.name),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: buildProductImage(),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    flex: 4,
                    child: buildInfoCard(),
                  ),
                ],
              )
            : Column(
                children: [
                  buildProductImage(),

                  const SizedBox(height: 20),

                  buildInfoCard(),
                ],
              ),
      ),
    );
  }
}