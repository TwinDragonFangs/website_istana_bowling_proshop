import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../auth/login_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final bool isGuest;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.isGuest = false,
  });

  @override
  State<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState
    extends State<ProductDetailPage> {
  late String selectedVariant;

  int qty = 1;

  @override
  void initState() {
    super.initState();

    selectedVariant =
        widget.product.variants.isNotEmpty
            ? widget.product.variants.first
            : "";
  }

  String formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void showLoginRequired() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Login Diperlukan",
        ),
        content: const Text(
          "Silakan login terlebih dahulu untuk menambahkan produk ke keranjang.",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LoginPage(),
                ),
              );
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart =
        Provider.of<CartProvider>(
      context,
      listen: false,
    );

    final width =
        MediaQuery.of(context).size.width;

    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor:
          const Color(0xfff5f5f5),

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.product.name),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: isDesktop
            ? Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildImage(),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: _buildInfo(cart),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildImage(),
                  const SizedBox(height: 20),
                  _buildInfo(cart),
                ],
              ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: InteractiveViewer(
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Image.memory(
            base64Decode(
              widget.product.imageBase64,
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(
      CartProvider cart) {
        final totalPrice =
          widget.product.price * qty;
          
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              formatRupiah(
                widget.product.price,
              ),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.red,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Pilih Varian / Berat",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            widget.product.variants.isNotEmpty
              ? Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.product.variants.map((variant) {
                    final isSelected =
                        selectedVariant == variant;

                    return ChoiceChip(
                      label: Text(
                        variant,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.orange,
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() {
                          selectedVariant = variant;
                        });
                      },
                    );
                  }).toList(),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: const Text("-"),
                ),

            const SizedBox(height: 20),

            const Text(
              "Jumlah",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                        fontSize: 18,
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
              ),

              const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 10),

                const Text(
                  "Subtotal",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  formatRupiah(totalPrice),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon:
                    const Icon(Icons.shopping_cart),
                label: const Text(
                  "Tambah ke Keranjang",
                ),
                onPressed: () {
                  if (widget.isGuest) {
                    showLoginRequired();
                    return;
                  }

                  cart.addToCart(
                    widget.product,
                    selectedVariant,
                    qty,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Ditambahkan ke keranjang",
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Deskripsi Produk",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              widget.product.description,
              style: const TextStyle(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}