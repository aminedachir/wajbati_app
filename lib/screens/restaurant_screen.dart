import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/providers.dart';
import '../widgets/widgets.dart';
import 'cart_screen.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantScreen({super.key, required this.restaurant});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  String _selectedMenuCategory = 'All';

  List<String> get menuCategories {
    final cats = widget.restaurant.menu.map((m) => m.category).toSet().toList();
    return ['All', ...cats];
  }

  List<MenuItem> get filteredMenu {
    if (_selectedMenuCategory == 'All') return widget.restaurant.menu;
    return widget.restaurant.menu.where((m) => m.category == _selectedMenuCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final favs = context.watch<FavoritesProvider>();
    final isFav = favs.isFavorite(widget.restaurant.id);
    final r = widget.restaurant;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textDark),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => favs.toggle(r.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                r.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.secondary.withOpacity(0.2),
                  child: const Icon(Icons.restaurant, size: 64, color: AppTheme.secondary),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name,
                                style: GoogleFonts.cairo(
                                    fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                            Text(r.nameAr,
                                style: GoogleFonts.cairo(fontSize: 14, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: r.isOpen ? AppTheme.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: r.isOpen ? AppTheme.success : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          r.isOpen ? 'Open' : 'Closed',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: r.isOpen ? AppTheme.success : Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(r.address,
                            style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Stats row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(icon: Icons.star_rounded, iconColor: const Color(0xFFFFA726),
                            value: '${r.rating}', label: 'Rating'),
                        _StatItem(icon: Icons.access_time_rounded, iconColor: AppTheme.secondary,
                            value: r.deliveryTime, label: 'Delivery'),
                        _StatItem(icon: Icons.delivery_dining_rounded, iconColor: AppTheme.primary,
                            value: '${r.deliveryFee.toInt()} DA', label: 'Fee'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Category filter
                  SectionTitle(title: 'Menu'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: menuCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => CategoryChip(
                        label: menuCategories[i],
                        isSelected: _selectedMenuCategory == menuCategories[i],
                        onTap: () => setState(() => _selectedMenuCategory = menuCategories[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => MenuItemTile(item: filteredMenu[i], restaurant: r),
                childCount: filteredMenu.length,
              ),
            ),
          ),
        ],
      ),

      // Cart bar at bottom
      bottomNavigationBar: cart.itemCount > 0
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${cart.itemCount}',
                          style: GoogleFonts.cairo(
                              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                    Text('View Cart',
                        style: GoogleFonts.cairo(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('${cart.subtotal.toInt()} DA',
                        style: GoogleFonts.cairo(
                            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem(
      {required this.icon,
      required this.iconColor,
      required this.value,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.cairo(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        Text(label,
            style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }
}
