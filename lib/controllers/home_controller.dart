import 'package:get/get.dart';
import '../../utils/appwrite_service.dart';
import '../../models/algerian_wilayas.dart';
import '../../models/models.dart';

class HomeController extends GetxController {
  var restaurants = <Restaurant>[].obs;
  var selectedCategory = 'All'.obs;
  var searchQuery = ''.obs;
  var selectedWilaya = 'Algiers'.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRestaurants();
  }

  List<Restaurant> get filteredRestaurants => restaurants.where((r) {
        final matchCat = selectedCategory.value == 'All' ||
            r.category == selectedCategory.value;
        final matchSearch = searchQuery.value.isEmpty ||
            r.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            r.nameAr.contains(searchQuery.value);
        final matchWilaya = selectedWilaya.value == 'Algiers' ||
            r.address
                .toLowerCase()
                .contains(selectedWilaya.value.toLowerCase());
        return matchCat && matchSearch && matchWilaya;
      }).toList();

  Future<void> loadRestaurants() async {
    isLoading.value = true;
    try {
      final documents = await AppwriteService.getRestaurants();
      restaurants.value = documents
          .map((doc) => Restaurant.fromAppwrite(doc.data, doc.$id))
          .toList();
    } catch (e) {
      print('DB error: $e');
      restaurants.value = [];
    }
    isLoading.value = false;
  }

  void setCategory(String category) => selectedCategory.value = category;
  void setSearchQuery(String query) => searchQuery.value = query;
  void setWilaya(String wilaya) {
    selectedWilaya.value = wilaya;
  }

  void refresh() => loadRestaurants();
}
