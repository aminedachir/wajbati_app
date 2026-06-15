import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'appwrite_service.dart';

/// Handles:
/// 1. Local in-app notifications (flutter_local_notifications)
/// 2. Saving the device push target to Appwrite Messaging
///    so Appwrite can send pushes via its Messaging API
///    (configure APNs/FCM credentials in Appwrite Console → Messaging)
class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'wajbati_orders',
    'طلبات وجبتي',
    description: 'إشعارات حالة الطلبات والتوصيل',
    importance: Importance.max,
    playSound: true,
  );

  // ── Initialize ────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        // payload = orderId — navigate to TrackOrderScreen here if needed
        debugPrint('🔔 Notification tapped, orderId: ${details.payload}');
      },
    );

    // Create Android channel
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    debugPrint('✅ Local notifications initialized');
  }

  // ── Show a local notification ─────────────────────────────────────────────
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _local.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // ── Trigger the right message based on order status ───────────────────────
  static Future<void> notifyOrderStatus({
    required String orderNumber,
    required String status,
    String? orderId,
  }) async {
    final (title, body) = _statusToMessage(orderNumber, status);
    await show(
      title: title,
      body: body,
      payload: orderId,
      id: orderId.hashCode.abs(),
    );
  }

  static (String, String) _statusToMessage(String num, String status) =>
      switch (status) {
        'مقبول' || 'جاري التحضير' => (
            '✅ تم قبول طلبك $num',
            'المطعم بدأ بتحضير وجبتك، استعد!'
          ),
        'جاهز للاستلام' => (
            '📦 طلبك جاهز $num',
            'جاري تعيين سائق توصيل لطلبك الآن'
          ),
        'في الطريق' => (
            '🛵 طلبك في الطريق $num',
            'السائق انطلق! تتبع طلبك مباشرة من التطبيق'
          ),
        'تم التسليم' => (
            '🎉 تم توصيل طلبك $num',
            'استمتع بوجبتك! لا تنسى تقييم تجربتك 😊'
          ),
        'ملغى' => (
            '❌ تم إلغاء الطلب $num',
            'تم إلغاء طلبك. تواصل مع الدعم إن احتجت مساعدة'
          ),
        _ => ('وجبتي 🍽️', 'تحديث جديد على طلبك $num'),
      };

  // ── Register device target in Appwrite Messaging ──────────────────────────
  // Call this once after login.
  // In Appwrite Console → Messaging, add APNs (iOS) or FCM (Android) provider,
  // then this saves the device token so Appwrite can send remote pushes.
  static Future<void> registerPushTarget({
    required String userId,
    required String deviceToken,   // APNs token (iOS) or FCM token (Android)
    String provider = 'apns',      // 'apns' | 'fcm' — match your Appwrite provider ID
  }) async {
    if (userId.startsWith('guest_')) return;
    try {
      final account = AppwriteService.account;
      // Creates or updates the push target for this device
      try {
        await account.updatePushTarget(
          targetId: '${userId}_device',
          identifier: deviceToken,
        );
      } catch (_) {
        await account.createPushTarget(
          targetId: '${userId}_device',
          identifier: deviceToken,
          providerId: provider,
        );
      }
      debugPrint('✅ Push target registered for $userId');
    } catch (e) {
      debugPrint('⚠️ Push target registration error (non-fatal): $e');
    }
  }
}
