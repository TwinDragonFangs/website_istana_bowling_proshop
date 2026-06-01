import 'dart:convert';
import 'edit_product_page.dart';
import '../../models/product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageProductsPage extends StatelessWidget {
  const ManageProductsPage({super.key});

  String formatRupiah(int value) {
    return "Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: const Text(
          "Kelola Produk",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy(
              'createdAt',
              descending: true,
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
                "Belum ada produk",
              ),
            );
          }

          final products =
              snapshot.data!.docs;

          return ListView.builder(
            padding:
                const EdgeInsets.all(20),

            itemCount:
                products.length,

            itemBuilder:
                (context, index) {
              final doc =
                  products[index];

              final data =
                  doc.data()
                      as Map<String,
                          dynamic>;

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 15,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          15),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(
                          12),

                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),

                        child: Image.memory(
                          base64Decode(
                            data[
                                'imageBase64'],
                          ),

                          width: 90,
                          height: 90,

                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(
                          width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Text(
                              data['name'] ??
                                  '',

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(
                                height: 5),

                            Text(
                              "Kategori : ${data['category']}",
                            ),

                            const SizedBox(
                                height: 5),

                            Text(
                              formatRupiah(
                                ((data['price'] ?? 0) as num).toInt(),
                              ),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.orange,
                        ),
                        onPressed: () {

                          final product = Product(
                            id: doc.id,
                            name: data['name'] ?? '',
                            price: data['price'] ?? 0,
                            description: data['description'] ?? '',
                            imageBase64: data['imageBase64'] ?? '',
                            category: data['category'] ?? 'Ball',
                            variants: List<String>.from(
                              data['variants'] ?? [],
                            ),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProductPage(
                                product: product,
                              ),
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color:
                              Colors.red,
                        ),
                        onPressed: () {
                          _deleteProduct(
                            context,
                            doc.id,
                          );
                        },
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

  Future<void> _deleteProduct(
    BuildContext context,
    String productId,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:
            const Text("Hapus Produk"),
        content: const Text(
          "Yakin ingin menghapus produk ini?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                  context,
                  false);
            },
            child: const Text(
              "Batal",
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                  context,
                  true);
            },
            child: const Text(
              "Hapus",
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Produk berhasil dihapus",
        ),
      ),
    );
  }
}