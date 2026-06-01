import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/admin/edit_banner_page.dart';

class BannerSection extends StatefulWidget {
  final bool isAdmin;

  const BannerSection({
    super.key,
    this.isAdmin = false,
  });

  @override
  State<BannerSection> createState() =>
      _BannerSectionState();
}

class _BannerSectionState
    extends State<BannerSection> {
  Future<DocumentSnapshot>? bannerFuture;

  @override
  void initState() {
    super.initState();
    loadBanner();
  }

  void loadBanner() {
    bannerFuture = FirebaseFirestore.instance
        .collection('banners')
        .doc('main_banner')
        .get();
  }

  Future<void> openEditBanner() async {
    debugPrint("BANNER DIKLIK");

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditBannerPage(),
      ),
    );

    setState(() {
      loadBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: bannerFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 320,
            child: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.data!.exists) {
          return GestureDetector(
            onTap: widget.isAdmin
                ? openEditBanner
                : null,
            child: Container(
              height: 320,
              width: double.infinity,
              margin:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    const Icon(
                      Icons.image,
                      size: 60,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Banner belum tersedia",
                    ),
                    if (widget.isAdmin)
                      const Padding(
                        padding:
                            EdgeInsets.only(
                          top: 10,
                        ),
                        child: Text(
                          "Klik untuk menambahkan banner",
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        final data =
            snapshot.data!.data()
                as Map<String, dynamic>;

        final imageBase64 =
            data['imageBase64'] ?? '';

        final title =
            data['title'] ??
                "ISTANA BOWLING PROSHOP";

        return GestureDetector(
          behavior:
              HitTestBehavior.opaque,
          onTap: widget.isAdmin
              ? openEditBanner
              : null,
          child: Container(
            height: 320,
            width: double.infinity,
            margin:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  child: imageBase64.isEmpty
                      ? Container(
                          color:
                              Colors.grey,
                        )
                      : Image.memory(
                          base64Decode(
                            imageBase64,
                          ),
                          width:
                              double.infinity,
                          height:
                              double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),

                Container(
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                    color: Colors.black
                        .withOpacity(
                      0.45,
                    ),
                  ),
                ),

                Center(
                  child: Text(
                    title,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 42,
                      fontWeight:
                          FontWeight
                              .bold,
                      letterSpacing:
                          2,
                    ),
                  ),
                ),

                if (widget.isAdmin)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color.fromARGB(255, 255, 255, 255),
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color:
                                Colors.black,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Klik untuk Edit Banner",
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color: Colors
                                  .black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}