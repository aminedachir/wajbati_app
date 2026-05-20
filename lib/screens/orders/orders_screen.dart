import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/providers.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && auth.user != null) {
        context.read<OrdersProvider>().loadOrders(auth.user!.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final orders = ordersProvider.orders;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mutedColor = AppTheme.textMuted(context);

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: ordersProvider.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 72,
                          color: mutedColor.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('لا توجد طلبات بعد',
                          style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isLight
                                  ? AppTheme.textMutedLight
                                  : AppTheme.textMutedDark)),
                      const SizedBox(height: 8),
                      Text('سجل طلباتك سيظهر هنا',
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: isLight
                                  ? AppTheme.textMutedLight
                                  : AppTheme.textMutedDark)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _groupOrdersByRestaurant(orders).length,
                  itemBuilder: (context, index) {
                    final grouped = _groupOrdersByRestaurant(orders);
                    final restaurantName = grouped.keys.elementAt(index);
                    final restaurantOrders = grouped[restaurantName]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            restaurantName,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isLight ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                        ),
                        ...restaurantOrders.map((o) {
                          return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isLight
                                ? AppTheme.lightDivider
                                : AppTheme.darkDivider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(o.orderNumber,
                                  style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.secondary)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(o.status,
                                    style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.success)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Items summary with Diabetic Request badges
                          ...o.items.map((i) => Row(
                                children: [
                                  Text(
                                    '${i.quantity}× ${i.nameAr.isNotEmpty ? i.nameAr : i.name}',
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: isLight
                                            ? AppTheme.textMutedLight
                                            : AppTheme.textMutedDark),
                                  ),
                                  if (i.isDiabeticRequest)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('طلب سكري',
                                          style: GoogleFonts.cairo(
                                              fontSize: 9,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              )),
                          if (o.isGroupOrder)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.people_outline_rounded, size: 14, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text('طلب جماعي / مشاركة التوصيل',
                                      style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: AppTheme.secondary,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          if (o.specialInstructions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'ملاحظات: ${o.specialInstructions}',
                                style: GoogleFonts.cairo(fontSize: 11, color: Colors.orange.shade700),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(o.formattedDate,
                                  style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: isLight
                                          ? AppTheme.textMutedLight
                                          : AppTheme.textMutedDark)),
                              Text('${o.total.toInt()} د.ج',
                                  style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => _reorder(context, o),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(color: AppTheme.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              textStyle: GoogleFonts.cairo(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            child: const Text('إعادة طلب'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
    );
  }

  Map<String, List<AppOrder>> _groupOrdersByRestaurant(List<AppOrder> orders) {
    final Map<String, List<AppOrder>> grouped = {};
    for (var order in orders) {
      grouped.putIfAbsent(order.restaurantName, () => []).add(order);
    }
    return grouped;
  }

  Future<void> _reorder(BuildContext context, AppOrder order) async {
    final cart = context.read<CartProvider>();
    await cart.clear();

    for (final oi in order.items) {
      // Recreate a minimal MenuItem from the order data
      final menuItem = MenuItem(
        id: oi.name,
        name: oi.name,
        nameAr: oi.nameAr,
        description: '',
        price: oi.price,
        category: '',
        imageUrl: '',
      );
      final mockRestaurant = Restaurant(
        id: order.restaurantId,
        name: order.restaurantName,
        nameAr: '',
        category: '',
        imageUrl: '',
        rating: 0,
        reviewCount: 0,
        deliveryTime: '',
        deliveryFee: 0,
        isOpen: true,
        address: '',
        menu: [],
      );
      for (int i = 0; i < oi.quantity; i++) {
        await cart.addItem(menuItem, mockRestaurant);
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('تمت إضافة الوجبات إلى السلة!', style: GoogleFonts.cairo()),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }
}
