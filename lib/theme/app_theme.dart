import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors from logo
  static const Color primary = Color(0xFFE8231A); // Red
  static const Color secondary = Color(0xFF1B4FA8); // Blue
  static const Color white = Colors.white;
  static const Color lightBg = Color(0xFFF5F6FA);
  static const Color darkBg = Color(0xFF0F0F23);
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color textLight = Color(0xFF1A1A2E);
  static const Color textDark = Color(0xFFEFEFF1);
  static const Color textMutedLight = Color(0xFF8898AA);
  static const Color textMutedDark = Color(0xFF9CA3AF);
  static const Color lightDivider = Color(0xFFEEEEEE);
  static const Color darkDivider = Color(0xFF2A2A3E);
  static const Color success = Color(0xFF2DCE89);

  // Added generic getter for backward compatibility or simple use
  static Color textMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textMutedLight
        : textMutedDark;
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      background: lightBg,
    ),
    scaffoldBackgroundColor: lightBg,
    textTheme: GoogleFonts.cairoTextTheme().copyWith(
      displayLarge: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textLight,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textLight,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textLight,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMutedLight,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightCard,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textLight,
      ),
      iconTheme: const IconThemeData(color: textLight),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: lightDivider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.cairo(color: textMutedLight, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: lightCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      secondary: secondary,
      background: darkBg,
    ),
    scaffoldBackgroundColor: darkBg,
    textTheme: GoogleFonts.cairoTextTheme().copyWith(
      displayLarge: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMutedDark,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkCard,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      iconTheme: const IconThemeData(color: textDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkDivider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.cairo(color: textMutedDark, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: darkCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
