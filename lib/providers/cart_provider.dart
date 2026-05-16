import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(
    Product product,
    String variant,
    int qty,
  ) {
    final index = _items.indexWhere(
      (e) =>
          e.product.id == product.id &&
          e.selectedVariant == variant,
    );

    if (index >= 0) {
      _items[index].quantity += qty;
    } else {
      _items.add(
        CartItem(
          product: product,
          selectedVariant: variant,
          quantity: qty,
        ),
      );
    }

    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  int get totalPrice {
    return _items.fold(
      0,
      (sum, item) =>
          sum + (item.product.price * item.quantity),
    );
  }
}