import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'appwrite_service.dart';
import 'environment.dart';
import 'notification_service.dart';

/// Appwrite Realtime — live order status updates.
///
/// CLIENT side (TrackOrderScreen):
///   RealtimeService.watchOrder(orderId, onUpdate: (status, data) { setState... });
///   // dispose:
///   RealtimeService.cancelOrderWatch();
///
/// DASHBOARD side (RestaurantDashboardScreen):
///   RealtimeService.watchRestaurantOrders(restaurantId, onEvent: (type, data) { setState... });
///   // dispose:
///   RealtimeService.cancelRestaurantWatch();
class RealtimeService {
  static Realtime? _realtime;
  static RealtimeSubscription? _orderSub;
  static RealtimeSubscription? _restaurantSub;

  static Realtime get _rt =>
      _realtime ??= Realtime(AppwriteService.client);

  // ── Watch a single order (client side) ───────────────────────────────────
  static void watchOrder(
    String orderId, {
    required void Function(String newStatus, Map<String, dynamic> data) onUpdate,
  }) {
    _orderSub?.close();

    final channel =
        'databases.${Environment.appwriteDatabaseId}'
        '.collections.${Environment.appwriteOrdersCollectionId}'
        '.documents.$orderId';

    _orderSub = _rt.subscribe([channel]);

    _orderSub!.stream.listen(
      (RealtimeMessage event) {
        if (event.payload.isEmpty) return;
        final data = Map<String, dynamic>.from(event.payload);
        final newStatus = (data['status'] as String?) ?? '';
        if (newStatus.isEmpty) return;

        debugPrint('📡 Order $orderId → $newStatus');
        onUpdate(newStatus, data);

        // Fire local notification so user sees it even if app is in foreground
        final orderNumber = (data['orderNumber'] as String?) ?? '';
        NotificationService.notifyOrderStatus(
          orderNumber: orderNumber,
          status: newStatus,
          orderId: orderId,
        );
      },
      onError: (e) => debugPrint('Realtime order error: $e'),
    );

    debugPrint('📡 Subscribed to order: $orderId');
  }

  // ── Watch all orders for a restaurant (dashboard) ────────────────────────
  static void watchRestaurantOrders(
    String restaurantId, {
    String? restaurantName,
    required void Function(String eventType, Map<String, dynamic> data) onEvent,
  }) {
    _restaurantSub?.close();

    // Subscribe to the entire orders collection;
    // filter by restaurantId in the callback (Appwrite doesn't support
    // server-side Realtime filtering by field yet).
    final channel =
        'databases.${Environment.appwriteDatabaseId}'
        '.collections.${Environment.appwriteOrdersCollectionId}'
        '.documents';

    _restaurantSub = _rt.subscribe([channel]);

    _restaurantSub!.stream.listen(
      (RealtimeMessage event) {
        if (event.payload.isEmpty) return;
        final data = Map<String, dynamic>.from(event.payload);

        // Ignore events for other restaurants
        final isMatchId = data['restaurantId'] == restaurantId;
        final isMatchName = restaurantName != null && data['restaurantName'] == restaurantName;
        if (!isMatchId && !isMatchName) return;

        final eventType =
            event.events.isNotEmpty ? event.events.first : 'unknown';
        debugPrint('📡 Dashboard event [$eventType] for $restaurantId');
        onEvent(eventType, data);
      },
      onError: (e) => debugPrint('Realtime restaurant error: $e'),
    );

    debugPrint('📡 Subscribed to orders for restaurant: $restaurantId');
  }

  // ── Cancel ────────────────────────────────────────────────────────────────
  static void cancelOrderWatch() {
    _orderSub?.close();
    _orderSub = null;
  }

  static void cancelRestaurantWatch() {
    _restaurantSub?.close();
    _restaurantSub = null;
  }

  static void cancelAll() {
    cancelOrderWatch();
    cancelRestaurantWatch();
  }
}
