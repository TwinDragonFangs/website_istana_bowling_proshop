import 'dart:html' as html;

import '../models/cart_item.dart';

class WhatsAppService {
  static void checkout(
    List<CartItem> items,
    int total,
  ) {
    String message =
        "Halo Istana Bowling Proshop!\n\n";

    message +=
        "Saya ingin memesan produk berikut:\n\n";

    for (var item in items) {
      message +=
          "• ${item.product.name}\n"
          "  Variant : ${item.selectedVariant}\n"
          "  Qty : ${item.quantity}\n"
          "  Harga : Rp ${item.product.price}\n\n";
    }

    message +=
        "====================\n"
        "TOTAL : Rp ${total.toStringAsFixed(0)}\n\n"
        "Mohon konfirmasi pesanan saya.\nTerima kasih.";

    final encoded =
        Uri.encodeComponent(message);

    final url =
        "https://wa.me/6282172041712?text=$encoded";

    html.window.open(url, "_blank");
  }
}