import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/order_notification_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Belanja"),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text("Keranjang masih kosong"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      // 🔥 SUBTOTAL PER ITEM
                      final int subtotal =
                          item.quantity * item.product.price;

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: item.selected,
                                onChanged: (_) {
                                  cart.toggleSelected(item);
                                },
                              ),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  base64Decode(item.product.imageBase64),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      "Harga: ${currencyFormat.format(item.product.price)}",
                                    ),

                                    const SizedBox(height: 5),

                                    Text("Variant: ${item.selectedVariant}"),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              cart.decreaseQty(item),
                                          icon: const Icon(Icons.remove),
                                        ),
                                        Text(item.quantity.toString()),
                                        IconButton(
                                          onPressed: () =>
                                              cart.increaseQty(item),
                                          icon: const Icon(Icons.add),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // 🔥 SUBTOTAL DISPLAY
                                    Text(
                                      "Subtotal: ${currencyFormat.format(subtotal)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  cart.removeItem(item);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ================= TOTAL SECTION =================
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormat.format(cart.totalPrice),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                          ),
                          label: const Text("Pesan via WhatsApp"),
                          onPressed: () async {
                            if (cart.selectedItems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Pilih produk terlebih dahulu",
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              final user =
                                  FirebaseAuth.instance.currentUser;

                              if (user == null) return;

                              final userDoc = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();

                              if (!userDoc.exists) return;

                              final userData = userDoc.data()!;

                              final List<Map<String, dynamic>>
                                  orderItems = [];

                              for (final item
                                  in cart.selectedItems) {
                                final subtotal =
                                    item.quantity *
                                        item.product.price;

                                orderItems.add({
                                  'id': item.product.id,
                                  'name': item.product.name,
                                  'price': item.product.price,
                                  'qty': item.quantity,
                                  'subtotal': subtotal, // 🔥 TAMBAHAN
                                  'variant': item.selectedVariant,
                                  'image':
                                      item.product.imageBase64,
                                });
                              }

                              final docRef = await FirebaseFirestore.instance
                                .collection('orders')
                                .add({
                                'customerName':
                                    userData['name'] ?? '',
                                'customerEmail':
                                    userData['email'] ?? '',
                                'phone':
                                    userData['phone'] ?? '',
                                'address':
                                    userData['address'] ?? '',
                                'orderDate':
                                    DateTime.now()
                                        .toString()
                                        .substring(0, 10),
                                'items': orderItems,
                                'totalPrice': cart.totalPrice,
                                'status':
                                    'Menunggu Pembayaran',
                                'createdAt': FieldValue
                                    .serverTimestamp(),
                              });

                              await OrderNotificationService.notifyAdminNewOrder(
                                orderId: docRef.id,
                                customerName: userData['name'],
                              );

                              String message =
                                  "=== ORDER ISTANA BOWLING PROSHOP ===\n\n";

                              message +=
                                  "Nama : ${userData['name']}\n";
                              message +=
                                  "Email : ${userData['email']}\n";
                              message +=
                                  "No HP : ${userData['phone']}\n";
                              message +=
                                  "Alamat : ${userData['address']}\n\n";

                              message += "========================\n\n";

                              for (int i = 0;
                                  i < cart.selectedItems.length;
                                  i++) {
                                final item =
                                    cart.selectedItems[i];

                                final subtotal = item.quantity *
                                    item.product.price;

                                message +=
                                    "${i + 1}. ${item.product.name}\n";
                                message +=
                                    "Variant : ${item.selectedVariant}\n";
                                message +=
                                    "Qty : ${item.quantity}\n";
                                message +=
                                    "Harga : ${currencyFormat.format(item.product.price)}\n";
                                message +=
                                    "Subtotal : ${currencyFormat.format(subtotal)}\n\n";
                              }

                              message += "========================\n\n";

                              message +=
                                  "TOTAL : ${currencyFormat.format(cart.totalPrice)}\n\n";

                              message +=
                                  "Mohon konfirmasi pesanan saya.";

                              final encoded =
                                  Uri.encodeComponent(message);

                              const adminPhone = "6282172041712";

                              final url =
                                  "https://wa.me/$adminPhone?text=$encoded";

                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );

                              // 🔥 AUTO REFRESH / RESET CART SETELAH CHECKOUT
                              Future.delayed(const Duration(milliseconds: 500), () {
                                cart.clearSelected(); // hanya hapus yang dipilih
                                // atau kalau mau full reset:
                                // cart.clearCart();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Pesanan dikirim, keranjang diperbarui"),
                                  ),
                                );
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text("Error : $e"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}