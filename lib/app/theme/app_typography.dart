import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTypography {
  static TextTheme get textTheme => TextTheme(
        displayLarge:
            GoogleFonts.cairo(fontSize: 57, fontWeight: FontWeight.w800),
        displayMedium:
            GoogleFonts.cairo(fontSize: 45, fontWeight: FontWeight.w700),
        displaySmall:
            GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.w700),
        headlineLarge:
            GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium:
            GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall:
            GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge:
            GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.tajawal(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      );
}
