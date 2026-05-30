import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();

  bool loading = false;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> register() async {
    try {
      setState(() => loading = true);

      final cred = await _auth.createUserWithEmailAndPassword(
        email: _emailC.text.trim(),
        password: _passC.text.trim(),
      );

      final user = cred.user!;

      await _db.collection('users').doc(user.uid).set({
        'name': _nameC.text.trim(),
        'email': _emailC.text.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register berhasil')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Register gagal')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 160,
              ),

              const SizedBox(height: 15),

              const Text(
                "DAFTAR AKUN",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _emailC,
                decoration: const InputDecoration(labelText: 'Email'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passC,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Password'),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loading ? null : register,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "REGISTER",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()),
                  );
                },
                child: const Text("Sudah punya akun? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}