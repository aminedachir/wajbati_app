import 'dart:convert';

class Restaurant {
  final String id;
  final String name;
  final String nameAr;
  final String category;
  final String type; // 'Restaurant' | 'Patisserie' | 'Fast Food' | 'Pizzeria'
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final double deliveryFee;
  final bool isOpen;
  final bool isFavorite;
  final String address;
  final String? videoUrl;
  final List<MenuItem> menu;

  const Restaurant({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.category,
    this.type =
        'Restaurant', // 'Restaurant' | 'Home Cook' | 'Patisserie' | etc.
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.isOpen,
    this.isFavorite = false,
    required this.address,
    this.videoUrl,
    this.menu = const [],
  });

  bool get isHomeCook => type == 'Home Cook';

  /// Arabic display label for the restaurant type badge
  String get typeAr => switch (type) {
        'Restaurant' => 'مطعم',
        'Home Cook' => 'طبخ منزلي',
        'Patisserie' => 'حلويات',
        'Fast Food' => 'أكل سريع',
        'Pizzeria' => 'بيتزا',
        'Cafe' => 'مقهى',
        _ => type,
      };

  Restaurant copyWith({bool? isFavorite}) => Restaurant(
        id: id,
        name: name,
        nameAr: nameAr,
        category: category,
        type: type,
        imageUrl: imageUrl,
        rating: rating,
        reviewCount: reviewCount,
        deliveryTime: deliveryTime,
        deliveryFee: deliveryFee,
        isOpen: isOpen,
        isFavorite: isFavorite ?? this.isFavorite,
        address: address,
        videoUrl: videoUrl,
        menu: menu,
      );

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        nameAr: json['nameAr'] ?? '',
        category: json['category'] ?? '',
        type: json['type'] ?? 'Restaurant',
        imageUrl: json['imageUrl'] ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: json['reviewCount'] ?? 0,
        deliveryTime: json['deliveryTime'] ?? '',
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
        isOpen: json['isOpen'] ?? false,
        isFavorite: json['isFavorite'] ?? false,
        address: json['address'] ?? '',
        videoUrl: json['videoUrl'],
        menu: [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'category': category,
        'type': type,
        'imageUrl': imageUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'deliveryTime': deliveryTime,
        'deliveryFee': deliveryFee,
        'isOpen': isOpen,
        'isFavorite': isFavorite,
        'address': address,
        'videoUrl': videoUrl,
        'menu': [],
      };

  factory Restaurant.fromAppwrite(Map<String, dynamic> data, String id) =>
      Restaurant(
        id: id,
        name: data['name'] ?? '',
        nameAr: data['nameAr'] ?? '',
        category: data['category'] ?? '',
        type: data['type'] ?? 'Restaurant',
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

class MenuItem {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final String category;
  final String imageUrl;
  final bool isPopular;
  final bool isDiabeticFriendly;
  final bool isHealthOriented;

  const MenuItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    this.descriptionAr = '',
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isPopular = false,
    this.isDiabeticFriendly = false,
    this.isHealthOriented = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'description': description,
        'descriptionAr': descriptionAr,
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
        descriptionAr: m['descriptionAr'] ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
        category: m['category'] ?? '',
        imageUrl: m['imageUrl'] ?? '',
        isPopular: m['isPopular'] ?? false,
        isDiabeticFriendly:
            m['isDiabeticFriendly'] ?? (m['category'] == 'وجبات السكري'),
        isHealthOriented: m['isHealthOriented'] ?? false,
      );
}

class CartItem {
  final MenuItem item;
  int quantity;
  bool isDiabeticRequest;
  String diabeticNote;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.isDiabeticRequest = false,
    this.diabeticNote = '',
  });

  CartItem.fromJson(Map<String, dynamic> json)
      : item = MenuItem.fromMap(json['item'] ?? {}),
        quantity = json['quantity'] ?? 1,
        isDiabeticRequest = json['isDiabeticRequest'] ?? false,
        diabeticNote = json['diabeticNote'] ?? '';

  Map<String, dynamic> toJson() => {
        'item': item.toMap(),
        'quantity': quantity,
        'isDiabeticRequest': isDiabeticRequest,
        'diabeticNote': diabeticNote,
      };
  double get total => item.price * quantity;
}

class OrderItem {
  final String name;
  final String nameAr;
  final int quantity;
  final double price;
  final bool isDiabeticRequest;
  final String diabeticNote;

  const OrderItem({
    required this.name,
    required this.nameAr,
    required this.quantity,
    required this.price,
    this.isDiabeticRequest = false,
    this.diabeticNote = '',
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameAr': nameAr,
        'quantity': quantity,
        'price': price,
        'isDiabeticRequest': isDiabeticRequest,
        'diabeticNote': diabeticNote,
      };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        name: m['name'] ?? '',
        nameAr: m['nameAr'] ?? '',
        quantity: (m['quantity'] as num?)?.toInt() ?? 0,
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
        isDiabeticRequest: m['isDiabeticRequest'] ?? false,
        diabeticNote: m['diabeticNote'] ?? '',
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
  final String paymentMethod; // 'Cash' | 'E-Payment' | 'Combined'
  final String? coOrderId;
  final bool isGroupOrder;
  final String specialInstructions;
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
    this.paymentMethod = 'Cash',
    this.coOrderId,
    this.isGroupOrder = false,
    this.specialInstructions = '',
    required this.createdAt,
  });

  static String generateOrderNumber() {
    final t = DateTime.now().millisecondsSinceEpoch.toString();
    return '#W${t.substring(t.length - 6)}';
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
        'paymentMethod': paymentMethod,
        'isGroupOrder': isGroupOrder,
        'specialInstructions': specialInstructions,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppOrder.fromMap(Map<String, dynamic> d, String id) {
    List<OrderItem> parsed = [];
    final raw = d['items'];
    try {
      final list = raw is String ? jsonDecode(raw) : raw;
      if (list is List) {
        parsed = list
            .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return AppOrder(
      id: id,
      orderNumber: d['orderNumber'] ??
          '#W${id.length >= 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase()}',
      restaurantName: d['restaurantName'] ?? '',
      restaurantId: d['restaurantId'] ?? '',
      items: parsed,
      subtotal: (d['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (d['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (d['discount'] as num?)?.toDouble() ?? 0.0,
      total: (d['total'] as num?)?.toDouble() ?? 0.0,
      status: d['status'] ?? 'جاري التحضير',
      paymentMethod: d['paymentMethod'] ?? 'Cash',
      isGroupOrder: d['isGroupOrder'] ?? false,
      specialInstructions: d['specialInstructions'] ?? '',
      createdAt: DateTime.tryParse(d['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get formattedDate {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays == 0) return 'اليوم, ${_fmt(createdAt)}';
    if (diff.inDays == 1) return 'أمس, ${_fmt(createdAt)}';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}, ${_fmt(createdAt)}';
  }

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ── Place types (used for filter tabs) ───────────────────────────
const List<String> placeTypes = [
  'الكل',
  'طبخ منزلي',
  'مطعم',
  'حلويات',
  'وجبات سريعة',
  'بيتزا',
];

// ── Food categories ───────────────────────────────────────────────
const List<String> categories = [
  'الكل',
  'جزائري',
  'بيتزا',
  'برغر',
  'ياباني',
  'إيطالي',
  'فرنسي',
  'مشاوي',
];
