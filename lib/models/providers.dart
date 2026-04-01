import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:convert';
import 'dart:math';
import 'package:get_storage/get_storage.dart';
import 'models.dart';
import 'user.dart';
import '../utils/appwrite_service.dart';
import '../utils/environment.dart';

// ─── Auth Provider ────────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isGuest => _user != null && _user!.uid.startsWith('guest_');

  String get displayName => _user?.name ?? 'Guest';
  String get email => _user?.email ?? '';
  String get initials => _user?.initials ?? 'G';

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = await AppwriteService.getCurrentUser();
      if (user != null) {
        _user = AppUser(
          uid: user.$id,
          email: user.email,
          name: user.name.isEmpty ? 'User' : user.name,
        );
      }
    } catch (_) {
      _user = null;
    }
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await AppwriteService.createEmailPasswordSession(email, password);
      await _checkAuthStatus();
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await AppwriteService.createAccount(email, password, name);
      await AppwriteService.createEmailPasswordSession(email, password);
      await _checkAuthStatus();
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    _loading = true;
    notifyListeners();
    final randomNum = Random().nextInt(10000).toString().padLeft(4, '0');
    _user = AppUser(
      uid: 'guest_$randomNum',
      email: '',
      name: 'Guest$randomNum',
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _loading = true;
    notifyListeners();
    try {
      if (!isGuest) {
        await AppwriteService.account.deleteSession(sessionId: 'current');
      }
    } catch (e) {
      debugPrint('Logout error (ignored): $e');
    } finally {
      _user = null;
      _loading = false;
      notifyListeners();
    }
  }
}

// ─── Cart Provider ────────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  Restaurant? _restaurant;
  final GetStorage _prefs = GetStorage();

  String _promoCode = '';
  double _promoDiscount = 0;
  String? _promoError;
  bool _promoApplied = false;

  static const String _cartKey = 'cart_items';
  static const String _restaurantKey = 'cart_restaurant';

  static const Map<String, double> _validCodes = {
    'WAJBATI': 150,
    'WELCOME': 100,
    'SAVE50': 50,
  };

  List<CartItem> get items => _items;
  Restaurant? get restaurant => _restaurant;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.fold(0, (sum, i) => sum + i.total);
  double get deliveryFee => _restaurant?.deliveryFee ?? 0;
  double get promoDiscount => _promoDiscount;
  double get total =>
      (subtotal + deliveryFee - _promoDiscount).clamp(0, double.infinity);
  String get promoCode => _promoCode;
  String? get promoError => _promoError;
  bool get promoApplied => _promoApplied;

  CartProvider() {
    loadCartFromPrefs();
  }

  bool applyPromoCode(String code) {
    final upper = code.trim().toUpperCase();
    if (_validCodes.containsKey(upper)) {
      _promoCode = upper;
      _promoDiscount = _validCodes[upper]!;
      _promoApplied = true;
      _promoError = null;
      notifyListeners();
      return true;
    } else {
      _promoCode = code;
      _promoDiscount = 0;
      _promoApplied = false;
      _promoError = 'Invalid promo code';
      notifyListeners();
      return false;
    }
  }

  void removePromo() {
    _promoCode = '';
    _promoDiscount = 0;
    _promoApplied = false;
    _promoError = null;
    notifyListeners();
  }

  Future<void> loadCartFromPrefs() async {
    try {
      final itemsJson = _prefs.read<List>(_cartKey) ?? [];
      _items.clear();
      _items.addAll(itemsJson.map<CartItem>(
          (json) => CartItem.fromJson(json as Map<String, dynamic>)));
      final restoJson = _prefs.read<Map<String, dynamic>>(_restaurantKey);
      _restaurant = restoJson != null ? Restaurant.fromJson(restoJson) : null;
      notifyListeners();
    } catch (e) {
      debugPrint('Load cart error: $e');
    }
  }

  Future<void> saveCartToPrefs() async {
    try {
      await _prefs.write(_cartKey, _items.map((i) => i.toJson()).toList());
      if (_restaurant != null) {
        await _prefs.write(_restaurantKey, _restaurant!.toJson());
      } else {
        await _prefs.remove(_restaurantKey);
      }
    } catch (e) {
      debugPrint('Save cart error: $e');
    }
  }

  Future<void> addItem(MenuItem item, Restaurant resto) async {
    if (_restaurant != null && _restaurant!.id != resto.id) {
      _items.clear();
      removePromo();
    }
    _restaurant = resto;
    final idx = _items.indexWhere((ci) => ci.item.id == item.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(item: item));
    }
    notifyListeners();
    await saveCartToPrefs();
  }

  Future<void> decreaseItem(String itemId) async {
    final idx = _items.indexWhere((ci) => ci.item.id == itemId);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
        if (_items.isEmpty) _restaurant = null;
      }
      notifyListeners();
      await saveCartToPrefs();
    }
  }

  Future<void> clear() async {
    _items.clear();
    _restaurant = null;
    removePromo();
    notifyListeners();
    await saveCartToPrefs();
  }

  int quantityOf(String itemId) {
    final idx = _items.indexWhere((ci) => ci.item.id == itemId);
    return idx >= 0 ? _items[idx].quantity : 0;
  }
}

