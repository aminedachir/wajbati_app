import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/providers.dart';
import '../widgets/widgets.dart';
import 'restaurant_screen.dart';
import 'auth_screen.dart';

// ─── Favorites Screen ─────────────────────────────────────────────
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final favoriteRestaurants =
        sampleRestaurants.where((r) => favs.isFavorite(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favoriteRestaurants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 72,
                      color: AppTheme.textMuted.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No favorites yet',
                      style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  Text('Tap the heart icon to save your favorites',
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: AppTheme.textMuted)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: favoriteRestaurants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) => RestaurantCard(
                restaurant: favoriteRestaurants[i],
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RestaurantScreen(
                            restaurant: favoriteRestaurants[i]))),
              ),
            ),
    );
  }
}

// ─── Orders Screen ────────────────────────────────────────────────
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
      if (auth.isLoggedIn) {
        context.read<OrdersProvider>().loadOrders(auth.user!.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final orders = ordersProvider.orders;

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
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
                          color: AppTheme.textMuted.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('No orders yet',
                          style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted)),
                      const SizedBox(height: 8),
                      Text('Your order history will appear here',
                          style: GoogleFonts.cairo(
                              fontSize: 13, color: AppTheme.textMuted)),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.divider),
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
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 4),
                          // Items summary
                          Text(
                            o.items
                                .map((i) => '${i.quantity}× ${i.name}')
                                .join(', '),
                            style: GoogleFonts.cairo(
                                fontSize: 12, color: AppTheme.textMuted),
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
                                      color: AppTheme.textMuted)),
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

  void _reorder(BuildContext context, AppOrder order) {
    // Find the matching restaurant from sample data
    final restaurant = sampleRestaurants.firstWhere(
      (r) => r.id == order.restaurantId,
      orElse: () => sampleRestaurants.first,
    );
    final cart = context.read<CartProvider>();
    cart.clear();

    for (final oi in order.items) {
      // Try to find matching menu item by name
      final menuItem = restaurant.menu.firstWhere(
        (m) => m.name == oi.name,
        orElse: () => restaurant.menu.first,
      );
      for (int i = 0; i < oi.quantity; i++) {
        cart.addItem(menuItem, restaurant);
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

// ─── Profile Screen ───────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrdersProvider>();
    final favs = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFFBF1A12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  auth.initials,
                  style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(auth.displayName,
                style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
            Text(auth.email,
                style:
                    GoogleFonts.cairo(fontSize: 14, color: AppTheme.textMuted)),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                _StatCard(
                    value: '${orders.orders.length}', label: 'Orders'),
                const SizedBox(width: 12),
                _StatCard(
                    value:
                        '${sampleRestaurants.where((r) => favs.isFavorite(r.id)).length}',
                    label: 'Favorites'),
                const SizedBox(width: 12),
                const _StatCard(value: '4.9', label: 'Rating'),
              ],
            ),

            const SizedBox(height: 24),
            _MenuTile(
                icon: Icons.location_on_rounded,
                label: 'My Addresses',
                color: AppTheme.secondary,
                onTap: () => _showComingSoon(context, 'My Addresses')),
            _MenuTile(
                icon: Icons.payment_rounded,
                label: 'Payment Methods',
                color: AppTheme.primary,
                onTap: () => _showComingSoon(context, 'Payment Methods')),
            _MenuTile(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                color: const Color(0xFFFFA726),
                onTap: () => _showComingSoon(context, 'Notifications')),
            _MenuTile(
                icon: Icons.help_rounded,
                label: 'Help & Support',
                color: AppTheme.success,
                onTap: () => _showComingSoon(context, 'Help & Support')),
            _MenuTile(
                icon: Icons.info_rounded,
                label: 'About Wajbati DZ',
                color: AppTheme.textMuted,
                onTap: () => _showAbout(context)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context, auth),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: GoogleFonts.cairo(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.cairo(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
              // AuthGate will automatically show AuthScreen
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child:
                Text('Sign Out', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$feature — coming soon!', style: GoogleFonts.cairo()),
      backgroundColor: AppTheme.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                  color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.restaurant, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Wajbati DZ',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Your favorite Algerian food delivery app.\nVersion 1.0.0\n\nBuilt with ❤️ for Algeria.',
          style: GoogleFonts.cairo(fontSize: 14, color: AppTheme.textMuted),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text('OK', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary)),
            Text(label,
                style:
                    GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        title: Text(label,
            style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark)),
        trailing: const Icon(Icons.chevron_right_rounded,
            size: 18, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}