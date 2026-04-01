import 'dart:convert';

class Restaurant {
  final String id;
  final String name;
  final String nameAr;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final double deliveryFee;
  final bool isOpen;
  final bool isFavorite;
  final String address;
  final List<MenuItem> menu;

  const Restaurant({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.isOpen,
    this.isFavorite = false,
    required this.address,
    this.menu = const [],
  });

  Restaurant copyWith({bool? isFavorite}) => Restaurant(
        id: id,
        name: name,
        nameAr: nameAr,
        category: category,
        imageUrl: imageUrl,
        rating: rating,
        reviewCount: reviewCount,
        deliveryTime: deliveryTime,
        deliveryFee: deliveryFee,
        isOpen: isOpen,
        isFavorite: isFavorite ?? this.isFavorite,
        address: address,
        menu: menu,
      );

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        nameAr: json['nameAr'] ?? '',
        category: json['category'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: json['reviewCount'] ?? 0,
        deliveryTime: json['deliveryTime'] ?? '',
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
        isOpen: json['isOpen'] ?? false,
        isFavorite: json['isFavorite'] ?? false,
        address: json['address'] ?? '',
        menu: [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'category': category,
        'imageUrl': imageUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'deliveryTime': deliveryTime,
        'deliveryFee': deliveryFee,
        'isOpen': isOpen,
        'isFavorite': isFavorite,
        'address': address,
        'menu': [],
      };

  factory Restaurant.fromAppwrite(Map<String, dynamic> data, String id) {
    return Restaurant(
      id: id,
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      deliveryTime: data['deliveryTime'] ?? '25-35 min',
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      isOpen: data['isOpen'] ?? true,
      address: data['address'] ?? '',
      menu: [],
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isPopular;

  const MenuItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isPopular = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'description': description,
        'price': price,
        'category': category,
        'imageUrl': imageUrl,
        'isPopular': isPopular,
      };

  factory MenuItem.fromMap(Map<String, dynamic> m) => MenuItem(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        nameAr: m['nameAr'] ?? '',
        description: m['description'] ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
        category: m['category'] ?? '',
        imageUrl: m['imageUrl'] ?? '',
        isPopular: m['isPopular'] ?? false,
      );
}

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  CartItem.fromJson(Map<String, dynamic> json)
      : item = MenuItem.fromMap(json['item'] ?? {}),
        quantity = json['quantity'] ?? 1;

  Map<String, dynamic> toJson() => {
        'item': item.toMap(),
        'quantity': quantity,
      };

  double get total => item.price * quantity;
}

class OrderItem {
  final String name;
  final String nameAr;
  final int quantity;
  final double price;

  const OrderItem({
    required this.name,
    required this.nameAr,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameAr': nameAr,
        'quantity': quantity,
        'price': price,
      };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        name: m['name'] ?? '',
        nameAr: m['nameAr'] ?? '',
        quantity: (m['quantity'] as num?)?.toInt() ?? 0,
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
      );
}

class AppOrder {
  final String id;
  final String orderNumber;
  final String restaurantName;
  final String restaurantId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String status;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.orderNumber,
    required this.restaurantName,
    required this.restaurantId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  // Generate a short human-readable order number
  static String generateOrderNumber() {
    final now = DateTime.now();
    return '#W${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  Map<String, dynamic> toMap() => {
        'orderNumber': orderNumber,
        'restaurantName': restaurantName,
        'restaurantId': restaurantId,
        'items': jsonEncode(items.map((i) => i.toMap()).toList()),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'total': total,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppOrder.fromMap(Map<String, dynamic> d, String id) {
    // items can be a JSON string or already a List
    List<OrderItem> parsedItems = [];
    final rawItems = d['items'];
    try {
      if (rawItems is String) {
        parsedItems = (jsonDecode(rawItems) as List)
            .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
            .toList();
      } else if (rawItems is List) {
        parsedItems = rawItems
            .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      parsedItems = [];
    }

    return AppOrder(
      id: id,
      orderNumber: d['orderNumber'] ?? '#W${id.substring(0, 5).toUpperCase()}',
      restaurantName: d['restaurantName'] ?? '',
      restaurantId: d['restaurantId'] ?? '',
      items: parsedItems,
      subtotal: (d['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (d['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (d['discount'] as num?)?.toDouble() ?? 0.0,
      total: (d['total'] as num?)?.toDouble() ?? 0.0,
      status: d['status'] ?? 'Preparing',
      createdAt: DateTime.tryParse(d['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays == 0) return 'Today, ${_fmt(createdAt)}';
    if (diff.inDays == 1) return 'Yesterday, ${_fmt(createdAt)}';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}, ${_fmt(createdAt)}';
  }

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ── Sample categories ─────────────────────────────────────────────
const List<String> categories = [
  'All',
  'Algerian',
  'Pizza',
  'Burger',
  'Japanese',
  'Italian',
  'Healthy',
];
