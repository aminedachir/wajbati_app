// ── Restaurant Order Model & Mock Data ──────────────────────────────────────
import 'dart:math';

enum OrderStatus {
  pending,      // جديد - waiting for restaurant to accept
  accepted,     // مقبول - restaurant accepted, preparing
  preparing,    // جاري التحضير
  readyForPickup, // جاهز للاستلام - waiting for livreur
  outForDelivery, // في الطريق - livreur picked up
  delivered,    // تم التسليم
  cancelled,    // ملغى
}

extension OrderStatusExt on OrderStatus {
  String get labelAr => switch (this) {
    OrderStatus.pending       => 'طلب جديد',
    OrderStatus.accepted      => 'مقبول',
    OrderStatus.preparing     => 'جاري التحضير',
    OrderStatus.readyForPickup => 'جاهز للاستلام',
    OrderStatus.outForDelivery => 'في الطريق',
    OrderStatus.delivered     => 'تم التسليم',
    OrderStatus.cancelled     => 'ملغى',
  };

  String get emoji => switch (this) {
    OrderStatus.pending        => '🔔',
    OrderStatus.accepted       => '✅',
    OrderStatus.preparing      => '👨‍🍳',
    OrderStatus.readyForPickup  => '📦',
    OrderStatus.outForDelivery  => '🛵',
    OrderStatus.delivered       => '🎉',
    OrderStatus.cancelled       => '❌',
  };
}

class DashOrderItem {
  final String name;
  final String nameAr;
  final int quantity;
  final double price;

  const DashOrderItem({required this.name, this.nameAr = '', required this.quantity, required this.price});
  double get total => price * quantity;
}

class DashOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String address;
  final List<DashOrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  OrderStatus status;
  final String paymentMethod;
  final DateTime createdAt;
  String? livreurName;
  String? livreurPhone;
  String? livreurEmoji;
  int? estimatedMinutes;

  DashOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.livreurName,
    this.livreurPhone,
    this.livreurEmoji,
    this.estimatedMinutes,
  });
}

// ── Mock livreurs ─────────────────────────────────────────────────────────────
class MockLivreur {
  final String name;
  final String phone;
  final String emoji;
  final double rating;
  final bool available;
  const MockLivreur({
    required this.name, required this.phone,
    required this.emoji, required this.rating, required this.available,
  });
}

const mockLivreurs = [
  MockLivreur(name: 'أمين بن علي', phone: '0555 123 456', emoji: '🛵', rating: 4.9, available: true),
  MockLivreur(name: 'كريم دلال', phone: '0661 789 012', emoji: '🏍️', rating: 4.7, available: true),
  MockLivreur(name: 'يوسف مزاحم', phone: '0770 345 678', emoji: '🚴', rating: 4.8, available: false),
  MockLivreur(name: 'بلال سعداوي', phone: '0550 901 234', emoji: '🛵', rating: 4.6, available: true),
];

// ── Mock data generator ───────────────────────────────────────────────────────
List<DashOrder> generateMockOrders(String restaurantId) {
  final rng = Random(restaurantId.hashCode);
  final customers = [
    ('فارس بوعزيز', '0551 234 567', 'شارع ديدوش مراد، الجزائر العاصمة'),
    ('نور الهدى بن عمر', '0661 345 678', 'حي السلامة، بئر خادم'),
    ('عبد الرحمان كريمي', '0770 456 789', 'شارع العربي بن مهيدي، وهران'),
    ('سارة مزغيش', '0555 567 890', 'طريق الشلف، بوفاريك'),
    ('حمزة الطاهر', '0660 678 901', 'حي النصر، قسنطينة'),
    ('ليلى بوكرزازة', '0771 789 012', 'شارع زيغود يوسف، سطيف'),
  ];

  final menuByRestaurant = {
    'tabakh_afrah': [
      ('شاورما لحم', 450.0), ('دجاج مشوي كامل', 900.0),
      ('كسكسي بالخضار', 650.0), ('طاجين لحم', 750.0), ('عصير طبيعي', 150.0),
    ],
    'halawiyat_benasser': [
      ('بقلاوة 500غ', 800.0), ('قطايف', 350.0),
      ('كعك العيد', 600.0), ('مقروط تمر', 400.0), ('شاي بالنعناع', 100.0),
    ],
    'fourrotime': [
      ('برغر كلاسيك', 550.0), ('دجاج كريسبي', 500.0),
      ('بيتزا مارغريتا', 750.0), ('فريت كبير', 200.0), ('كولا', 150.0),
    ],
  };

  final menu = menuByRestaurant[restaurantId] ?? menuByRestaurant['fourrotime']!;
  final statuses = [
    OrderStatus.pending, OrderStatus.pending,
    OrderStatus.accepted, OrderStatus.preparing, OrderStatus.preparing,
    OrderStatus.readyForPickup, OrderStatus.outForDelivery,
    OrderStatus.delivered, OrderStatus.delivered, OrderStatus.delivered,
  ];

  final orders = <DashOrder>[];
  for (int i = 0; i < 12; i++) {
    final cust = customers[rng.nextInt(customers.length)];
    final status = statuses[i % statuses.length];
    final itemCount = rng.nextInt(3) + 1;
    final items = List.generate(itemCount, (_) {
      final m = menu[rng.nextInt(menu.length)];
      return DashOrderItem(name: m.$1, quantity: rng.nextInt(2) + 1, price: m.$2);
    });
    final sub = items.fold(0.0, (s, it) => s + it.total);
    final fee = 150.0;
    final livreur = (status == OrderStatus.outForDelivery || status == OrderStatus.readyForPickup)
      ? mockLivreurs[rng.nextInt(mockLivreurs.length)]
      : null;

    orders.add(DashOrder(
      id: 'ord_${restaurantId}_$i',
      orderNumber: '#W${(100000 + rng.nextInt(900000)).toString()}',
      customerName: cust.$1,
      customerPhone: cust.$2,
      address: cust.$3,
      items: items,
      subtotal: sub,
      deliveryFee: fee,
      total: sub + fee,
      status: status,
      paymentMethod: rng.nextBool() ? 'نقدي' : 'دفع إلكتروني',
      createdAt: DateTime.now().subtract(Duration(minutes: rng.nextInt(180) + 5)),
      livreurName: livreur?.name,
      livreurPhone: livreur?.phone,
      livreurEmoji: livreur?.emoji,
      estimatedMinutes: livreur != null ? rng.nextInt(20) + 10 : null,
    ));
  }
  // Sort: pending first
  orders.sort((a, b) => a.status.index.compareTo(b.status.index));
  return orders;
}

// ── Weekly revenue mock ───────────────────────────────────────────────────────
List<double> generateWeeklyRevenue(String restaurantId) {
  final rng = Random(restaurantId.hashCode + 1);
  return List.generate(7, (_) => 5000 + rng.nextDouble() * 15000);
}

List<int> generateHourlyCounts(String restaurantId) {
  final rng = Random(restaurantId.hashCode + 2);
  return List.generate(12, (i) {
    // peaks at lunch (i=2,3) and dinner (i=7,8)
    final peak = (i == 2 || i == 3 || i == 7 || i == 8) ? 3.0 : 1.0;
    return (rng.nextDouble() * 8 * peak).round() + 1;
  });
}
