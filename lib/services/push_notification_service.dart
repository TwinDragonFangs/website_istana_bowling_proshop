import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notification_helper.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  Future<void> init() async {

    await _messaging.requestPermission();

    String? token =
        await _messaging.getToken();

    print("FCM TOKEN: $token");

    if (token != null) {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
        });
      }
    }

    // ===== FOREGROUND NOTIFICATION =====
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {

        print(
          "Foreground notification: "
          "${message.notification?.title}",
        );

        NotificationHelper.showNotification(
          title:
              message.notification?.title ??
              "Notifikasi",

          body:
              message.notification?.body ??
              "",
        );
      },
    );

    // ===== SAAT NOTIF DITEKAN =====
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print(
          "Notification clicked",
        );
      },
    );
  }
}