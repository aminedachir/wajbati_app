import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../models/providers.dart';
import '../theme/app_theme.dart';
import 'restaurant_frame.dart';
import 'restaurant_header.dart';
import 'restaurant_stats.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;
  final double screenScale;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    required this.screenScale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RestaurantFrame(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildImage()),
                Padding(
                  padding: EdgeInsets.all(12 * screenScale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RestaurantHeader(
                        name: restaurant.name,
                        nameAr: restaurant.nameAr,
                        isOpen: restaurant.isOpen,
                        screenScale: screenScale,
                      ),
                      SizedBox(height: 8 * screenScale),
                      RestaurantStats(
                        rating: restaurant.rating,
                        reviewCount: restaurant.reviewCount,
                        deliveryTime: restaurant.deliveryTime,
                        screenScale: screenScale,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildFavoriteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: CachedNetworkImage(
        imageUrl: restaurant.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppTheme.secondary.withOpacity(0.1),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppTheme.secondary.withOpacity(0.1),
          child:
              const Icon(Icons.restaurant, size: 48, color: AppTheme.secondary),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Selector<FavoritesProvider, bool>(
        selector: (context, favs) => favs.isFavorite(restaurant.id),
        builder: (context, isFav, child) {
          return GestureDetector(
            onTap: () =>
                context.read<FavoritesProvider>().toggle(restaurant.id),
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
      ),
    );
  }
}
