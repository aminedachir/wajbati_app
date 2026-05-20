import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantStats extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final double screenScale;

  const RestaurantStats({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.screenScale,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = (16 * screenScale).clamp(14.0, 20.0);

    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded,
                size: iconSize, color: const Color(0xFFFFA726)),
            SizedBox(width: 4 * screenScale),
            Text(
              rating.toStringAsFixed(1),
              style: GoogleFonts.cairo(
                fontSize: (13 * screenScale).clamp(12.0, 14.0),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              ' ($reviewCount)',
              style: GoogleFonts.cairo(
                fontSize: (12 * screenScale).clamp(11.0, 13.0),
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time,
                size: (14 * screenScale).clamp(12.0, 16.0),
                color: Theme.of(context).textTheme.bodyMedium?.color),
            SizedBox(width: 3 * screenScale),
            Text(
              deliveryTime,
              style: GoogleFonts.cairo(
                fontSize: (12 * screenScale).clamp(11.0, 13.0),
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
