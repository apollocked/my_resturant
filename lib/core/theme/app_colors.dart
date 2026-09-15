import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE8611A);
  static const Color primarySoft = Color(0xFFFFF0E8);

  static Color softSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3A2B24)
          : primarySoft;

  /// Warm layered neutral scale — no pure white, subtle sand/warm tint so
  /// surfaces feel soft and contemporary instead of stark.
  static const Color background = Color(0xFFF5F1EB);
  static const Color surface = Color(0xFFFDFBF8);
  static const Color surfaceLowest = Color(0xFFFFFDFA);
  static const Color surfaceContainerLow = Color(0xFFF9F5F0);
  static const Color surfaceContainer = Color(0xFFF4EFE9);
  static const Color surfaceContainerHigh = Color(0xFFEFE9E2);
  static const Color surfaceContainerHighest = Color(0xFFE9E2DA);
  static const Color onSurface = Color(0xFF1E1812);
  static const Color onSurfaceVariant = Color(0xFF6E665E);
  static const Color outline = Color(0xFF8A7E74);
  static const Color outlineVariant = Color(0xFFE2DAD0);
  static const Color inputFill = Color(0xFFF2ECE5);

  static const Color textPrimary = Color(0xFF1E1812);
  static const Color textSecondary = Color(0xFF6E665E);
  static const Color divider = Color(0xFFEAE4DC);
  static const Color success = Color(0xFF2EC153);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}

abstract class AppRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 20;
  static const double pill = 24;
  static const double circle = 28;
}
