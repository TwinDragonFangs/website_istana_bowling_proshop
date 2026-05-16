import 'product.dart';

class CartItem {
  final Product product;
  final String selectedVariant;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedVariant,
    required this.quantity,
  });
}