import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() =>
      _AddProductPageState();
}

class _AddProductPageState
    extends State<AddProductPage> {
  final _nameC = TextEditingController();
  final _priceC = TextEditingController();
  final _descC = TextEditingController();
  final _variantC = TextEditingController();

  final _db = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  String? _imageBase64;

  bool _loading = false;

  String selectedCategory = "Ball";

  final List<String> categories = [
    "Ball",
    "Shoes",
    "Bag",
    "Accessories",
  ];

  List<String> variants = [];

  Future<void> _pickImage() async {
    final xFile =
        await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (xFile == null) return;

    try {
      final bytes =
          await xFile.readAsBytes();

      final image =
          img.decodeImage(bytes);

      if (image == null) {
        throw Exception(
          "Format gambar tidak didukung",
        );
      }

      final resized =
          img.copyResize(
        image,
        width: 1200,
      );

      final compressed =
          img.encodeJpg(
        resized,
        quality: 70,
      );

      setState(() {
        _imageBase64 =
            base64Encode(compressed);
      });

      final compressedSize =
          compressed.length / 1024;

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "Gambar berhasil dikompres (${compressedSize.toStringAsFixed(0)} KB)",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (_imageBase64 == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Pilih gambar terlebih dahulu"),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _db.collection(
        'products',
      ).add({
        'name':
            _nameC.text.trim(),

        'price':
            int.tryParse(
                  _priceC.text,
                ) ??
                0,

        'description':
            _descC.text.trim(),

        'imageBase64':
            _imageBase64,

        'category':
            selectedCategory,

        'variants':
            variants,

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Produk berhasil ditambahkan",
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Gagal: $e"),
        ),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  InputDecoration inputStyle(
    String label,
  ) {
    return InputDecoration(
      labelText: label,

      filled: true,
      fillColor: Colors.white,

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xfff5f5f5),

      appBar: AppBar(
        backgroundColor:
            Colors.black,

        title: const Text(
          "Tambah Produk",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight:
                FontWeight.bold,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),

      body: Center(
        child: Container(
          width: 900,
          padding:
              const EdgeInsets.all(20),

          child: Card(
            elevation: 5,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            child: Padding(
              padding:
                  const EdgeInsets.all(20),

              child: ListView(
                shrinkWrap: true,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 400,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),

                      child: _imageBase64 == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 70,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Klik untuk memilih gambar",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 5,
                                child: Image.memory(
                                  base64Decode(_imageBase64!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  TextField(
                    controller:
                        _nameC,
                    decoration:
                        inputStyle(
                      "Nama Produk",
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  TextField(
                    controller:
                        _priceC,
                    keyboardType:
                        TextInputType
                            .number,
                    decoration:
                        inputStyle(
                      "Harga",
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  TextField(
                    controller:
                        _descC,
                    maxLines: 4,
                    decoration:
                        inputStyle(
                      "Deskripsi",
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  DropdownButtonFormField<
                      String>(
                    value:
                        selectedCategory,

                    decoration:
                        inputStyle(
                      "Kategori",
                    ),

                    items: categories
                        .map(
                          (e) =>
                              DropdownMenuItem(
                            value: e,
                            child:
                                Text(e),
                          ),
                        )
                        .toList(),

                    onChanged:
                        (value) {
                      setState(() {
                        selectedCategory =
                            value!;
                      });
                    },
                  ),

                  const SizedBox(
                      height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              _variantC,

                          decoration:
                              inputStyle(
                            "Variant (12 lbs)",
                          ),
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xffD4AF37,
                          ),
                        ),

                        onPressed: () {
                          if (_variantC
                              .text
                              .isEmpty) {
                            return;
                          }

                          setState(() {
                            variants.add(
                              _variantC.text,
                            );

                            _variantC
                                .clear();
                          });
                        },

                        child:
                            const Icon(
                          Icons.add,
                          color: Colors
                              .black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 15),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,

                    children:
                        variants.map(
                      (v) {
                        return Chip(
                          backgroundColor:
                              const Color(
                            0xffD4AF37,
                          ),

                          label:
                              Text(v),

                          onDeleted:
                              () {
                            setState(
                              () {
                                variants.remove(
                                  v,
                                );
                              },
                            );
                          },
                        );
                      },
                    ).toList(),
                  ),

                  const SizedBox(
                      height: 30),

                  SizedBox(
                    height: 55,

                    child:
                        ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xffD4AF37,
                        ),
                      ),

                      onPressed:
                          _loading
                              ? null
                              : _saveProduct,

                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "SIMPAN PRODUK",
                              style:
                                  TextStyle(
                                color: Colors
                                    .black,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}