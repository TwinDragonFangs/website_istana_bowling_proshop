import 'package:flutter/material.dart';

class DeepLinkService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void handle(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'order':
        navigatorKey.currentState?.pushNamed(
          '/order-detail',
          arguments: data['orderId'],
        );
        break;

      case 'chat':
        navigatorKey.currentState?.pushNamed(
          '/chat',
          arguments: data['roomId'],
        );
        break;

      case 'thread':
        navigatorKey.currentState?.pushNamed(
          '/thread',
          arguments: data['threadId'],
        );
        break;

      default:
        navigatorKey.currentState?.pushNamed('/');
    }
  }
}