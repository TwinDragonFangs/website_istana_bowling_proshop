import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // =====================
  // ADD TO CART
  // =====================

  void addToCart(
    Product product,
    String variant,
    int qty,
  ) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedVariant == variant,
    );

    if (index != -1) {
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

  // =====================
  // REMOVE
  // =====================

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  // =====================
  // QTY +
  // =====================

  void increaseQty(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  // =====================
  // QTY -
  // =====================

  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
    }
  }

  // =====================
  // CHECKBOX
  // =====================

  void toggleSelected(CartItem item) {
    item.selected = !item.selected;
    notifyListeners();
  }

  // =====================
  // CLEAR CART
  // =====================

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void clearSelected() {
    items.removeWhere((item) => item.selected == true);
      notifyListeners();
  }

  // =====================
  // TOTAL ITEM
  // =====================

  int get totalItems {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  // =====================
  // TOTAL PRICE
  // =====================

  int get totalPrice {
  return _items
      .where((item) => item.selected)
      .fold(
        0,
        (sum, item) =>
            sum +
            (item.product.price * item.quantity),
      );
}

  // =====================
  // SELECTED ITEMS
  // =====================

  List<CartItem> get selectedItems {
    return _items
        .where(
          (item) => item.selected,
        )
        .toList();
  }
}