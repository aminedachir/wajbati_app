import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import 'restaurant_order_model.dart';
import 'dashboard_orders_tab.dart';
import 'dashboard_analytics_tab.dart';
import 'dashboard_delivery_tab.dart';
import '../../../utils/realtime_service.dart';
import '../../../utils/appwrite_service.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final String restaurantEmoji;
  final Color accentColor;

  const RestaurantDashboardScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantEmoji,
    required this.accentColor,
  });

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen>
    with TickerProviderStateMixin {
  late List<DashOrder> _orders;
  late AnimationController _headerCtrl;
  late AnimationController _tabCtrl;
  late AnimationController _pulseCtrl;
  int _currentTab = 0;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _orders = [];
    _loadOrders();
    
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _tabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    // Live order updates via Appwrite Realtime
    RealtimeService.watchRestaurantOrders(
      widget.restaurantId,
      restaurantName: widget.restaurantName,
      onEvent: (eventType, data) {
        final orderId = data['\$id'] as String?;
        if (orderId == null) return;
        if (eventType.contains('create')) {
          // New order arrived — add to top of list
          setState(() {
            _orders.insert(0, _parseAppwriteOrder(data, orderId));
          });
        } else if (eventType.contains('update')) {
          // Status updated from another device / Appwrite Function
          final newStatusStr = data['status'] as String?;
          if (newStatusStr == null) return;
          final newStatus = OrderStatus.values.firstWhere(
            (s) => s.labelAr == newStatusStr,
            orElse: () => OrderStatus.pending,
          );
          _updateOrderStatusLocally(orderId, newStatus);
        }
      },
    );
  }

  Future<void> _loadOrders() async {
    final docs = await AppwriteService.getRestaurantOrders(widget.restaurantId, restaurantName: widget.restaurantName);
    if (!mounted) return;
    setState(() {
      _orders = docs.map((doc) => _parseAppwriteOrder(doc.data, doc.$id)).toList();
    });
  }

  DashOrder _parseAppwriteOrder(Map<String, dynamic> data, String id) {
    List<DashOrderItem> items = [];
    try {
      final rawItems = data['items'];
      final List list = rawItems is String ? jsonDecode(rawItems) : rawItems;
      items = list.map((i) => DashOrderItem(
        name: i['nameAr']?.toString().isNotEmpty == true ? i['nameAr'] : i['name'] ?? '',
        quantity: i['quantity'] ?? 1,
        price: (i['price'] as num?)?.toDouble() ?? 0.0,
      )).toList();
    } catch (_) {}

    final statusStr = data['status'] as String? ?? '';
    final status = OrderStatus.values.firstWhere(
      (s) => s.labelAr == statusStr,
      orElse: () => OrderStatus.pending,
    );

    return DashOrder(
      id: id,
      orderNumber: data['orderNumber'] ?? '#W000000',
      customerName: data['customerName'] ?? 'زبون',
      customerPhone: data['customerPhone'] ?? '',
      address: data['deliveryAddress'] ?? '',
      items: items,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 150,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      status: status,
      paymentMethod: data['paymentMethod'] ?? 'نقدي',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _tabCtrl.dispose();
    _pulseCtrl.dispose();
    RealtimeService.cancelRestaurantWatch();
    super.dispose();
  }

  void _updateOrderStatusLocally(String orderId, OrderStatus newStatus, {MockLivreur? livreur}) {
    setState(() {
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        final o = _orders[idx];
        _orders[idx] = DashOrder(
          id: o.id,
          orderNumber: o.orderNumber,
          customerName: o.customerName,
          customerPhone: o.customerPhone,
          address: o.address,
          items: o.items,
          subtotal: o.subtotal,
          deliveryFee: o.deliveryFee,
          total: o.total,
          status: newStatus,
          paymentMethod: o.paymentMethod,
          createdAt: o.createdAt,
          livreurName: livreur?.name ?? o.livreurName,
          livreurPhone: livreur?.phone ?? o.livreurPhone,
          livreurEmoji: livreur?.emoji ?? o.livreurEmoji,
          estimatedMinutes: livreur != null ? 15 : o.estimatedMinutes,
        );
        _orders.sort((a, b) => a.status.index.compareTo(b.status.index));
      }
    });
  }

  void _updateOrderStatus(String orderId, OrderStatus newStatus, {MockLivreur? livreur}) {
    _updateOrderStatusLocally(orderId, newStatus, livreur: livreur);
    AppwriteService.updateOrderStatus(orderId, newStatus.labelAr).catchError((_) {});
  }

  int get _pendingCount => _orders.where((o) => o.status == OrderStatus.pending).length;
  int get _activeCount => _orders.where((o) =>
    o.status == OrderStatus.accepted ||
    o.status == OrderStatus.preparing ||
    o.status == OrderStatus.readyForPickup
  ).length;

  @override
  Widget build(BuildContext context) {
    final tabs = ['الطلبات', 'التوصيل', 'الإحصائيات'];
    final tabIcons = [Icons.receipt_long_rounded, Icons.delivery_dining_rounded, Icons.bar_chart_rounded];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────
          _DashboardHeader(
            restaurantName: widget.restaurantName,
            restaurantEmoji: widget.restaurantEmoji,
            accentColor: widget.accentColor,
            pendingCount: _pendingCount,
            activeCount: _activeCount,
            isOnline: _isOnline,
            pulseCtrl: _pulseCtrl,
            headerCtrl: _headerCtrl,
            onToggleOnline: () => setState(() => _isOnline = !_isOnline),
            onLogout: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),

          // ── Tab bar ────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final selected = _currentTab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() { _currentTab = i; _tabCtrl.forward(from: 0); }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? widget.accentColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: selected ? [
                          BoxShadow(color: widget.accentColor.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))
                        ] : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tabIcons[i], size: 16,
                            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.4)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(tabs[i],
                              style: GoogleFonts.cairo(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (i == 0 && _pendingCount > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('$_pendingCount',
                                style: GoogleFonts.cairo(
                                  fontSize: 10, fontWeight: FontWeight.w800,
                                  color: selected ? widget.accentColor : Colors.white,
                                )),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Tab content ────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: switch (_currentTab) {
                0 => DashboardOrdersTab(
                    key: const ValueKey('orders'),
                    orders: _orders,
                    accentColor: widget.accentColor,
                    onUpdateStatus: _updateOrderStatus,
                  ),
                1 => DashboardDeliveryTab(
                    key: const ValueKey('delivery'),
                    orders: _orders,
                    accentColor: widget.accentColor,
                    onUpdateStatus: _updateOrderStatus,
                  ),
                _ => DashboardAnalyticsTab(
                    key: const ValueKey('analytics'),
                    orders: _orders,
                    restaurantId: widget.restaurantId,
                    accentColor: widget.accentColor,
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard Header ─────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final String restaurantName, restaurantEmoji;
  final Color accentColor;
  final int pendingCount, activeCount;
  final bool isOnline;
  final AnimationController pulseCtrl, headerCtrl;
  final VoidCallback onToggleOnline, onLogout;

  const _DashboardHeader({
    required this.restaurantName, required this.restaurantEmoji,
    required this.accentColor, required this.pendingCount,
    required this.activeCount, required this.isOnline,
    required this.pulseCtrl, required this.headerCtrl,
    required this.onToggleOnline, required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: headerCtrl,
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(headerCtrl.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - t)),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha: 0.15),
                        const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                  ),
                  child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Restaurant emoji badge
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor.withValues(alpha: 0.2),
                              border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 2),
                            ),
                            child: Center(child: Text(restaurantEmoji, style: const TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(restaurantName,
                                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                Row(children: [
                                  AnimatedBuilder(
                                    animation: pulseCtrl,
                                    builder: (_, __) => Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isOnline ? AppTheme.success : Colors.grey,
                                        boxShadow: isOnline ? [
                                          BoxShadow(
                                            color: AppTheme.success.withValues(alpha: 0.3 + pulseCtrl.value * 0.4),
                                            blurRadius: 6 + pulseCtrl.value * 6,
                                          )
                                        ] : [],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(isOnline ? 'متاح - يقبل الطلبات' : 'مغلق',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: isOnline ? AppTheme.success : Colors.grey,
                                    )),
                                ]),
                              ],
                            ),
                          ),
                          // Online toggle
                          GestureDetector(
                            onTap: onToggleOnline,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 50, height: 28,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: isOnline ? AppTheme.success : Colors.grey.shade700,
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  width: 22, height: 22,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: onLogout,
                            icon: const Icon(Icons.logout_rounded, color: Colors.white60, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Quick stats row
                      Row(
                        children: [
                          _QuickStat(label: 'طلبات جديدة', value: '$pendingCount', color: Colors.orangeAccent, icon: '🔔'),
                          const SizedBox(width: 10),
                          _QuickStat(label: 'قيد التحضير', value: '$activeCount', color: accentColor, icon: '👨‍🍳'),
                          const SizedBox(width: 10),
                          _QuickStat(
                            label: 'اليوم',
                            value: '${pendingCount + activeCount + 5}',
                            color: AppTheme.success,
                            icon: '📦',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _QuickStat({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value,
                    style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text(label,
                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.white.withValues(alpha: 0.5)),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
