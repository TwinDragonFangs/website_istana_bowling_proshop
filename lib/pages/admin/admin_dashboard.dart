import 'package:flutter/material.dart';

import 'add_product_page.dart';

class AdminDashboard
    extends StatelessWidget {

  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddProductPage(),
            ),
          );
        },

        child: const Icon(Icons.add),
      ),

      body: const Center(
        child: Text(
          "Admin Panel",
        ),
      ),
    );
  }
}