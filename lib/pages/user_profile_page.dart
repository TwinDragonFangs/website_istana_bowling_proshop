import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import './auth/login_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() =>
      _UserProfilePageState();
}

class _UserProfilePageState
    extends State<UserProfilePage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _addressC = TextEditingController();

  String profileImageBase64 = "";

  final ImagePicker _picker = ImagePicker();

  bool loading = true;

  final uid =
      FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data();

    if (data != null) {
      _nameC.text = data['name'] ?? '';
      _emailC.text = data['email'] ?? '';
      _phoneC.text = data['phone'] ?? '';
      _addressC.text = data['address'] ?? '';

      profileImageBase64 =
          data['profileImage'] ?? '';
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> pickProfileImage() async {
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
        width: 600,
      );

      final compressed =
          img.encodeJpg(
        resized,
        quality: 70,
      );

      setState(() {
        profileImageBase64 =
            base64Encode(compressed);
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Foto berhasil dipilih (${(compressed.length / 1024).toStringAsFixed(0)} KB)",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Gagal memilih foto: $e",
          ),
        ),
      );
    }
  }

  Future<void> saveProfile() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final newEmail =
          _emailC.text.trim().toLowerCase();

      if (newEmail != user.email) {

        await user.verifyBeforeUpdateEmail(
          newEmail,
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Email verifikasi telah dikirim. Cek inbox email baru Anda.",
            ),
          ),
        );
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'name': _nameC.text.trim(),
        'email': newEmail,
        'phone': _phoneC.text.trim(),
        'address': _addressC.text.trim(),
        'profileImage': profileImageBase64,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Profil berhasil diperbarui",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
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
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Center(
            child: Stack(
              children: [

                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: profileImageBase64.isNotEmpty
                        ? Image.memory(
                            base64Decode(
                              profileImageBase64,
                            ),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: pickProfileImage,
                    child: Container(
                      padding:
                          const EdgeInsets.all(8),
                      decoration:
                          const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          TextField(
            controller: _nameC,
            decoration:
                const InputDecoration(
              labelText: "Nama",
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _emailC,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _addressC,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Alamat",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _phoneC,
            decoration:
                const InputDecoration(
              labelText: "Nomor HP",
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 25),

          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color.fromARGB(255, 255, 223, 223),
            ),
            onPressed: saveProfile,
            child: const Text(
              "Simpan Perubahan",
            ),
          ),
          const SizedBox(height: 15),

            OutlinedButton.icon(
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              label: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.red,
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text(
                        "Yakin ingin keluar dari akun ini?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text("Batal"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}