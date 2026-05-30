import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'providers/cart_provider.dart';

import 'pages/auth/login_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  theme: ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFE53935),
  ),

  scaffoldBackgroundColor:
      const Color(0xFFF5F7FA),

  inputDecorationTheme:
      const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
  ),
);
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(

      providers: [

        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],

      child: MaterialApp(

        debugShowCheckedModeBanner: false,

        title: 'Istana Bowling Proshop',

        theme: ThemeData(

          primarySwatch: Colors.red,

          scaffoldBackgroundColor:
              Colors.grey.shade100,

          useMaterial3: true,
        ),

        home: const LoginPage(),
      ),
    );
  }
}