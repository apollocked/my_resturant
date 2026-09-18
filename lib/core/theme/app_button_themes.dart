import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/theme/button_styles.dart';

/// The four primary button families, shared verbatim by light and dark themes.
class AppButtonThemes {
  static ElevatedButtonThemeData get elevated => ElevatedButtonThemeData(
        style: PhysicalButtons.filled(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          overlayColor: Colors.white.withValues(alpha: 0.18),
          shadowColor: AppColors.primary,
        ),
      );

  static FilledButtonThemeData get filled => FilledButtonThemeData(
        style: PhysicalButtons.filled(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          overlayColor: Colors.white.withValues(alpha: 0.18),
          shadowColor: AppColors.primary,
        ),
      );

  static TextButtonThemeData get text => TextButtonThemeData(
        style: PhysicalButtons.text(
          foregroundColor: AppColors.primary,
          overlayColor: AppColors.primary.withValues(alpha: 0.12),
        ),
      );

  static OutlinedButtonThemeData get outlined => OutlinedButtonThemeData(
        style: PhysicalButtons.outlined(
          foregroundColor: AppColors.primary,
          overlayColor: AppColors.primary.withValues(alpha: 0.12),
          shadowColor: AppColors.primary,
        ),
      );
}