import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/home_provider.dart';
import '../../../models/algerian_wilayas.dart';

class LocationSelector extends StatelessWidget {
  const LocationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showWilayaBottomSheet(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded,
              size: 16, color: AppTheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text('${homeProvider.selectedWilaya}، ج',
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textDark : AppTheme.textLight),
                overflow: TextOverflow.ellipsis),
          ),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
        ],
      ),
    );
  }

  void _showWilayaBottomSheet(BuildContext context) {
    final homeProvider = context.read<HomeProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اختر الولاية',
                style: GoogleFonts.cairo(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: algerianWilayas.length,
                itemBuilder: (context, index) {
                  final wilaya = algerianWilayas[index];
                  return ListTile(
                    leading: const Icon(Icons.location_city, color: AppTheme.primary),
                    title: Text(wilaya['name'] ?? ''),
                    subtitle: Text(wilaya['nameAr'] ?? ''),
                    onTap: () {
                      Navigator.pop(context);
                      homeProvider.setWilaya(wilaya['name']!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
