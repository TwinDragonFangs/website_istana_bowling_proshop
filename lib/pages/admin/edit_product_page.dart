import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../../models/product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({
    super.key,
    required this.product,
  });

  @override
  State<EditProductPage> createState() =>
      _EditProductPageState();
}

class _EditProductPageState
    extends State<EditProductPage> {
  final _db = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  late TextEditingController _nameC;
  late TextEditingController _priceC;
  late TextEditingController _descC;
  late TextEditingController _variantC;

  bool _loading = false;

  String? _imageBase64;

  String selectedCategory = "Ball";

  final List<String> categories = [
    "Ball",
    "Shoes",
    "Bag",
    "Accessories",
  ];

  List<String> variants = [];

  String formatRupiah(String value) {
    if (value.isEmpty) return "";

    value = value.replaceAll(".", "");

    return value.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  void initState() {
    super.initState();

    _imageBase64 =
        widget.product.imageBase64;

    _nameC = TextEditingController(
      text: widget.product.name,
    );

    _priceC = TextEditingController(
      text: formatRupiah(
        widget.product.price.toString(),
      ),
    );

    _descC = TextEditingController(
      text: widget.product.description,
    );

    _variantC = TextEditingController();

    selectedCategory =
        widget.product.category;

    variants = List<String>.from(
      widget.product.variants,
    );
  }

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
        width: 800,
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

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Gambar berhasil diperbarui (${(compressed.length / 1024).toStringAsFixed(0)} KB)",
          ),
        ),
      );
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

  Future<void> updateProduct() async {
    setState(() {
      _loading = true;
    });

    try {
      await _db
          .collection('products')
          .doc(widget.product.id)
          .update({
        'name':
            _nameC.text.trim(),

        'price': int.tryParse(
              _priceC.text
                  .replaceAll(".", ""),
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
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Produk berhasil diupdate",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Gagal: $e"),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
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
            BorderRadius.circular(
          12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameC.dispose();
    _priceC.dispose();
    _descC.dispose();
    _variantC.dispose();
    super.dispose();
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
          "Edit Produk",
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: Center(
        child: Container(
          width: 900,

          padding:
              const EdgeInsets.all(
            20,
          ),

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
                  const EdgeInsets.all(
                20,
              ),

              child: ListView(
                shrinkWrap: true,
                children: [

                  GestureDetector(
                    onTap: _pickImage,

                    child: Container(
                      height: 300,

                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),

                        border:
                            Border.all(
                          color:
                              Colors.grey,
                        ),
                      ),

                      child:
                          _imageBase64 ==
                                  null
                              ? const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 60,
                                    ),
                                    SizedBox(
                                      height:
                                          10,
                                    ),
                                    Text(
                                      "Klik untuk memilih gambar",
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    15,
                                  ),

                                  child:
                                      Image.memory(
                                    base64Decode(
                                      _imageBase64!,
                                    ),

                                    fit: BoxFit.contain,
                                  ),
                                ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextField(
                    controller:
                        _nameC,
                    decoration:
                        inputStyle(
                      "Nama Produk",
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  TextField(
                    controller:
                        _priceC,

                    keyboardType:
                        TextInputType.number,

                    decoration:
                        inputStyle(
                      "Harga",
                    ),

                    onChanged:
                        (value) {
                      final raw =
                          value.replaceAll(
                        ".",
                        "",
                      );

                      if (raw.isEmpty) {
                        return;
                      }

                      final formatted =
                          formatRupiah(
                        raw,
                      );

                      _priceC.value =
                          TextEditingValue(
                        text:
                            formatted,

                        selection:
                            TextSelection.collapsed(
                          offset:
                              formatted
                                  .length,
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 15,
                  ),

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
                    height: 15,
                  ),

                  DropdownButtonFormField<
                      String>(
                    value:
                        selectedCategory,

                    decoration:
                        inputStyle(
                      "Kategori",
                    ),

                    items:
                        categories
                            .map(
                              (e) =>
                                  DropdownMenuItem(
                                value:
                                    e,
                                child:
                                    Text(
                                  e,
                                ),
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
                    height: 20,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            TextField(
                          controller:
                              _variantC,

                          decoration:
                              inputStyle(
                            "Variant (12 lbs)",
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xffD4AF37,
                          ),
                        ),

                        onPressed:
                            () {
                          if (_variantC
                              .text
                              .trim()
                              .isEmpty) {
                            return;
                          }

                          setState(() {
                            variants.add(
                              _variantC
                                  .text
                                  .trim(),
                            );

                            _variantC
                                .clear();
                          });
                        },

                        child:
                            const Icon(
                          Icons.add,
                          color:
                              Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

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
                                variants
                                    .remove(
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
                    height: 30,
                  ),

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
                              : updateProduct,

                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "UPDATE PRODUK",
                              style:
                                  TextStyle(
                                color:
                                    Colors.black,
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