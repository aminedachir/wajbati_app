import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/providers.dart';

// ─── Responsive Helper (Optimized) ───────────────────────────────────
class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static bool isSmallPhone(BuildContext context) => width(context) < 360;
}

// ─── Restaurant Card (Modern & Premium) ──────────────────────────
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: CachedNetworkImage(
                        imageUrl: restaurant.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppTheme.secondary.withValues(alpha: 0.1),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.secondary.withValues(alpha: 0.1),
                          child: const Icon(Icons.restaurant, size: 40, color: AppTheme.secondary),
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Status & Favorite
                  Positioned(top: 12, left: 12, child: _StatusBadge(isOpen: restaurant.isOpen)),
                  Positioned(top: 10, right: 10, child: _FavoriteButton(restaurantId: restaurant.id)),
                ],
              ),
            ),
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          restaurant.nameAr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12, 
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const _RatingAndTimeRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Menu Item Tile (Refined & Responsive) ──────────────────────
class MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final Restaurant restaurant;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final int quantity;

  const MenuItemTile({
    super.key,
    required this.item,
    required this.restaurant,
    this.onAdd,
    this.onRemove,
    this.quantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSmall = Responsive.isSmallPhone(context);
    final double imageSize = isSmall ? 80.0 : 100.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[100]),
                  errorWidget: (_, __, ___) => const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
              if (item.isPopular)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11, 
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (item.isDiabeticFriendly) 
                        const _HealthBadge(label: 'مناسب للسكري', color: Colors.green, icon: Icons.health_and_safety_outlined),
                      if (item.isHealthOriented && !item.isDiabeticFriendly) 
                        const _HealthBadge(label: 'وجبة صحية', color: AppTheme.success),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.price.toInt()} د.ج',
                      style: GoogleFonts.cairo(
                        fontSize: 16, 
                        fontWeight: FontWeight.w800, 
                        color: AppTheme.primary,
                      ),
                    ),
                    _QuantityControls(quantity: quantity, onAdd: onAdd, onRemove: onRemove),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets (Private - No Rebuilds) ──────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? AppTheme.success : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? 'مفتوح' : 'مغلق',
        style: GoogleFonts.cairo(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _HealthBadge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
                fontSize: 9, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final String restaurantId;
  const _FavoriteButton({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Selector<FavoritesProvider, bool>(
      selector: (context, favs) => favs.isFavorite(restaurantId),
      builder: (context, isFav, child) {
        return GestureDetector(
          onTap: () => context.read<FavoritesProvider>().toggle(restaurantId),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
        );
      },
    );
  }
}

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'مميز',
        style: TextStyle(
            fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RatingAndTimeRow extends StatelessWidget {
  const _RatingAndTimeRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFA726)),
        SizedBox(width: 4),
        Text('4.8',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(' (320)', style: TextStyle(fontSize: 12)),
        Spacer(),
        Icon(Icons.access_time, size: 14),
        SizedBox(width: 3),
        Text('25-35 دقيقة', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  const _QuantityControls({
    required this.quantity,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text('$quantity'),
        ),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primary),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove, color: AppTheme.primary, size: 16),
          ),
        ),
      ],
    );
  }
}

// ─── Category Chip ─────────────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.primary : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (Theme.of(context).brightness == Brightness.light
                    ? AppTheme.lightDivider
                    : AppTheme.darkDivider),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

// ─── Section Title ──────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary)),
          ),
      ],
    );
  }
}
