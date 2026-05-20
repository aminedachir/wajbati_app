import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../models/providers.dart';
import '../../../models/home_provider.dart';
import 'location_selector.dart';

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
    final hp = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => hp.fetchRestaurants(),
      child: CustomScrollView(
        slivers: [
          // ── AppBar ─────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8F8F8),
            elevation: 0,
            toolbarHeight: 64,
            flexibleSpace: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('توصيل إلى',
                              style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppTheme.textMutedDark
                                      : AppTheme.textMutedLight)),
                          const LocationSelector(),
                        ],
                      ),
                    ),
                    _NotifBell(),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting + Search ───────────────────────
                Container(
                  color: isDark ? AppTheme.darkBg : const Color(0xFFF8F8F8),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _GreetingText(),
                      const SizedBox(height: 14),
                      _SearchBar(hp: hp, ctrl: _searchCtrl, isDark: isDark),
                    ],
                  ),
                ),

                // ── Promo Banner ────────────────────────────
                const _PromoBanner(),
                const SizedBox(height: 24),

                // ── Type Filter ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Text('ماذا تبحث عنه اليوم؟',
                      style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppTheme.textDark : AppTheme.textLight)),
                ),

                SizedBox(
                  height: 104,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _TypeCard(
                          label: 'الكل',
                          emoji: '🍽️',
                          color: const Color(0xFF6C63FF),
                          count: hp.countByType('All'),
                          selected: hp.selectedType == 'All' ? 'الكل' : '',
                          isDark: isDark,
                          onTap: () => hp.setType('All')),
                      const SizedBox(width: 12),
                      const SizedBox(width: 12),
                      _TypeCard(
                          label: 'طبخ منزلي',
                          emoji: '🏠',
                          color: Colors.orange,
                          count: hp.countByType('Home Cook'),
                          selected:
                              hp.selectedType == 'Home Cook' ? 'طبخ منزلي' : '',
                          isDark: isDark,
                          onTap: () => hp.setType('Home Cook')),
                      const SizedBox(width: 12),
                      _TypeCard(
                          label: 'مطاعم',
                          emoji: '🍲',
                          color: AppTheme.secondary,
                          count: hp.countByType('Restaurant'),
                          selected:
                              hp.selectedType == 'Restaurant' ? 'مطاعم' : '',
                          isDark: isDark,
                          onTap: () => hp.setType('Restaurant')),
                      const SizedBox(width: 12),
                      _TypeCard(
                          label: 'بيتزا',
                          emoji: '🍕',
                          color: Colors.redAccent,
                          count: hp.countByType('Pizzeria'),
                          selected:
                              hp.selectedType == 'Pizzeria' ? 'بيتزا' : '',
                          isDark: isDark,
                          onTap: () => hp.setType('Pizzeria')),
                      const SizedBox(width: 12),
                      _TypeCard(
                          label: 'أكل سريع',
                          emoji: '🍔',
                          color: AppTheme.primary,
                          count: hp.countByType('Fast Food'),
                          selected:
                              hp.selectedType == 'Fast Food' ? 'أكل سريع' : '',
                          isDark: isDark,
                          onTap: () => hp.setType('Fast Food')),
                      const SizedBox(width: 12),
                      _TypeCard(
                          label: 'حلويات',
                          emoji: '🍰',
                          color: const Color(0xFFE91E8C),
                          count: hp.countByType('Patisserie'),
                          selected:
                              hp.selectedType == 'Patisserie' ? 'حلويات' : '',
                          isDark: isDark,
                          onTap: () => hp.setType('Patisserie')),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Home Cooks Section ──────────────────────
                if (hp.selectedType == 'All' && hp.homeCooks.isNotEmpty) ...[
                  _SectionHeader(
                      title: 'طباخون منزليون مميزون',
                      onTap: () => hp.setType('Home Cook'),
                      isDark: isDark),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: hp.homeCooks.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: SizedBox(
                          width: 260,
                          child: RestaurantCard(
                              restaurant: hp.homeCooks[i],
                              onTap: () => Navigator.pushNamed(
                                  ctx, '/restaurant',
                                  arguments: hp.homeCooks[i])),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // ── Health/Diabetic Section ──────────────────
                if (hp.selectedType == 'All' &&
                    hp.healthFriendlyRestaurants.isNotEmpty) ...[
                  _SectionHeader(
                      title: 'وجبات صحية ولمرضى السكري',
                      onTap: () {},
                      isDark: isDark),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: hp.healthFriendlyRestaurants.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: SizedBox(
                          width: 260,
                          child: RestaurantCard(
                              restaurant: hp.healthFriendlyRestaurants[i],
                              onTap: () => Navigator.pushNamed(
                                  ctx, '/restaurant',
                                  arguments: hp.healthFriendlyRestaurants[i])),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // ── Main List header ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_sectionLabel(hp.selectedType),
                          style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppTheme.textDark
                                  : AppTheme.textLight)),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/all-restaurants'),
                        child: Text('عرض الكل',
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── List ───────────────────────────────────────────
          if (hp.isLoading)
            const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary)))
          else if (hp.filteredRestaurants.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_emptyEmoji(hp.selectedType),
                          style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      Text('لم يتم العثور على نتائج',
                          style: GoogleFonts.cairo(
                              fontSize: 15,
                              color: isDark
                                  ? AppTheme.textMutedDark
                                  : AppTheme.textMutedLight)),
                    ]),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final r = hp.filteredRestaurants[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        height: 280,
                        child: RestaurantCard(
                          restaurant: r,
                          onTap: () => Navigator.pushNamed(ctx, '/restaurant',
                              arguments: r),
                        ),
                      ),
                    );
                  },
                  childCount: hp.filteredRestaurants.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _sectionLabel(String t) => switch (t) {
        'Home Cook' => 'طباخون منزليون بالقرب منك',
        'Restaurant' => 'مطاعم بالقرب منك',
        'Patisserie' => 'محلات حلويات بالقرب منك',
        'Fast Food' => 'أكل سريع بالقرب منك',
        _ => 'أماكن قريبة منك',
      };

  String _emptyEmoji(String t) => switch (t) {
        'Home Cook' => '🏠',
        'Patisserie' => '🍰',
        'Fast Food' => '🍔',
        'Restaurant' => '🍲',
        _ => '🍽️',
      };
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isDark;
  const _SectionHeader(
      {required this.title, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDark : AppTheme.textLight)),
          GestureDetector(
            onTap: onTap,
            child: Text('عرض الكل',
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}

// ── Notification Bell ──────────────────────────────────────────────
class _NotifBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Stack(alignment: Alignment.center, children: [
        const Icon(Icons.notifications_outlined,
            size: 20, color: AppTheme.secondary),
        Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppTheme.primary, shape: BoxShape.circle),
            )),
      ]),
    );
  }
}

