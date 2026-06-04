import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';
import 'deep_link_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission();

    // ================= FOREGROUND =================
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? "Notifikasi";
      final body = message.notification?.body ?? "";

      NotificationService.show(
        title: title,
        body: body,
      );
    });

    // ================= CLICK NOTIFICATION =================
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      DeepLinkService.handle(message.data);
    });

    // ================= KILLED STATE =================
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      DeepLinkService.handle(initialMessage.data);
    }
  }
}