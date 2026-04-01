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

// ─── Restaurant Card (Smooth & Low-Resource) ──────────────────────────
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
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
            // Image Section (Optimized with Caching)
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: restaurant.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.secondary.withOpacity(0.1),
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.secondary.withOpacity(0.1),
                        child: const Icon(Icons.restaurant,
                            size: 48, color: AppTheme.secondary),
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _StatusBadge(isOpen: restaurant.isOpen),
                  ),
                  // Favorite Button (Using Selector to prevent full card rebuilds)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteButton(restaurantId: restaurant.id),
                  ),
                ],
              ),
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    restaurant.nameAr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const _RatingAndTimeRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Menu Item Tile (Appwrite & Database Ready) ──────────────────────
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
    // Determine image size once per build
    final bool isSmall = Responsive.isSmallPhone(context);
    final double imageSize = isSmall ? 60.0 : 72.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? AppTheme.lightDivider
              : AppTheme.darkDivider,
        ),
      ),
      child: Row(
        children: [
          // Smooth Image with Caching
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[100]),
              errorWidget: (context, url, error) => const Icon(Icons.fastfood),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.isPopular) _PopularBadge(),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(item.nameAr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                // Dynamic Price (Ready for Database)
                Text(
                  '${item.price.toInt()} DA',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppTheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QuantityControls(
              quantity: quantity, onAdd: onAdd, onRemove: onRemove),
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
        isOpen ? 'Open' : 'Closed',
        style: GoogleFonts.cairo(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
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
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Popular',
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
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFA726)),
        const SizedBox(width: 4),
        const Text('4.8',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const Text(' (320)', style: TextStyle(fontSize: 12)),
        const Spacer(),
        const Icon(Icons.access_time, size: 14),
        const SizedBox(width: 3),
        const Text('25-35 min', style: TextStyle(fontSize: 12)),
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
