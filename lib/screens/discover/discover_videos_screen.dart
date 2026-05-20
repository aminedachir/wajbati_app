import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../models/home_provider.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../restaurant/restaurant_screen.dart';

class DiscoverVideosScreen extends StatelessWidget {
  const DiscoverVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final restaurantsWithVideos = homeProvider.restaurants
        .where((r) => r.videoUrl != null && r.videoUrl!.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: restaurantsWithVideos.isEmpty
          ? _buildEmpty()
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: restaurantsWithVideos.length,
              itemBuilder: (context, index) {
                return _VideoPlayerItem(
                    restaurant: restaurantsWithVideos[index]);
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Scaffold(
      appBar: AppBar(
        title: Text('الفيديوهات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded,
                size: 80, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('لا توجد فيديوهات حالياً',
                style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('أضف رابط فيديو للمطعم من لوحة التحكم',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ── Video Item ─────────────────────────────────────────────────────────
class _VideoPlayerItem extends StatefulWidget {
  final Restaurant restaurant;
  const _VideoPlayerItem({required this.restaurant});

  @override
  State<_VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<_VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isPlaying = true;
  bool _isFollowing = false;
  int _likes = 1200;
  bool _liked = false;
  final int _comments = 84;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    setState(() {
      _initialized = false;
      _hasError = false;
    });
    _controller = VideoPlayerController.network(widget.restaurant.videoUrl!)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _controller.setLooping(true);
          _controller.play();
        }
      }).catchError((error) {
        debugPrint('Video player error: $error');
        if (mounted) {
          setState(() => _hasError = true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final restaurantName =
        restaurant.nameAr.isNotEmpty ? restaurant.nameAr : restaurant.name;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Video / Placeholder ───────────────────────────────────
        GestureDetector(
          onTap: _togglePlay,
          child: VisibilityDetector(
            key: Key('video_${widget.restaurant.id}'),
            onVisibilityChanged: (visibilityInfo) {
              if (visibilityInfo.visibleFraction == 0 && mounted) {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                  setState(() => _isPlaying = false);
                }
              }
            },
            child: _initialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_hasError) ...[
                            const CircularProgressIndicator(
                                color: AppTheme.primary),
                            const SizedBox(height: 16),
                            Text(
                              'جاري تحميل الفيديو...',
                              style: GoogleFonts.cairo(color: Colors.white70),
                            ),
                          ] else ...[
                            const Icon(Icons.error_outline_rounded,
                                color: Colors.redAccent, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              'تعذر تحميل الفيديو',
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تأكد من اتصالك بالإنترنت',
                              style: GoogleFonts.cairo(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton.icon(
                                onPressed: _initController,
                                icon:
                                    const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('إعادة المحاولة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  textStyle: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ),

        // ── Pause icon overlay ────────────────────────────────────
        if (!_isPlaying)
          const Center(
            child: Icon(Icons.play_circle_fill_rounded,
                size: 72, color: Colors.white70),
          ),

        // ── Dark gradient bottom ──────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.55,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // ── Right sidebar: actions ────────────────────────────────
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              _SideAction(
                icon: _liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: _formatCount(_likes),
                color: _liked ? Colors.red : Colors.white,
                onTap: () => setState(() {
                  _liked = !_liked;
                  _likes += _liked ? 1 : -1;
                }),
              ),
              const SizedBox(height: 20),
              _SideAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: _formatCount(_comments),
                color: Colors.white,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _SideAction(
                icon: Icons.share_rounded,
                label: 'نشر',
                color: Colors.white,
                onTap: () {},
              ),
            ],
          ),
        ),

        // ── Bottom info ───────────────────────────────────────────
        Positioned(
          bottom: 80,
          left: 16,
          right: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chef row
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    backgroundImage: restaurant.imageUrl.isNotEmpty
                        ? NetworkImage(restaurant.imageUrl)
                        : null,
                    child: restaurant.imageUrl.isEmpty
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      restaurantName,
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _isFollowing = !_isFollowing),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isFollowing ? Colors.white24 : AppTheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Text(
                        _isFollowing ? 'يُتابَع' : 'متابعة',
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dish title
              Text(
                restaurant.category.isNotEmpty
                    ? restaurant.category
                    : restaurantName,
                style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
                maxLines: 2,
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                restaurant.address.isNotEmpty
                    ? restaurant.address
                    : 'اكتشف أشهى المأكولات العربية الأصيلة من مطعمنا مباشرة.',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              // Order button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            RestaurantScreen(restaurant: restaurant)),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined,
                      size: 18, color: Colors.white),
                  label: Text('اطلب الآن',
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Safe area top padding ─────────────────────────────────
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(height: 50),
        ),
      ],
    );
  }
}

// ── Side Action Button ──────────────────────────────────────────────
class _SideAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SideAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
