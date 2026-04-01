import 'package:flutter/foundation.dart';
import '../utils/appwrite_service.dart';
import 'models.dart';
import 'algerian_wilayas.dart';

class HomeProvider extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedWilaya = defaultWilaya;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedWilaya => _selectedWilaya;

  HomeProvider() {
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final docs = await AppwriteService.getRestaurants();
      _restaurants = docs.map((doc) {
        final data = doc.data;
        // Map Appwrite document to Restaurant model
        return Restaurant.fromAppwrite(data, doc.$id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');
      _restaurants = []; // Fallback to empty list
    }

    _isLoading = false;
    notifyListeners();
  }

  void refresh() {
    fetchRestaurants();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setWilaya(String wilaya) {
    _selectedWilaya = wilaya;
    notifyListeners();
  }

  List<Restaurant> get filteredRestaurants {
    return _restaurants.where((r) {
      final matchCat =
          _selectedCategory == 'All' || r.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.nameAr.contains(_searchQuery);
      // In a real app, you would also filter by Wilaya if the field exists in the model/DB
      return matchCat && matchSearch;
    }).toList();
  }
}
