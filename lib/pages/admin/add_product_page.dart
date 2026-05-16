import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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

    final compressed =
        await FlutterImageCompress
            .compressWithFile(
      xFile.path,
      quality: 60,
      minWidth: 500,
      minHeight: 500,
    );

    if (compressed == null) return;

    setState(() {
      _imageBase64 =
          base64Encode(compressed);
    });
  }

  Future<void> _saveProduct() async {

    if (_imageBase64 == null) return;

    setState(() {
      _loading = true;
    });

    await _db.collection('products').add({
      'name': _nameC.text.trim(),

      'price':
          int.tryParse(_priceC.text) ?? 0,

      'description':
          _descC.text.trim(),

      'imageBase64': _imageBase64,

      'variants': variants,

      'createdAt':
          FieldValue.serverTimestamp(),
    });

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Produk berhasil ditambahkan'),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Tambah Produk",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          GestureDetector(
            onTap: _pickImage,

            child: Container(
              height: 200,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: _imageBase64 == null
                  ? const Icon(
                      Icons.add_a_photo,
                      size: 50,
                    )
                  : ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),

                      child: Image.memory(
                        base64Decode(
                            _imageBase64!),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _nameC,
            decoration:
                const InputDecoration(
              labelText: 'Nama Produk',
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
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _descC,

            maxLines: 3,

            decoration:
                const InputDecoration(
              labelText: 'Deskripsi',
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: TextField(
                  controller: _variantC,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Variant (12 lbs)',
                  ),
                ),
              ),

              IconButton(
                onPressed: () {

                  if (_variantC.text.isEmpty) {
                    return;
                  }

                  setState(() {

                    variants.add(
                        _variantC.text);

                    _variantC.clear();
                  });
                },

                icon: const Icon(Icons.add),
              ),
            ],
          ),

          Wrap(
            spacing: 8,

            children: variants
                .map(
                  (v) => Chip(
                    label: Text(v),

                    onDeleted: () {
                      setState(() {
                        variants.remove(v);
                      });
                    },
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed:
                _loading ? null : _saveProduct,

            child: _loading
                ? const CircularProgressIndicator()
                : const Text(
                    "Simpan Produk",
                  ),
          ),
        ],
      ),
    );
  }
}