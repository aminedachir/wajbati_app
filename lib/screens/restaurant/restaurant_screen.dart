import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/providers.dart';
import '../../models/restaurant_review.dart';
import '../cart/cart_screen.dart';
import '../../widgets/intro_video_widget.dart';
import '../../widgets/widgets.dart';
import '../../utils/appwrite_service.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantScreen({super.key, required this.restaurant});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  List<MenuItem> _menu = [];
  List<RestaurantReview> _reviews = [];
  bool _loadingMenu = true;
  bool _loadingReviews = true;
  String _selectedCategory = 'الكل';
  bool _showHealthOnly = false;

  @override
  void initState() {
    super.initState();
    _loadMenu();
    _loadReviews();
  }

  Future<void> _loadMenu() async {
    final items = await AppwriteService.getMenuItems(widget.restaurant.id);

    // Inject mock diabetic meals for testing if not present and NOT a Patisserie
    final isNotPatisserie = widget.restaurant.type != 'Patisserie';

    if (isNotPatisserie && !items.any((i) => i.category == 'وجبات السكري')) {
      items.addAll([
        const MenuItem(
          id: 'diabetic_mock_1',
          name: 'سلطة البقوليات العضوية',
          nameAr: 'سلطة البقوليات العضوية',
          description: 'حمص، عدس، كينوا مع خضروات طازجة وزيت زيتون بكر ممتاز.',
          price: 450,
          category: 'وجبات السكري',
          imageUrl:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=2070',
          isDiabeticFriendly: true,
        ),
        const MenuItem(
          id: 'diabetic_mock_2',
          name: 'سلمون مشوي بالأعشاب',
          nameAr: 'سلمون مشوي بالأعشاب',
          description:
              'قطعة سلمون فاخرة مشوية مع أعشاب برية تقدم مع خضروات موسمية.',
          price: 850,
          category: 'وجبات السكري',
          imageUrl:
              'https://images.unsplash.com/photo-1485921325833-c519f76c4927?q=80&w=1964',
          isDiabeticFriendly: true,
        ),
        const MenuItem(
          id: 'diabetic_mock_3',
          name: 'طاجين خضروات قليل الدسم',
          nameAr: 'طاجين خضروات قليل الدسم',
          description:
              'مزيج من الخضروات الموسمية المطهوة ببطء مع توابل طبيعية بدون زيوت مهدرجة.',
          price: 550,
          category: 'وجبات السكري',
          imageUrl:
              'https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=2071',
          isDiabeticFriendly: true,
        ),
        const MenuItem(
          id: 'diabetic_mock_4',
          name: 'دجاج مشوي بتتبيلة الليمون',
          nameAr: 'دجاج مشوي بتتبيلة الليمون',
          description:
              'صدر دجاج مشوي غني بالبروتين مع تتبيلة الليمون والثوم المنعشة.',
          price: 680,
          category: 'وجبات السكري',
          imageUrl:
              'https://images.unsplash.com/photo-1532550907401-a500c9a57435?q=80&w=2070',
          isDiabeticFriendly: true,
        ),
        const MenuItem(
          id: 'diet_plan_1',
          name: 'طاجين زيتون صحي',
          nameAr: 'طاجين زيتون صحي (قليل الملح)',
          description: 'طاجين زيتون تقليدي محضر بطريقة صحية للحمية.',
          price: 600,
          category: 'حمية وغذاء صحي',
          imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=2070',
          isHealthOriented: true,
        ),
        const MenuItem(
          id: 'diet_plan_2',
          name: 'كسكسي قمح كامل',
          nameAr: 'كسكسي بالخضار (قمح كامل)',
          description: 'كسكسي تقليدي مصنوع من القمح الكامل الغني بالألياف.',
          price: 750,
          category: 'حمية وغذاء صحي',
          imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=2070',
          isHealthOriented: true,
        ),
        const MenuItem(
          id: 'protein_plan_1',
          name: 'وجبة البروتين العالية',
          nameAr: 'صدر دجاج مع عدس',
          description: 'وجبة متكاملة غنية بالبروتين للرياضيين.',
          price: 900,
          category: 'رياضة وبروتين',
          imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=2080',
          isHealthOriented: true,
        ),
        const MenuItem(
          id: 'gluten_free_1',
          name: 'خبز الدار بدون غلوتين',
          nameAr: 'خبز الدار (بدون غلوتين)',
          description: 'خبز منزلي تقليدي محضر بدقيق خاص لمرضى الحساسية.',
          price: 300,
          category: 'طلبات خاصة وحساسية',
          imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=2072',
          isHealthOriented: true,
        ),
        const MenuItem(
          id: 'vegetarian_1',
          name: 'شربة فريك نباتية',
          nameAr: 'شربة فريك (نباتية بالكامل)',
          description: 'شربة تقليدية غنية بالخضروات وبدون أي لحوم.',
          price: 400,
          category: 'نباتي وصحي',
          imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=2071',
          isHealthOriented: true,
        ),
      ]);
    }

    if (mounted) {
      setState(() {
        _menu = items;
        _loadingMenu = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final docs = await AppwriteService.getReviews(widget.restaurant.id);
      if (mounted) {
        setState(() {
          _reviews = docs.map((doc) {
            final d = doc.data;
            return RestaurantReview(
              id: doc.$id,
              restaurantId: widget.restaurant.id,
              userId: d['userId'] ?? '',
              userName: d['userName'] ?? 'مجهول',
              comment: d['comment'] ?? '',
              rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
              date: DateTime.tryParse(d['createdAt'] ?? '') ?? DateTime.now(),
            );
          }).toList();
          _loadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  List<String> get _menuCategories {
    final cats = _menu.map((i) => i.category).toSet().toList()..sort();
    return ['الكل', ...cats];
  }

  List<MenuItem> get _filteredMenu {
    List<MenuItem> list = _menu;
    if (_selectedCategory != 'الكل') {
      list = list.where((i) => i.category == _selectedCategory).toList();
    }
    if (_showHealthOnly) {
      list = list
          .where((i) => i.isDiabeticFriendly || i.isHealthOriented)
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final favs = context.watch<FavoritesProvider>();
    final auth = context.read<AuthProvider>();
    final isFav = favs.isFavorite(widget.restaurant.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero AppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: isDark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                child: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  // Use toggleWithSync to persist favorites
                  onPressed: () => favs.toggleWithSync(
                    widget.restaurant.id,
                    auth.user?.uid,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.restaurant.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        color: AppTheme.secondary.withValues(alpha: 0.1)),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.secondary.withValues(alpha: 0.1),
                      child: const Icon(Icons.restaurant,
                          size: 60, color: AppTheme.secondary),
                    ),
                  ),
                  if (widget.restaurant.videoUrl != null)
                    Positioned.fill(
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.play_circle_fill,
                              size: 64, color: Colors.white70),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.black,
                              builder: (_) => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: IntroVideoWidget(
                                    videoUrl: widget.restaurant.videoUrl!),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Restaurant Info ──────────────────────────────────
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
                            Text(widget.restaurant.nameAr.isNotEmpty ? widget.restaurant.nameAr : widget.restaurant.name,
                                style: GoogleFonts.cairo(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppTheme.textDark
                                        : AppTheme.textLight)),
                            Text(widget.restaurant.nameAr,
                                style: GoogleFonts.cairo(
                                    fontSize: 14, color: mutedColor)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: AppTheme.success),
                            const SizedBox(width: 4),
                            Text(
                              widget.restaurant.rating.toStringAsFixed(1),
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.success),
                            ),
                            Text(' (${widget.restaurant.reviewCount})',
                                style: GoogleFonts.cairo(
                                    fontSize: 12, color: mutedColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                          icon: Icons.access_time_rounded,
                          label: widget.restaurant.deliveryTime,
                          isDark: isDark),
                      _InfoChip(
                          icon: Icons.delivery_dining_rounded,
                          label: '${widget.restaurant.deliveryFee.toInt()} DA',
                          isDark: isDark),
                      _InfoChip(
                          icon: widget.restaurant.isOpen
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          label: widget.restaurant.isOpen ? 'مفتوح' : 'مغلق',
                          isDark: isDark,
                          color: widget.restaurant.isOpen
                              ? AppTheme.success
                              : Colors.red),
                    ],
                  ),
                  if (widget.restaurant.address.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 14, color: mutedColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(widget.restaurant.address,
                              style: GoogleFonts.cairo(
                                  fontSize: 13, color: mutedColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('القائمة',
                          style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppTheme.textDark
                                  : AppTheme.textLight)),
                      FilterChip(
                        label: Text('وجبات صحية',
                            style: GoogleFonts.cairo(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        selected: _showHealthOnly,
                        onSelected: (v) => setState(() => _showHealthOnly = v),
                        selectedColor: AppTheme.success.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Category Filter ──────────────────────────────────
          if (!_loadingMenu && _menu.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _menuCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _menuCategories[i];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark ? AppTheme.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : (isDark
                                    ? AppTheme.darkDivider
                                    : AppTheme.lightDivider),
                          ),
                        ),
                        child: Text(cat,
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : mutedColor)),
                      ),
                    );
                  },
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Menu Items ───────────────────────────────────────
          if (_loadingMenu)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary)),
              ),
            )
          else if (_menu.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.restaurant_menu_outlined,
                          size: 56, color: mutedColor.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text('لا توجد عناصر في القائمة حالياً',
                          style: GoogleFonts.cairo(
                              fontSize: 15, color: mutedColor)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _filteredMenu[index];
                    final qty = cart.quantityOf(item.id);
                    return MenuItemTile(
                      item: item,
                      restaurant: widget.restaurant,
                      quantity: qty,
                      onAdd: () => context
                          .read<CartProvider>()
                          .addItem(item, widget.restaurant),
                      onRemove: () =>
                          context.read<CartProvider>().decreaseItem(item.id),
                    );
                  },
                  childCount: _filteredMenu.length,
                ),
              ),
            ),

          // ── Reviews Section ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                children: [
                  Text('التقييمات',
                      style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppTheme.textDark : AppTheme.textLight)),
                  const SizedBox(width: 8),
                  if (!_loadingReviews)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${_reviews.length}',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary)),
                    ),
                ],
              ),
            ),
          ),

          if (_loadingReviews)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary, strokeWidth: 2)),
              ),
            )
          else if (_reviews.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDark
                            ? AppTheme.darkDivider
                            : AppTheme.lightDivider),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 40, color: mutedColor.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      Text('لا توجد تقييمات بعد',
                          style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: mutedColor)),
                      Text('كن أول من يقيم!',
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: mutedColor)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _ReviewCard(review: _reviews[index], isDark: isDark),
                  childCount: _reviews.length,
                ),
              ),
            ),
        ],
      ),

      // ── View Cart Bottom Bar ─────────────────────────────────
      bottomSheet: cart.itemCount > 0
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen())),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${cart.itemCount} وجبة',
                          style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                      Text('عرض السلة',
                          style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      Text('${cart.total.toInt()} د.ج',
                          style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// ── Review Card ────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final RestaurantReview review;
  final bool isDark;
  const _ReviewCard({required this.review, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(
                      _formatDate(review.date),
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.textMutedDark
                              : AppTheme.textMutedLight),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: const Color(0xFFFFA726),
                  );
                }),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: isDark ? AppTheme.textDark : AppTheme.textLight,
                    height: 1.5)),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ── Info Chip ──────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;
  const _InfoChip(
      {required this.icon,
      required this.label,
      required this.isDark,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c =
        color ?? (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 12, fontWeight: FontWeight.w600, color: c)),
        ],
      ),
    );
  }
}
