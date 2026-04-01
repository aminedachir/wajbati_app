import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? AppTheme.primary
                  : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppTheme.primary
                    : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
