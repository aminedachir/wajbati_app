import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class RestaurantHeader extends StatelessWidget {
  final String name;
  final String nameAr;
  final bool isOpen;
  final double screenScale;

  const RestaurantHeader({
    super.key,
    required this.name,
    required this.nameAr,
    required this.isOpen,
    required this.screenScale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            fontSize: (15 * screenScale).clamp(14.0, 18.0),
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2 * screenScale),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 6 * screenScale, vertical: 2 * screenScale),
              decoration: BoxDecoration(
                color: isOpen ? AppTheme.success : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOpen ? 'Open' : 'Closed',
                style: GoogleFonts.cairo(
                  fontSize: (10 * screenScale).clamp(9.0, 12.0),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8 * screenScale),
            Expanded(
              child: Text(
                nameAr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: (11 * screenScale).clamp(10.0, 13.0),
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
