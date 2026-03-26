import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

// ─── Auth Provider ────────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  String get displayName => _user?.displayName ?? _user?.email?.split('@').first ?? 'User';
  String get email => _user?.email ?? '';
  String get initials {
    final name = displayName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  AuthProvider() {
    _auth.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      _loading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      _error = _mapError(e.code);
      notifyListeners();
      return _error;
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();
      _user = _auth.currentUser;
      _loading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      _error = _mapError(e.code);
      notifyListeners();
      return _error;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

// ─── Cart Provider ────────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  Restaurant? _restaurant;

  List<CartItem> get items => _items;
  Restaurant? get restaurant => _restaurant;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0, (sum, i) => sum + i.total);
  double get deliveryFee => _restaurant?.deliveryFee ?? 0;
  double get total => subtotal + deliveryFee;

  void addItem(MenuItem item, Restaurant resto) {
    if (_restaurant != null && _restaurant!.id != resto.id) {
      _items.clear();
    }
    _restaurant = resto;
    final idx = _items.indexWhere((ci) => ci.item.id == item.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(item: item));
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((ci) => ci.item.id == itemId);
    if (_items.isEmpty) _restaurant = null;
    notifyListeners();
  }

  void decreaseItem(String itemId) {
    final idx = _items.indexWhere((ci) => ci.item.id == itemId);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
        if (_items.isEmpty) _restaurant = null;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _restaurant = null;
    notifyListeners();
  }

  int quantityOf(String itemId) {
    final idx = _items.indexWhere((ci) => ci.item.id == itemId);
    return idx >= 0 ? _items[idx].quantity : 0;
  }
}

// ─── Favorites Provider ───────────────────────────────────────────
class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favorites = {};

  bool isFavorite(String id) => _favorites.contains(id);

  void toggle(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }
}

// ─── Orders Provider ─────────────────────────────────────────────
class OrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<AppOrder> _orders = [];
  bool _loading = false;

  List<AppOrder> get orders => _orders;
  bool get loading => _loading;

  Future<void> loadOrders(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      _orders = snap.docs.map((d) => AppOrder.fromDoc(d)).toList();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<AppOrder?> placeOrder({
    required String userId,
    required CartProvider cart,
  }) async {
    if (cart.restaurant == null || cart.items.isEmpty) return null;
    try {
      final orderData = AppOrder(
        id: '',
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
        total: cart.total,
        status: 'Delivered',
        createdAt: DateTime.now(),
      );

      final ref = await _db
          .collection('users')
          .doc(userId)
          .collection('orders')
          .add(orderData.toMap());

      final saved = AppOrder(
        id: ref.id,
        restaurantName: orderData.restaurantName,
        restaurantId: orderData.restaurantId,
        items: orderData.items,
        subtotal: orderData.subtotal,
        deliveryFee: orderData.deliveryFee,
        total: orderData.total,
        status: orderData.status,
        createdAt: orderData.createdAt,
      );

      _orders.insert(0, saved);
      notifyListeners();
      return saved;
    } catch (_) {
      return null;
    }
  }
}