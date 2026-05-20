import 'package:get/get.dart';
import '../../models/models.dart';

class CartController extends GetxController {
  var items = <CartItem>[].obs;
  var restaurant = Rxn<Restaurant>();

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.total);
  double get deliveryFee => restaurant.value?.deliveryFee ?? 0;
  double get total => subtotal + deliveryFee;

  void addItem(MenuItem item, Restaurant resto) {
    if (restaurant.value != null && restaurant.value!.id != resto.id) {
      items.clear();
    }
    restaurant.value = resto;
    final idx = items.indexWhere((ci) => ci.item.id == item.id);
    if (idx >= 0) {
      items[idx].quantity++;
    } else {
      items.add(CartItem(item: item));
    }
  }

  void removeItem(String itemId) {
    items.removeWhere((ci) => ci.item.id == itemId);
    if (items.isEmpty) restaurant.value = null;
  }

  void decreaseItem(String itemId) {
    final idx = items.indexWhere((ci) => ci.item.id == itemId);
    if (idx >= 0) {
      if (items[idx].quantity > 1) {
        items[idx].quantity--;
      } else {
        items.removeAt(idx);
        if (items.isEmpty) restaurant.value = null;
      }
    }
  }

  void clear() {
    items.clear();
    restaurant.value = null;
  }

  int quantityOf(String itemId) {
    final idx = items.indexWhere((ci) => ci.item.id == itemId);
    return idx >= 0 ? items[idx].quantity : 0;
  }
}
