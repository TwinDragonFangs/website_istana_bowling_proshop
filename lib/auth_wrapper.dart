import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/user/home_page.dart';
import 'pages/admin/admin_dashboard.dart';
import 'pages/auth/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // ================= LOADING =================
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // ================= NOT LOGGED IN =================
        if (user == null) {
          return const LoginPage();
        }

        // ================= ROLE CHECK =================
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, snap) {

            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snap.data!.data() as Map<String, dynamic>?;
            final role = data?['role'] ?? 'user';

            // ================= ROUTING ONLY =================
            if (role == 'admin') {
              return const AdminDashboard();
            }

            return const HomePage();
          },
        );
      },
    );
  }
}