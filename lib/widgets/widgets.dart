import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/providers.dart';
import 'package:provider/provider.dart';

// ─── Restaurant Card ──────────────────────────────────────────────
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({super.key, required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final isFav = favs.isFavorite(restaurant.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    restaurant.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: AppTheme.secondary.withOpacity(0.1),
                      child: const Icon(Icons.restaurant, size: 48, color: AppTheme.secondary),
                    ),
                  ),
                ),
                // Status badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: restaurant.isOpen ? AppTheme.success : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      restaurant.isOpen ? 'Open' : 'Closed',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => favs.toggle(restaurant.id),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name,
                      style: GoogleFonts.cairo(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(restaurant.nameAr,
                      style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFA726)),
                      const SizedBox(width: 4),
                      Text('${restaurant.rating}',
                          style: GoogleFonts.cairo(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                      Text(' (${restaurant.reviewCount})',
                          style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text(restaurant.deliveryTime,
                          style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining, size: 14, color: AppTheme.secondary),
                      const SizedBox(width: 4),
                      Text('${restaurant.deliveryFee.toInt()} DA',
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: AppTheme.secondary, fontWeight: FontWeight.w600)),
                    ],
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

// ─── Category Chip ─────────────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip(
      {super.key, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─── Menu Item Tile ─────────────────────────────────────────────────
class MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final Restaurant restaurant;

  const MenuItemTile({super.key, required this.item, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.quantityOf(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: AppTheme.background,
                child: const Icon(Icons.fastfood, color: AppTheme.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.isPopular)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Popular',
                        style: GoogleFonts.cairo(
                            fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                  ),
                Text(item.name,
                    style: GoogleFonts.cairo(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                Text(item.nameAr,
                    style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
                const SizedBox(height: 2),
                Text(item.description,
                    style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('${item.price.toInt()} DA',
                    style: GoogleFonts.cairo(
                        fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          qty == 0
              ? GestureDetector(
                  onTap: () => context.read<CartProvider>().addItem(item, restaurant),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                )
              : Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.read<CartProvider>().decreaseItem(item.id),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primary),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove, size: 16, color: AppTheme.primary),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('$qty',
                          style: GoogleFonts.cairo(
                              fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    ),
                    GestureDetector(
                      onTap: () => context.read<CartProvider>().addItem(item, restaurant),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

// ─── Section Title ──────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.cairo(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: GoogleFonts.cairo(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.secondary)),
          ),
      ],
    );
  }
}