// ─── Favorites Provider ───────────────────────────────────────────
class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favorites = {};
  final GetStorage _prefs = GetStorage();
  static const String _favsKey = 'favorite_ids';

  FavoritesProvider() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    try {
      final stored = _prefs.read<List>(_favsKey) ?? [];
      _favorites.addAll(stored.map((e) => e.toString()));
      notifyListeners();
    } catch (e) {
      debugPrint('Load favorites error: $e');
    }
  }

  Future<void> _saveToStorage() async {
    await _prefs.write(_favsKey, _favorites.toList());
  }

  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> toggle(String id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> toggleWithSync(String restaurantId, String? userId) async {
    final willAdd = !_favorites.contains(restaurantId);
    await toggle(restaurantId);
    if (userId == null || userId.startsWith('guest_')) return;
    try {
      if (willAdd) {
        await AppwriteService.addFavorite(userId, restaurantId);
      } else {
        await AppwriteService.removeFavorite(userId, restaurantId);
      }
    } catch (e) {
      debugPrint('Sync favorite error: $e');
    }
  }

  Future<void> loadFromAppwrite(String userId) async {
    if (userId.startsWith('guest_')) return;
    try {
      final docs = await AppwriteService.getFavorites(userId);
      _favorites.clear();
      for (final doc in docs) {
        _favorites.add(doc.data['restaurantId'] as String);
      }
      await _saveToStorage();
      notifyListeners();
    } catch (e) {
      debugPrint('Load favorites Appwrite error: $e');
    }
  }
}

// ─── Orders Provider ─────────────────────────────────────────────
class OrdersProvider extends ChangeNotifier {
  List<AppOrder> _orders = [];
  bool _loading = false;

  List<AppOrder> get orders => _orders;
  bool get loading => _loading;

  Future<void> loadOrders(String userId) async {
    if (userId.startsWith('guest_')) return;

    _loading = true;
    notifyListeners();

    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteOrdersCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
        ],
      );
      _orders = response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        // items is stored as JSON string in Appwrite
        if (data['items'] is String) {
          data['items'] = jsonDecode(data['items'] as String);
        }
        return AppOrder.fromMap(data, doc.$id);
      }).toList();
    } catch (e) {
      debugPrint('Load orders error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<AppOrder?> placeOrder({
    required String userId,
    required CartProvider cart,
  }) async {
    if (cart.restaurant == null || cart.items.isEmpty) return null;

    // Generate order number upfront
    final orderNum = AppOrder.generateOrderNumber();

    final itemsList = cart.items
        .map((ci) => {
              'name': ci.item.name,
              'nameAr': ci.item.nameAr,
              'quantity': ci.quantity,
              'price': ci.item.price,
            })
        .toList();

    // Guest: in-memory only
    if (userId.startsWith('guest_')) {
      final mockOrder = AppOrder(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        orderNumber: orderNum,
        restaurantName: cart.restaurant!.name,
        restaurantId: cart.restaurant!.id,
        items: cart.items
            .map((ci) => OrderItem(
                  name: ci.item.name,
                  nameAr: ci.item.nameAr,
                  quantity: ci.quantity,
                  price: ci.item.price,
                ))
            .toList(),
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        discount: cart.promoDiscount,
        total: cart.total,
        status: 'Preparing',
        createdAt: DateTime.now(),
      );
      _orders.insert(0, mockOrder);
      notifyListeners();
      return mockOrder;
    }

    // Real user: save to Appwrite
    // Note: If 'subtotal' is missing in Appwrite schema, we remove it from orderData
    // but keep it in our local AppOrder model for display.
    final orderData = <String, Object>{
      'userId': userId,
      'orderNumber': orderNum,
      'restaurantName': cart.restaurant!.name,
      'restaurantId': cart.restaurant!.id,
      'items': jsonEncode(itemsList),
      'subtotal': cart.subtotal,
      'deliveryFee': cart.deliveryFee,
      'discount': cart.promoDiscount,
      'total': cart.total,
      'status': 'Preparing',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final response = await AppwriteService.databases.createDocument(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteOrdersCollectionId,
        documentId: ID.unique(),
        data: orderData,
      );

      final responseData = Map<String, dynamic>.from(response.data);
      if (responseData['items'] is String) {
        responseData['items'] = jsonDecode(responseData['items'] as String);
      }

      // Inject subtotal back for local model if Appwrite doesn't store it
      if (!responseData.containsKey('subtotal')) {
        responseData['subtotal'] = cart.subtotal;
      }

      final savedOrder = AppOrder.fromMap(responseData, response.$id);
      _orders.insert(0, savedOrder);
      notifyListeners();
      return savedOrder;
    } catch (e) {
      debugPrint('Place order error: $e');
      return null;
    }
  }
}
