import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/user/home_page.dart';
import 'pages/admin/admin_dashboard.dart';
import 'pages/auth/login_page.dart';

import 'services/push_notification_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {

  bool _fcmInitialized = false;

  void _initFCMOnce() {
    if (_fcmInitialized) return;

    PushNotificationService().init();
    _fcmInitialized = true;
  }

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

        // ================= NOT LOGIN =================
        if (user == null) {
          return const LoginPage();
        }

        // ================= LOGIN + ROLE CHECK =================
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

            final data =
                snap.data!.data() as Map<String, dynamic>?;

            final role = data?['role'] ?? 'user';

            // ================= INIT FCM ONCE =================
            _initFCMOnce();

            // ================= ROUTING =================
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