import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class IntroVideoWidget extends StatefulWidget {
  final String videoUrl;
  final String title;

  const IntroVideoWidget({
    super.key,
    required this.videoUrl,
    this.title = 'تعرف علينا',
  });

  @override
  State<IntroVideoWidget> createState() => _IntroVideoWidgetState();
}

class _IntroVideoWidgetState extends State<IntroVideoWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return VisibilityDetector(
      key: Key('intro_video_${widget.videoUrl}'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0) {
          if (_isInitialized && _controller.value.isPlaying) {
            _controller.pause();
            if (mounted) setState(() {});
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          if (!_controller.value.isPlaying)
            const Icon(Icons.play_circle_filled, size: 64, color: Colors.white70),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
