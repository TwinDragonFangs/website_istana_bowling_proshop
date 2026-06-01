import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../auth/login_page.dart';
import 'add_product_page.dart';
import 'manage_products_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() =>
      _AdminProfilePageState();
}

class _AdminProfilePageState
    extends State<AdminProfilePage> {
  final _nameC = TextEditingController();

  bool loading = true;

  final uid =
      FirebaseAuth.instance.currentUser!.uid;

  String email = '';

  int totalProducts = 0;
  int totalBalls = 0;
  int totalShoes = 0;
  int totalBags = 0;
  int totalAccessories = 0;

  @override
  void initState() {
    super.initState();
    loadAdmin();
  }

  Future<void> loadAdmin() async {
    try {
      final adminDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

      final userData = adminDoc.data();

      if (userData != null) {
        _nameC.text = userData['name'] ?? '';
        email = userData['email'] ?? '';
      }

      final products =
          await FirebaseFirestore.instance
              .collection('products')
              .get();

      totalProducts = products.docs.length;

      totalBalls = 0;
      totalShoes = 0;
      totalBags = 0;
      totalAccessories = 0;

      for (var doc in products.docs) {
        final data =
            doc.data() as Map<String, dynamic>;

        final category =
            (data['category'] ?? '')
                .toString()
                .trim()
                .toLowerCase();

        if (category.contains('ball')) {
          totalBalls++;
        }

        if (category.contains('shoe')) {
          totalShoes++;
        }

        if (category.contains('bag')) {
          totalBags++;
        }

        if (category.contains('access')) {
          totalAccessories++;
        }
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint(
        "ERROR ADMIN PROFILE: $e",
      );

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> saveAdmin() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'name': _nameC.text.trim(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text("Profil berhasil diperbarui"),
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
    Widget icon,
  ) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.amber.shade100,
            child: icon,
          ),

          const SizedBox(height: 15),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(title),
        ],
      ),
    );
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
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Profil Admin",
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
            width: 1100,
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
                  color: Colors.black12,
                  blurRadius: 10,
                ),
              ],
            ),

            child: Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor:
                      Colors.amber.shade100,
                  child: const FaIcon(
                    FontAwesomeIcons.userTie,
                    color: Colors.amber,
                    size: 60,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _nameC.text.isEmpty
                      ? "Administrator"
                      : _nameC.text,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    statCard(
                      "Total Produk",
                      totalProducts.toString(),
                      const Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.amber,
                        size: 38,
                      ),
                    ),

                    statCard(
                      "Ball",
                      totalBalls.toString(),
                      const FaIcon(
                        FontAwesomeIcons.bowlingBall,
                        color: Colors.amber,
                        size: 38,
                      ),
                    ),

                    statCard(
                      "Shoes",
                      totalShoes.toString(),
                      const FaIcon(
                        FontAwesomeIcons.shoePrints,
                        color: Colors.amber,
                        size: 38,
                      ),
                    ),

                    statCard(
                      "Bag",
                      totalBags.toString(),
                      const FaIcon(
                        FontAwesomeIcons.briefcase,
                        color: Colors.amber,
                        size: 38,
                      ),
                    ),

                    statCard(
                      "Accessories",
                      totalAccessories.toString(),
                      const FaIcon(
                        FontAwesomeIcons.gem,
                        color: Colors.amber,
                        size: 38,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: _nameC,
                  decoration:
                      InputDecoration(
                    labelText:
                        "Nama Admin",
                    prefixIcon:
                        const Icon(
                      Icons.person,
                    ),
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

                Row(
                  children: [
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
                            55,
                          ),
                        ),
                        onPressed:
                            saveAdmin,
                        icon:
                            const Icon(
                          Icons.save,
                        ),
                        label:
                            const Text(
                          "Update Profil",
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child:
                          ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.amber,
                          foregroundColor:
                              Colors.black,
                          minimumSize:
                              const Size(
                            0,
                            55,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AddProductPage(),
                            ),
                          );
                        },
                        icon:
                            const Icon(
                          Icons.add,
                        ),
                        label:
                            const Text(
                          "Tambah Produk",
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child:
                          ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue,
                          foregroundColor:
                              Colors.white,
                          minimumSize:
                              const Size(
                            0,
                            55,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ManageProductsPage(),
                            ),
                          );
                        },
                        icon:
                            const Icon(
                          Icons.edit,
                        ),
                        label:
                            const Text(
                          "Kelola Produk",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child:
                      ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,
                      foregroundColor:
                          Colors.white,
                      minimumSize:
                          const Size(
                        0,
                        55,
                      ),
                    ),
                    onPressed: () async {
                      bool? logout =
                          await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                            "Yakin ingin keluar dari akun admin?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text("Batal"),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text("Logout"),
                            ),
                          ],
                        ),
                      );

                      if (logout != true) return;

                      await FirebaseAuth.instance.signOut();

                      if (!mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: const Text(
                      "Logout",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}