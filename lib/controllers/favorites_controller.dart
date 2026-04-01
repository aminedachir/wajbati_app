import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../utils/appwrite_service.dart';
import '../controllers/auth_controller.dart';

class FavoritesController extends GetxController {
  var favorites = <String>{}.obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      loadFavorites();
    }
  }

  Future<void> loadFavorites() async {
    loading.value = true;
    try {
      final user = await AppwriteService.getCurrentUser();
      if (user != null) {
        final docs = await AppwriteService.getFavorites(user.$id);
        favorites.value =
            docs.map((doc) => doc.data['restaurantId'] as String).toSet();
      }
    } catch (e) {
      print('Load favorites error: $e');
    } finally {
      loading.value = false;
    }
  }

  bool isFavorite(String id) => favorites.contains(id);

  void toggle(String id) async {
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn && auth.user.value != null) {
      loading.value = true;
      try {
        final userId = auth.user.value!.uid;
        if (favorites.contains(id)) {
          await AppwriteService.removeFavorite(userId, id);
          favorites.remove(id);
        } else {
          await AppwriteService.addFavorite(userId, id);
          favorites.add(id);
        }
      } catch (e) {
        print('Toggle favorite error: $e');
      } finally {
        loading.value = false;
      }
    } else {
      // Guest - local only
      if (favorites.contains(id)) {
        favorites.remove(id);
      } else {
        favorites.add(id);
      }
    }
  }
}
