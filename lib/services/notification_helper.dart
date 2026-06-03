import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    await plugin.initialize(
      const InitializationSettings(
        android: android,
      ),
    );
  }

  static Future showNotification({
    required String title,
    required String body,
  }) async {
    await plugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'orders_channel',
          'Orders Notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}