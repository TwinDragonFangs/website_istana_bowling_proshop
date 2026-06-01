import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class EditBannerPage extends StatefulWidget {
  const EditBannerPage({super.key});

  @override
  State<EditBannerPage> createState() =>
      _EditBannerPageState();
}

class _EditBannerPageState
    extends State<EditBannerPage> {
  final TextEditingController titleC =
      TextEditingController();

  final ImagePicker _picker =
      ImagePicker();

  String imageBase64 = "";

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadBanner();
  }

  Future<void> loadBanner() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('banners')
              .doc('main_banner')
              .get();

      if (doc.exists) {
        final data =
            doc.data() as Map<String, dynamic>;

        titleC.text =
            data['title'] ?? '';

        imageBase64 =
            data['imageBase64'] ?? '';
      }
    } catch (e) {
      debugPrint(
        "LOAD BANNER ERROR: $e",
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? xFile =
          await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (xFile == null) return;

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
        width: 1400,
      );

      final compressed =
          img.encodeJpg(
        resized,
        quality: 75,
      );

      setState(() {
        imageBase64 =
            base64Encode(compressed);
      });

      final sizeKb =
          compressed.length / 1024;

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "Banner berhasil dipilih (${sizeKb.toStringAsFixed(0)} KB)",
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

  Future<void> saveBanner() async {
    if (titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Judul banner wajib diisi",
          ),
        ),
      );
      return;
    }

    if (imageBase64.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Pilih gambar banner terlebih dahulu",
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('banners')
          .doc('main_banner')
          .set({
        "title":
            titleC.text.trim(),
        "imageBase64":
            imageBase64,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Banner berhasil diperbarui",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Gagal menyimpan banner: $e",
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xfff5f5f5),

      appBar: AppBar(
        backgroundColor:
            Colors.black,

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Edit Banner",
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 1000,
            margin:
                const EdgeInsets.all(30),
            padding:
                const EdgeInsets.all(30),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Judul Banner",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: titleC,
                  decoration:
                      InputDecoration(
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Preview Banner",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  height: 320,
                  width: double.infinity,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                    border: Border.all(
                      color:
                          Colors.grey.shade300,
                    ),
                  ),
                  child: imageBase64.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada banner",
                          ),
                        )
                      : ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                          child:
                              Image.memory(
                            base64Decode(
                              imageBase64,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.amber,
                        foregroundColor:
                            Colors.black,
                      ),
                      onPressed:
                          pickImage,
                      icon:
                          const Icon(
                        Icons.image,
                      ),
                      label: const Text(
                        "Pilih Banner",
                      ),
                    ),

                    const SizedBox(
                        width: 15),

                    Expanded(
                      child:
                          ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.black,
                          foregroundColor:
                              Colors.white,
                          minimumSize:
                              const Size(
                            0,
                            50,
                          ),
                        ),
                        onPressed: saving
                            ? null
                            : saveBanner,
                        icon:
                            const Icon(
                          Icons.save,
                        ),
                        label: Text(
                          saving
                              ? "Menyimpan..."
                              : "Simpan Banner",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}