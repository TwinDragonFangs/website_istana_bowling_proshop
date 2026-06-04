import 'notification_service.dart';
import 'push_notification_service.dart';

class AppBootstrap {
  static Future<void> init() async {
    await NotificationService.init();
    await PushNotificationService.init();
  }
}