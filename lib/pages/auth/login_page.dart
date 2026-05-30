import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/admin_dashboard.dart';
import '../user/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();

  bool loading = false;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // =========================
  // EMAIL LOGIN
  // =========================
  Future<void> login() async {
    try {
      setState(() => loading = true);

      final cred = await _auth.signInWithEmailAndPassword(
        email: _emailC.text.trim(),
        password: _passC.text.trim(),
      );

      final uid = cred.user!.uid;

      final doc =
          await _db.collection('users').doc(uid).get();

      final role = doc['role'];

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login gagal')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // =========================
  // GOOGLE LOGIN (WEB FIX)
  // =========================
  Future<void> loginWithGoogle() async {
    try {
      setState(() => loading = true);

      print("STEP 1 : Mulai Google Login");

      final GoogleAuthProvider googleProvider =
          GoogleAuthProvider();

      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });

      final userCred =
          await FirebaseAuth.instance
              .signInWithPopup(googleProvider);

      print("STEP 2 : Login Google Berhasil");

      final user = userCred.user!;

      print("UID : ${user.uid}");
      print("EMAIL : ${user.email}");

      final docRef =
          _db.collection('users').doc(user.uid);

      print("STEP 3 : Coba akses Firestore");

      DocumentSnapshot doc;

      try {
        doc = await docRef.get();

        print("STEP 4 : Firestore Connected");
        print("Doc Exists : ${doc.exists}");
      } catch (e) {
        print("FIRESTORE ERROR");
        print(e);

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                "Firestore Error : $e",
              ),
            ),
          );
        }

        return;
      }

      if (!doc.exists) {
        print("STEP 5 : User Baru");

        await docRef.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'role': 'user',
          'createdAt':
              FieldValue.serverTimestamp(),
        });

        print("User berhasil dibuat");
      }

      final updatedDoc =
          await docRef.get();

      final role =
          updatedDoc['role'] ?? 'user';

      print("ROLE : $role");

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const AdminDashboard(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
        );
      }
    } catch (e, stack) {
      print("GOOGLE LOGIN ERROR");
      print(e);
      print(stack);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "Google login gagal: $e",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo-ibp.png',
                height: 180,
              ),

              const SizedBox(height: 15),

              const Text(
                "ISTANA PROSHOP",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Login untuk melanjutkan",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _emailC,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passC,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loginWithGoogle,
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 30,
                ),
                label: const Text(
                  "Login dengan Google",
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text("Belum punya akun? Daftar di sini"),
              ),
            ],
          ),
        ),
      ),
    )
  );
  }
}