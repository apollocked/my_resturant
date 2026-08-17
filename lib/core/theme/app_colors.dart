import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE8611A);
  static const Color primarySoft = Color(0xFFFFF0E8);
  static const Color background = Color(0xFFFAF8F6);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1C1B1A);
  static const Color textSecondary = Color(0xFF8C8C8E);
  static const Color divider = Color(0xFFF0EDEA);
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
