import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import 'restaurant_screen.dart';

class AllRestaurantsScreen extends StatefulWidget {
  final String title;
  final List<Restaurant> initialRestaurants;

  const AllRestaurantsScreen({
    super.key,
    this.title = 'جميع المطاعم',
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
              const PopupMenuItem(value: 'Default', child: Text('الافتراضي')),
              const PopupMenuItem(
                  value: 'Famous', child: Text('الأكثر تقييماً')),
              const PopupMenuItem(
                  value: 'Nearby', child: Text('الأقرب / الأسرع')),
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
                      'ترتيب حسب: $_sortBy',
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
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      height: 280,
                      child: RestaurantCard(
                        restaurant: r,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantScreen(restaurant: r),
                          ),
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

