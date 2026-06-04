import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:html' as html;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) {
      await _initWeb();
    } else {
      await _initAndroid();
    }
  }

  // ================= ANDROID =================
  static Future<void> _initAndroid() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      const InitializationSettings(android: android),
    );
  }

  static void show({
    required String title,
    required String body,
  }) {
    if (kIsWeb) {
      _showWeb(title, body);
    } else {
      _showAndroid(title, body);
    }
  }

  // ================= ANDROID NOTIF =================
  static void _showAndroid(String title, String body) {
    _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ================= WEB NOTIF =================
  static void _showWeb(String title, String body) {
    // simple browser notification fallback
    // (tanpa dependency file tambahan)
    if (kIsWeb) {
      if (html.Notification.supported &&
          html.Notification.permission == 'granted') {
        html.Notification(title, body: body);
      }
    }
  }

  // ================= WEB INIT =================
  static Future<void> _initWeb() async {
    if (html.Notification.supported) {
      await html.Notification.requestPermission();
    }
  }
}