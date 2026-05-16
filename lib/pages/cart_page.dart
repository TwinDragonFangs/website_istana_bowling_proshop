import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../services/whatsapp_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            WhatsAppService.checkout(
              cart.items,
              cart.totalPrice,
            );
          },
          child: const Text('Checkout via WhatsApp'),
        ),
      ),
    );
  }
}
