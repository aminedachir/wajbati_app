import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors from logo
  static const Color primary = Color(0xFFE8231A);   // Red
  static const Color secondary = Color(0xFF1B4FA8); // Blue
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF5F6FA);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF8898AA);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color success = Color(0xFF2DCE89);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: secondary,
          background: background,
        ),
        scaffoldBackgroundColor: background,
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
            color: textMuted,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: white,
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
          fillColor: white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          hintStyle: GoogleFonts.cairo(color: textMuted, fontSize: 14),
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
      );
}
