import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import 'restaurant_screen.dart';

class AllRestaurantsScreen extends StatefulWidget {
  final String title;
  final List<Restaurant> initialRestaurants;

  const AllRestaurantsScreen({
    super.key,
    this.title = 'All Restaurants',
    required this.initialRestaurants,
  });

  @override
  State<AllRestaurantsScreen> createState() => _AllRestaurantsScreenState();
}

class _AllRestaurantsScreenState extends State<AllRestaurantsScreen> {
  late List<Restaurant> _restaurants;
  String _sortBy = 'Default';

  @override
  void initState() {
    super.initState();
    _restaurants = List.from(widget.initialRestaurants);
  }

  void _sortRestaurants(String criteria) {
    setState(() {
      _sortBy = criteria;
      if (criteria == 'Famous') {
        _restaurants.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (criteria == 'Nearby') {
        _restaurants.sort((a, b) {
          int timeA = int.tryParse(a.deliveryTime.split('-').first) ?? 999;
          int timeB = int.tryParse(b.deliveryTime.split('-').first) ?? 999;
          return timeA.compareTo(timeB);
        });
      } else {
        _restaurants = List.from(widget.initialRestaurants);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: _sortRestaurants,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Default', child: Text('Default')),
              const PopupMenuItem(
                  value: 'Famous', child: Text('Famous (Top Rated)')),
              const PopupMenuItem(
                  value: 'Nearby', child: Text('Nearby (Fastest)')),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (_sortBy != 'Default')
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Sorted by: $_sortBy',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _sortRestaurants('Default'),
                      child: const Icon(Icons.close,
                          size: 14, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final r = _restaurants[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _RestaurantListCard(
                      restaurant: r,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantScreen(restaurant: r),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _restaurants.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantListCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const _RestaurantListCard({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed height image to avoid layout errors in SliverList
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: restaurant.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 160,
                  color: AppTheme.secondary.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 160,
                  color: AppTheme.secondary.withOpacity(0.1),
                  child: const Icon(Icons.restaurant, size: 48, color: AppTheme.secondary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    restaurant.nameAr,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFA726)),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.rating}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        ' (${restaurant.reviewCount})',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.deliveryTime,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
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
