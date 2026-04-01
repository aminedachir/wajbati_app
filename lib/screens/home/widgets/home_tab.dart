import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../models/providers.dart';
import '../../../models/home_provider.dart';
import '../../../widgets/widgets.dart';
import '../../restaurant/restaurant_screen.dart';
import 'location_selector.dart';

const List<String> categories = [
  'All',
  'Algerian',
  'Italian',
  'Burger',
  'Japanese',
  'Lebanese',
  'Grill',
  'French',
  'Pizza',
  'Shawarma',
];

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => homeProvider.fetchRestaurants(),
      child: CustomScrollView(
        slivers: [
          // ── Sticky Header ──────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            title: const Text('Wajbati'),
            backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8F8F8),
            elevation: 0,
            toolbarHeight: 64,
            flexibleSpace: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    // Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Deliver to',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.textMutedDark
                                  : AppTheme.textMutedLight,
                            ),
                          ),
                          const LocationSelector(),
                        ],
                      ),
                    ),
                    // Notification bell
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_outlined,
                              size: 20, color: AppTheme.secondary),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting + Search ──────────────────────────
                Container(
                  color: isDark ? AppTheme.darkBg : const Color(0xFFF8F8F8),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _GreetingText(),
                      const SizedBox(height: 14),
                      // Search bar
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => homeProvider.setSearchQuery(v),
                          style: GoogleFonts.cairo(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search restaurants or food...',
                            hintStyle: GoogleFonts.cairo(
                              fontSize: 13,
                              color: isDark
                                  ? AppTheme.textMutedDark
                                  : AppTheme.textMutedLight,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark
                                  ? AppTheme.textMutedDark
                                  : AppTheme.textMutedLight,
                              size: 20,
                            ),
                            suffixIcon: homeProvider.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close_rounded,
                                        size: 18,
                                        color: isDark
                                            ? AppTheme.textMutedDark
                                            : AppTheme.textMutedLight),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      homeProvider.setSearchQuery('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Promo Banner ───────────────────────────────
                _PromoBanner(isDark: isDark),
                const SizedBox(height: 48),

                // ── Categories ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Categories',
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.textDark : AppTheme.textLight,
                    ),
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categoryIcons.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final entry = _categoryIcons.entries.elementAt(i);
                      final isSelected =
                          homeProvider.selectedCategory == entry.key;
                      return GestureDetector(
                        onTap: () => homeProvider.setCategory(entry.key),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary
                                    : (isDark
                                        ? AppTheme.darkCard
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? AppTheme.primary.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.key,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.primary
                                    : (isDark
                                        ? AppTheme.textMutedDark
                                        : AppTheme.textMutedLight),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Restaurants Header ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nearby Restaurants',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppTheme.textDark : AppTheme.textLight,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/all-restaurants'),
                        child: Text(
                          'See all',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Restaurant List ────────────────────────────────────
          if (homeProvider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (homeProvider.filteredRestaurants.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_outlined,
                        size: 64,
                        color: (isDark
                                ? AppTheme.textMutedDark
                                : AppTheme.textMutedLight)
                            .withOpacity(0.4)),
                    const SizedBox(height: 12),
                    Text(
                      'No restaurants found',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        color: isDark
                            ? AppTheme.textMutedDark
                            : AppTheme.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final r = homeProvider.filteredRestaurants[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _RestaurantListCard(
                        restaurant: r,
                        isDark: isDark,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/restaurant',
                          arguments: r,
                        ),
                      ),
                    );
                  },
                  childCount: homeProvider.filteredRestaurants.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Category icons map ─────────────────────────────────────────────
const Map<String, String> _categoryIcons = {
  'All': '🍽️',
  'Algerian': '🇩🇿',
  'Burger': '🍔',
  'Pizza': '🍕',
  'Italian': '🍝',
  'Japanese': '🍱',
  'Grill': '🥩',
  'Shawarma': '🌯',
  'Lebanese': '🧆',
  'French': '🥐',
};

// ── Greeting ───────────────────────────────────────────────────────
class _GreetingText extends StatelessWidget {
  const _GreetingText();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Hello, ',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textDark : AppTheme.textLight,
            ),
          ),
          TextSpan(
            text: '${auth.displayName.split(' ').first} 👋',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ── Promo Banner ───────────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  final bool isDark;
  const _PromoBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            right: 0,
            top: -20,
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withOpacity(0.1),
              ),
            ),
          ),
          // Food emoji decoration
          const Positioned(
            right: 20,
            top: -110,
            bottom: 0,
            child: Center(
              child: Text('🔥', style: TextStyle(fontSize: 35)),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'LIMITED OFFER',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Free Delivery Today! 🎉',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use code: WAJBATI',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => (),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Order Now →',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Restaurant List Card ───────────────────────────────────────────
class _RestaurantListCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool isDark;
  final VoidCallback onTap;

  const _RestaurantListCard({
    required this.restaurant,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final auth = context.read<AuthProvider>();
    final isFav = favs.isFavorite(restaurant.id);
    final mutedColor =
        isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

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
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: restaurant.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 160,
                      color: AppTheme.secondary.withOpacity(0.08),
                      child: const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primary),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 160,
                      color: AppTheme.secondary.withOpacity(0.08),
                      child: const Icon(Icons.restaurant,
                          size: 48, color: AppTheme.secondary),
                    ),
                  ),
                ),
                // Open/Closed badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: restaurant.isOpen ? AppTheme.success : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      restaurant.isOpen ? '🟢 Open' : '🔴 Closed',
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
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () =>
                        favs.toggleWithSync(restaurant.id, auth.user?.uid),
                    child: Container(
                      width: 36,
                      height: 36,
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? AppTheme.textDark : AppTheme.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA726).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Color(0xFFFFA726)),
                            const SizedBox(width: 3),
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFA726),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.nameAr,
                    style: GoogleFonts.cairo(fontSize: 12, color: mutedColor),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 13, color: mutedColor),
                      const SizedBox(width: 4),
                      Text(restaurant.deliveryTime,
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: mutedColor)),
                      const SizedBox(width: 16),
                      Icon(Icons.delivery_dining_rounded,
                          size: 13, color: mutedColor),
                      const SizedBox(width: 4),
                      Text('${restaurant.deliveryFee.toInt()} DA',
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: mutedColor)),
                      const SizedBox(width: 16),
                      Icon(Icons.people_outline_rounded,
                          size: 13, color: mutedColor),
                      const SizedBox(width: 4),
                      Text('${restaurant.reviewCount} reviews',
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: mutedColor)),
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
