import 'package:cloud_firestore/cloud_firestore.dart';

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
    required this.menu,
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
        id: m['id'],
        name: m['name'],
        nameAr: m['nameAr'],
        description: m['description'],
        price: (m['price'] as num).toDouble(),
        category: m['category'],
        imageUrl: m['imageUrl'],
        isPopular: m['isPopular'] ?? false,
      );
}

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get total => item.price * quantity;
}

// ─── Order model ──────────────────────────────────────────────────
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
        name: m['name'],
        nameAr: m['nameAr'],
        quantity: m['quantity'],
        price: (m['price'] as num).toDouble(),
      );
}

class AppOrder {
  final String id;
  final String restaurantName;
  final String restaurantId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.restaurantName,
    required this.restaurantId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'restaurantName': restaurantName,
        'restaurantId': restaurantId,
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory AppOrder.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppOrder(
      id: doc.id,
      restaurantName: d['restaurantName'],
      restaurantId: d['restaurantId'],
      items: (d['items'] as List).map((i) => OrderItem.fromMap(i)).toList(),
      subtotal: (d['subtotal'] as num).toDouble(),
      deliveryFee: (d['deliveryFee'] as num).toDouble(),
      total: (d['total'] as num).toDouble(),
      status: d['status'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
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

  String get orderNumber => '#W${id.substring(0, 5).toUpperCase()}';
}

// ─── Sample data ──────────────────────────────────────────────────
final List<Restaurant> sampleRestaurants = [
  Restaurant(
    id: '1',
    name: 'Dar El Medina',
    nameAr: 'دار المدينة',
    category: 'Algerian',
    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
    rating: 4.8,
    reviewCount: 320,
    deliveryTime: '25-35 min',
    deliveryFee: 150,
    isOpen: true,
    address: 'Rue Didouche Mourad, Alger',
    menu: [
      MenuItem(id: 'm1', name: 'Couscous Royal', nameAr: 'كسكسي ملكي', description: 'Lamb, vegetables, harissa', price: 850, category: 'Main', imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200', isPopular: true),
      MenuItem(id: 'm2', name: 'Chorba Frik', nameAr: 'شوربة فريك', description: 'Traditional wheat soup', price: 350, category: 'Starter', imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=200'),
      MenuItem(id: 'm3', name: 'Tajine Zitoune', nameAr: 'طاجين الزيتون', description: 'Chicken, olives, lemon', price: 700, category: 'Main', imageUrl: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=200', isPopular: true),
      MenuItem(id: 'm4', name: 'Baklava', nameAr: 'بقلاوة', description: 'Honey, pistachios', price: 180, category: 'Dessert', imageUrl: 'https://images.unsplash.com/photo-1519676867240-f03562e64548?w=200'),
    ],
  ),
  Restaurant(
    id: '2',
    name: 'La Piazza',
    nameAr: 'لا بياتزا',
    category: 'Italian',
    imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
    rating: 4.5,
    reviewCount: 210,
    deliveryTime: '30-40 min',
    deliveryFee: 200,
    isOpen: true,
    address: 'Boulevard Khemisti, Alger',
    menu: [
      MenuItem(id: 'm5', name: 'Margherita Pizza', nameAr: 'بيتزا مارغريتا', description: 'Tomato, mozzarella, basil', price: 950, category: 'Pizza', imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=200', isPopular: true),
      MenuItem(id: 'm6', name: 'Pasta Carbonara', nameAr: 'باستا كاربونارا', description: 'Egg, pancetta, parmesan', price: 800, category: 'Pasta', imageUrl: 'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=200'),
    ],
  ),
  Restaurant(
    id: '3',
    name: 'Sushi Baya',
    nameAr: 'سوشي بايا',
    category: 'Japanese',
    imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
    rating: 4.6,
    reviewCount: 180,
    deliveryTime: '40-50 min',
    deliveryFee: 250,
    isOpen: false,
    address: 'Hydra, Alger',
    menu: [
      MenuItem(id: 'm7', name: 'Salmon Roll', nameAr: 'رول سالمون', description: 'Fresh salmon, avocado', price: 1200, category: 'Rolls', imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=200', isPopular: true),
    ],
  ),
  Restaurant(
    id: '4',
    name: 'Burger House',
    nameAr: 'بيت البرغر',
    category: 'Burger',
    imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    rating: 4.3,
    reviewCount: 450,
    deliveryTime: '20-30 min',
    deliveryFee: 100,
    isOpen: true,
    address: 'Bab Ezzouar, Alger',
    menu: [
      MenuItem(id: 'm8', name: 'Classic Burger', nameAr: 'برغر كلاسيك', description: 'Beef patty, cheese, lettuce', price: 650, category: 'Burgers', imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200', isPopular: true),
      MenuItem(id: 'm9', name: 'Crispy Chicken', nameAr: 'دجاج مقرمش', description: 'Fried chicken, coleslaw', price: 580, category: 'Burgers', imageUrl: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=200'),
      MenuItem(id: 'm10', name: 'Loaded Fries', nameAr: 'فريتس محملة', description: 'Cheese, bacon, jalapeños', price: 350, category: 'Sides', imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=200'),
    ],
  ),
];

const List<String> categories = [
  'All', 'Algerian', 'Pizza', 'Burger', 'Japanese', 'Italian', 'Healthy',
];