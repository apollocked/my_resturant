import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

/// Per-brightness color choices for the shared ThemeData skeleton.
class ThemeSpec {
  const ThemeSpec(
    this.scheme,
    this.surface,
    this.appBarTitle,
    this.appBarIcon,
    this.bottomUnselected,
    this.inputFill,
    this.inputLabel,
    this.cardColor,
    this.cardBorder,
    this.cardShadow,
    this.dialogColor,
    this.dialogBorder,
    this.dialogShadow,
    this.divider,
    this.snackbarBg,
  );

  final ColorScheme scheme;
  final Color surface;
  final Color appBarTitle;
  final Color appBarIcon;
  final Color bottomUnselected;
  final Color inputFill;
  final Color inputLabel;
  final Color cardColor;
  final Color cardBorder;
  final Color cardShadow;
  final Color dialogColor;
  final Color dialogBorder;
  final Color dialogShadow;
  final Color divider;
  final Color snackbarBg;
}

const lightThemeSpec = ThemeSpec(
  ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    error: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    surfaceContainerLowest: AppColors.surfaceLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
  ),
  AppColors.surface,
  AppColors.textPrimary,
  AppColors.textPrimary,
  AppColors.textSecondary,
  AppColors.inputFill,
  AppColors.textSecondary,
  AppColors.surface,
  AppColors.outlineVariant,
  AppColors.onSurface,
  AppColors.surfaceLowest,
  AppColors.outlineVariant,
  AppColors.onSurface,
  AppColors.divider,
  AppColors.onSurface,
);

const darkThemeSpec = ThemeSpec(
  ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    error: AppColors.error,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    surfaceContainerLowest: AppColors.darkSurfaceLowest,
    surfaceContainerLow: AppColors.darkSurfaceContainerLow,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
  ),
  AppColors.darkSurface,
  AppColors.darkOnSurface,
  AppColors.darkOnSurface,
  AppColors.darkOnSurfaceVariant,
  AppColors.darkInputFill,
  AppColors.darkOnSurfaceVariant,
  AppColors.darkSurface,
  AppColors.darkOutlineVariant,
  AppColors.darkShadow,
  AppColors.darkSurfaceLowest,
  AppColors.darkOutlineVariant,
  AppColors.darkShadow,
  AppColors.darkDivider,
  AppColors.darkOnSurface,
);

const appPageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
  },
);