import 'package:cloud_firestore/cloud_firestore.dart';

class OrderNotificationService {

  // ================= USER → ADMIN =================
  static Future notifyAdminNewOrder({
    required String orderId,
    required String customerName,
  }) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add({
      'type': 'order',
      'target': 'admin',
      'title': 'Pesanan Baru',
      'body': '$customerName membuat pesanan baru',
      'orderId': orderId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= ADMIN → USER =================
  static Future notifyUserOrderStatus({
    required String email,
    required String status,
    required String orderId,
  }) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add({
      'type': 'order_status',
      'target': email,
      'title': 'Update Pesanan',
      'body': 'Status pesanan Anda: $status',
      'orderId': orderId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}