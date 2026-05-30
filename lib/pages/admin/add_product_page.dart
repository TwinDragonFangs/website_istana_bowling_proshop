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
            "Format gambar tidak didukung");
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

      final originalSize =
          bytes.length / 1024;

      final compressedSize =
          compressed.length / 1024;

      debugPrint(
        "Original: ${originalSize.toStringAsFixed(0)} KB",
      );

      debugPrint(
        "Compressed: ${compressedSize.toStringAsFixed(0)} KB",
      );

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
      debugPrint(
        "Compress Error: $e",
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text("Gagal memproses gambar: $e"),
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (_imageBase64 == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Silakan pilih gambar"),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _db.collection('products').add({
        'name': _nameC.text.trim(),
        'price':
            int.tryParse(_priceC.text) ?? 0,
        'description':
            _descC.text.trim(),
        'imageBase64':
            _imageBase64,
        'variants': variants,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Produk berhasil ditambahkan',
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text('Gagal menyimpan: $e'),
          ),
        );
      }
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Tambah Produk"),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [
          GestureDetector(
            onTap: _pickImage,

            child: Container(
              height: 220,

              decoration: BoxDecoration(
                color:
                    Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(
                        12),
              ),

              child: _imageBase64 ==
                      null
                  ? const Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 50,
                        ),
                        SizedBox(
                            height: 8),
                        Text(
                            "Klik untuk memilih gambar"),
                      ],
                    )
                  : ClipRRect(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),

                      child: Image.memory(
                        base64Decode(
                            _imageBase64!),
                        fit:
                            BoxFit.cover,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _nameC,
            decoration:
                const InputDecoration(
              labelText:
                  'Nama Produk',
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _priceC,
            keyboardType:
                TextInputType.number,

            decoration:
                const InputDecoration(
              labelText: 'Harga',
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _descC,
            maxLines: 4,

            decoration:
                const InputDecoration(
              labelText:
                  'Deskripsi',
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                      _variantC,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Variant (12 lbs)',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(
                  width: 8),

              IconButton(
                onPressed: () {
                  if (_variantC
                      .text.isEmpty) {
                    return;
                  }

                  setState(() {
                    variants.add(
                        _variantC.text);

                    _variantC.clear();
                  });
                },

                icon: const Icon(
                  Icons.add_circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children: variants
                .map(
                  (v) => Chip(
                    label: Text(v),

                    onDeleted: () {
                      setState(() {
                        variants
                            .remove(v);
                      });
                    },
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 55,

            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : _saveProduct,

              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text(
                      "Simpan Produk",
                    ),
            ),
          ),
        ],
      ),
    );
  }
}