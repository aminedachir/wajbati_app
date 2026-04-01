import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../utils/appwrite_service.dart';
import '../../models/models.dart';

class OrdersController extends GetxController {
  var orders = <AppOrder>[].obs;
  var loading = false.obs;

  Future<void> loadOrders(String userId) async {
    loading.value = true;
    try {
      final docs = await AppwriteService.getOrders(userId);
      // Ensure your AppOrder model can handle the 'subtotal' field from the map
      orders.value =
          docs.map((doc) => AppOrder.fromMap(doc.data, doc.$id)).toList();
    } catch (e) {
      debugPrint('Load orders error: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> placeOrder(Map<String, dynamic> orderData, String userId) async {
    try {
      loading.value = true; // Show loading while placing order

      orderData['userId'] = userId;

       if (!orderData.containsKey('subtotal')) {
        int total = orderData['totalAmount'] ?? 0;
        int delivery = orderData['deliveryFee'] ?? 0;
        orderData['subtotal'] = total - delivery;
      }

      // 3. Save to Appwrite
      await AppwriteService.saveOrder(orderData);

      // 4. Refresh the orders list for the user
      await loadOrders(userId);

      Get.back(); // Close the checkout/cart screen
      Get.snackbar(
        'Success',
        'Order placed successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place order: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
    }
  }
}