import 'package:flutter/foundation.dart';
import 'appwrite_service.dart';
import 'notification_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // 1. Appwrite client
    try {
      final client = AppwriteService.client;
      debugPrint('✅ Appwrite initialized: ${client.config['project']}');
    } catch (e) {
      debugPrint('❌ Appwrite init error: $e');
      rethrow;
    }

    // 2. Local notifications (flutter_local_notifications)
    //    Remote push: configure APNs/FCM provider in Appwrite Console → Messaging
    //    then call NotificationService.registerPushTarget() after login.
    try {
      await NotificationService.initialize();
      debugPrint('✅ Notifications initialized');
    } catch (e) {
      debugPrint('⚠️ Notification init error (non-fatal): $e');
    }
  }
}