// ── Greeting ───────────────────────────────────────────────────────
class _GreetingText extends StatelessWidget {
  const _GreetingText();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: [
        TextSpan(
            text: 'مرحباً، ',
            style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textDark : AppTheme.textLight)),
        TextSpan(
            text: '${auth.displayName.split(' ').first} 👋',
            style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary)),
      ]),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final HomeProvider hp;
  final TextEditingController ctrl;
  final bool isDark;
  const _SearchBar(
      {required this.hp, required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: ctrl,
        onChanged: hp.setSearchQuery,
        style: GoogleFonts.cairo(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'ابحث عن طباخين، مطاعم، حلويات...',
          hintStyle: GoogleFonts.cairo(
              fontSize: 13,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
          prefixIcon: Icon(Icons.search_rounded,
              size: 20,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
          suffixIcon: hp.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 18,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : AppTheme.textMutedLight),
                  onPressed: () {
                    ctrl.clear();
                    hp.setSearchQuery('');
                  })
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ── Promo Banner ───────────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(minHeight: 130),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(children: [
        Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withValues(alpha: 0.1)),
            )),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('عرض محدود',
                      style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          letterSpacing: 1)),
                ),
                const SizedBox(height: 6),
                Text('توصيل مجاني اليوم! 🎉',
                    style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('استخدم الرمز: WAJBATI',
                    style:
                        GoogleFonts.cairo(fontSize: 13, color: Colors.white60)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/cart'),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('اطلب الآن ←',
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ]),
        ),
      ]),
    );
  }
}

// ── Type Card ──────────────────────────────────────────────────────
class _TypeCard extends StatelessWidget {
  final String label, emoji, selected;
  final int count;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeCard(
      {required this.label,
      required this.emoji,
      required this.color,
      required this.count,
      required this.selected,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected ? color : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppTheme.textDark
                                : AppTheme.textLight))),
                Text('$count مكان',
                    style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white70
                            : (isDark
                                ? AppTheme.textMutedDark
                                : AppTheme.textMutedLight))),
              ]),
            ]),
      ),
    );
  }
}

// ── Place Card ─────────────────────────────────────────────────────
