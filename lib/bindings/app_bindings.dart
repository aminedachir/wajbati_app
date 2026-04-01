import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/theme_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(AuthController());
    Get.put(CartController());
    Get.put(FavoritesController());
    Get.put(OrdersController());
    Get.put(ThemeController());
  }
}
