import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantInfo extends StatelessWidget {
  final String name;
  final String nameAr;
  final double rating;
  final int reviewCount;
  final String deliveryTime;

  const RestaurantInfo({
    super.key,
    required this.name,
    required this.nameAr,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontScale = screenWidth < 360
        ? 0.9
        : screenWidth < 600
            ? 1.0
            : 1.1;
    final iconSize = (16 * fontScale).clamp(14.0, 20.0);

    return Padding(
      padding: EdgeInsets.all((12 * fontScale).clamp(10.0, 14.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: (15 * fontScale).clamp(14.0, 18.0),
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            nameAr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: (11 * fontScale).clamp(10.0, 13.0),
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 8 * fontScale),
          Row(
            children: [
              Icon(Icons.star_rounded,
                  size: iconSize, color: const Color(0xFFFFA726)),
              SizedBox(width: 4 * fontScale),
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.cairo(
                  fontSize: (13 * fontScale).clamp(12.0, 14.0),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                ' ($reviewCount)',
                style: GoogleFonts.cairo(
                  fontSize: (12 * fontScale).clamp(11.0, 13.0),
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time,
                  size: (14 * fontScale).clamp(12.0, 16.0),
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              SizedBox(width: 3 * fontScale),
              Text(
                deliveryTime,
                style: GoogleFonts.cairo(
                  fontSize: (12 * fontScale).clamp(11.0, 13.0),
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
