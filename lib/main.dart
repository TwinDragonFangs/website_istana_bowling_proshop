import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'providers/cart_provider.dart';

import 'pages/auth/login_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

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