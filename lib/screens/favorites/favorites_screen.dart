import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../models/providers.dart';
import '../../models/home_provider.dart';
import '../restaurant/restaurant_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoritesProvider, HomeProvider>(
      builder: (context, favs, homeProvider, child) {
        final favoriteRestaurants = homeProvider.restaurants
            .where((r) => favs.isFavorite(r.id))
            .toList();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final mutedColor = AppTheme.textMuted(context);
        final auth = context.read<AuthProvider>();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'المفضلة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
          body: homeProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary))
              : favoriteRestaurants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 72, color: mutedColor.withValues(alpha: 0.35)),
                          const SizedBox(height: 16),
                          Text('لا توجد مفضلات بعد',
                              style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppTheme.textDark
                                      : AppTheme.textLight)),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'اضغط على أيقونة ❤️ في صفحة المطعم لحفظه هنا',
                              style: GoogleFonts.cairo(
                                  fontSize: 13, color: mutedColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: favoriteRestaurants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final r = favoriteRestaurants[i];
                        return _FavoriteCard(
                          restaurant: r,
                          isDark: isDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RestaurantScreen(restaurant: r),
                            ),
                          ),
                          onRemove: () =>
                              favs.toggleWithSync(r.id, auth.user?.uid),
                        );
                      },
                    ),
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final dynamic restaurant;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.restaurant,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor =
        isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(18)),
              child: CachedNetworkImage(
                imageUrl: restaurant.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 110,
                  height: 110,
                  color: AppTheme.secondary.withValues(alpha: 0.08),
                  child:
                      const Icon(Icons.restaurant, color: AppTheme.secondary),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 110,
                  height: 110,
                  color: AppTheme.secondary.withValues(alpha: 0.08),
                  child:
                      const Icon(Icons.restaurant, color: AppTheme.secondary),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.nameAr.isNotEmpty ? restaurant.nameAr : restaurant.name,
                      style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppTheme.textDark : AppTheme.textLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(restaurant.nameAr,
                        style:
                            GoogleFonts.cairo(fontSize: 12, color: mutedColor)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFFFA726)),
                        const SizedBox(width: 3),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFA726)),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time_rounded,
                            size: 12, color: mutedColor),
                        const SizedBox(width: 3),
                        Text(restaurant.deliveryTime,
                            style: GoogleFonts.cairo(
                                fontSize: 12, color: mutedColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen
                            ? AppTheme.success.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        restaurant.isOpen ? 'مفتوح' : 'مغلق',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              restaurant.isOpen ? AppTheme.success : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Remove button
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      size: 17, color: AppTheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
