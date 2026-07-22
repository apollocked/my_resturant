import 'package:flutter/material.dart';

class OnbColors {
  final Brightness brightness;
  const OnbColors(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  Color get scaffoldBg => isDark ? Colors.black : const Color(0xFFF8F6F4);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1C1B1A);
  Color get textSecondary => isDark ? Colors.white70 : const Color(0xFF6B6B6E);
  Color get glassBg => isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.06);
  Color get glassBorder => isDark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.1);
  Color get skipBg => isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06);
  Color get skipBorder => isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1);
  Color get skipText => isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.6);
  Color get iconCircleBg => isDark ? Colors.white.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.9);
  Color get iconCircleBorder => isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08);
  Color get checkBg => isDark ? Colors.white : Colors.white;
  Color get dotInactive => isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.12);
  Color get selectedBg => isDark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.1);
  Color get selectedBorder => isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.25);
  double get ctaShadow => isDark ? 0.4 : 0.25;

  List<Color> meshGradient(List<Color> base) => isDark
      ? base
      : [
          Color.lerp(base[0], Colors.white, 0.55)!,
          Color.lerp(base[1], Colors.white, 0.6)!,
          Color.lerp(base[2], Colors.white, 0.65)!,
        ];

  static OnbColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return OnbColors(brightness);
  }
}
