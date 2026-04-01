import 'package:flutter/material.dart';
import 'theme_utils.dart';
import '../theme/app_theme.dart';

Color textMuted(BuildContext context) {
  return ThemeNotifier.isDarkMode(context)
      ? AppTheme.textMutedDark
      : AppTheme.textMutedLight;
}

Color text(BuildContext context) {
  return ThemeNotifier.isDarkMode(context)
      ? AppTheme.textDark
      : AppTheme.textLight;
}

Color cardBg(BuildContext context) {
  return ThemeNotifier.isDarkMode(context)
      ? AppTheme.darkCard
      : AppTheme.lightCard;
}

Color bg(BuildContext context) {
  return ThemeNotifier.isDarkMode(context) ? AppTheme.darkBg : AppTheme.lightBg;
}

Color dividerColor(BuildContext context) {
  return ThemeNotifier.isDarkMode(context)
      ? AppTheme.darkDivider
      : AppTheme.lightDivider;
}
