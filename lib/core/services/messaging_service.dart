import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService(FirebaseMessaging.instance);
});

class MessagingService {
  const MessagingService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<String?> initialize() async {
    try {
      await Firebase.initializeApp();
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return null;
      }

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      return _messaging.getToken();
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('FCM init skipped: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    } catch (error, stackTrace) {
      debugPrint('FCM init skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> subscribeRestaurant(String restaurantId) async {
    try {
      await _messaging.subscribeToTopic('restaurant_$restaurantId');
    } catch (error) {
      debugPrint('FCM subscribe skipped: $error');
    }
  }

  Future<void> unsubscribeRestaurant(String restaurantId) async {
    try {
      await _messaging.unsubscribeFromTopic('restaurant_$restaurantId');
    } catch (error) {
      debugPrint('FCM unsubscribe skipped: $error');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Restaurant push: ${message.messageId ?? message.data}');
  }
}
