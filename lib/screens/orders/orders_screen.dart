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

    return Scaffold(
      appBar: AppBar(  automaticallyImplyLeading: false,title: const Text('My Orders')),
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
                          color: (isLight
                                  ? AppTheme.textMutedLight
                                  : AppTheme.textMutedDark)
                              .withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('No orders yet',
                          style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isLight
                                  ? AppTheme.textMutedLight
                                  : AppTheme.textMutedDark)),
                      const SizedBox(height: 8),
                      Text('Your order history will appear here',
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
                  itemCount: orders.length,
                  itemBuilder: (context, i) {
                    final o = orders[i];
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
                                  color: AppTheme.success.withOpacity(0.1),
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
                          Text(o.restaurantName,
                              style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isLight
                                      ? AppTheme.textLight
                                      : AppTheme.textDark)),
                          const SizedBox(height: 4),
                          // Items summary
                          Text(
                            o.items
                                .map((i) => '${i.quantity}× ${i.name}')
                                .join(', '),
                            style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: isLight
                                    ? AppTheme.textMutedLight
                                    : AppTheme.textMutedDark),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                              Text('${o.total.toInt()} DA',
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
                            child: const Text('Reorder'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
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

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Items added to cart!', style: GoogleFonts.cairo()),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }
}
