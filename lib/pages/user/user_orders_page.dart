import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserOrdersPage extends StatelessWidget {
  const UserOrdersPage({super.key});

  String formatRupiah(int value) {
    return "Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}";
  }

  Color statusColor(String status) {
    switch (status) {
      case "Menunggu Pembayaran":
        return Colors.orange;
      case "Diproses":
        return Colors.blue;
      case "Pre Order":
        return Colors.deepOrange;
      case "Dikirim":
        return Colors.purple;
      case "Selesai":
        return Colors.green;
      case "Dibatalkan":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Silakan login terlebih dahulu"),
        ),
      );
    }

    final email =
        user.email!.trim().toLowerCase();

    print(
      "LOGIN EMAIL = ${FirebaseAuth.instance.currentUser?.email}",
    );

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          "Pesanan Saya",
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where(
              'customerEmail',
              isEqualTo: FirebaseAuth.instance
                  .currentUser!
                  .email!
                  .trim()
                  .toLowerCase(),
            )
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada pesanan",
              ),
            );
          }

          final orders =
              snapshot.data!.docs;

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {

              final doc = orders[index];

              final data =
                  doc.data()
                      as Map<String, dynamic>;

              final items =
                  (data['items'] as List?) ??
                      [];

              final total =
                  data['totalPrice'] ?? 0;

              final status =
                  data['status'] ?? '-';

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      Row(
                        children: [

                          Expanded(
                            child: Text(
                              data['customerName'] ??
                                  '-',
                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  statusColor(
                                status,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              status,
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 10),

                      Text(
                        "Tanggal: ${data['orderDate'] ?? '-'}",
                      ),

                      Text(
                        "No HP: ${data['phone'] ?? '-'}",
                      ),

                      Text(
                        "Alamat: ${data['address'] ?? '-'}",
                      ),

                      if ((data['preOrderDays'] ??
                              0) >
                          0)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 5,
                          ),
                          child: Text(
                            "Pre Order ${data['preOrderDays']} hari",
                            style:
                                const TextStyle(
                              color:
                                  Colors.orange,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                      const Divider(),

                      ...items.map((item) {

                        return ListTile(
                          contentPadding:
                              EdgeInsets.zero,

                          leading:
                              item['image'] !=
                                      null
                                  ? Image.memory(
                                      base64Decode(
                                        item[
                                            'image'],
                                      ),
                                      width: 50,
                                      height:
                                          50,
                                      fit: BoxFit
                                          .cover,
                                    )
                                  : const Icon(
                                      Icons
                                          .image,
                                    ),

                          title: Text(
                            item['name'] ??
                                '',
                          ),

                          subtitle: Text(
                            "${item['variant']} | ${formatRupiah(item['price'] ?? 0)}",
                          ),

                          trailing: Text(
                            "x${item['qty']}",
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        );
                      }),

                      const Divider(),

                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: Text(
                          "TOTAL : ${formatRupiah(total)}",
                          style:
                              const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}