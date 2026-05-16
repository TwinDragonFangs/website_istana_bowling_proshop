import 'dart:html' as html;

import '../models/cart_item.dart';

class WhatsAppService {
  static void checkout(
    List<CartItem> items,
    int total,
  ) {
    String message =
        "Halo Istana Bowling Proshop!\n\n";

    message += "Saya ingin memesan:\n\n";

    for (var item in items) {
      message +=
          "- ${item.product.name} "
          "(${item.selectedVariant}) "
          "x${item.quantity}\n";
    }

    message +=
        "\nTotal: Rp $total"
        "\n\nMohon konfirmasi ya 🙏";

    final encoded =
        Uri.encodeComponent(message);

    final url =
        "https://wa.me/628973021789?text=$encoded";

    html.window.open(url, "_blank");
  }
}