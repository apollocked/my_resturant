import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/theme/app_button_themes.dart';

/// Per-brightness color choices for the shared ThemeData skeleton.
class _ThemeSpec {
  const _ThemeSpec(this.scheme, this.surface, this.appBarTitle, this.appBarIcon,
      this.bottomUnselected, this.inputFill, this.inputLabel, this.cardColor,
      this.cardBorder, this.cardShadow, this.dialogColor, this.dialogBorder,
      this.dialogShadow, this.divider, this.snackbarBg);

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

const _light = _ThemeSpec(
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

const _dark = _ThemeSpec(
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

const _transitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
  },
);

ThemeData buildAppTheme({required bool dark}) {
  final s = dark ? _dark : _light;
  return ThemeData(
    fontFamily: 'NRT',
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: _transitions,
    scaffoldBackgroundColor: dark ? AppColors.darkBackground : AppColors.background,
    colorScheme: s.scheme,
    appBarTheme: AppBarTheme(
      backgroundColor: s.surface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: s.appBarTitle,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: s.appBarIcon),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: s.surface,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: s.bottomUnselected,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
    ),
    elevatedButtonTheme: AppButtonThemes.elevated,
    filledButtonTheme: AppButtonThemes.filled,
    textButtonTheme: AppButtonThemes.text,
    outlinedButtonTheme: AppButtonThemes.outlined,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: s.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: s.inputLabel, fontSize: 13),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shadowColor: s.cardShadow.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: s.cardBorder.withValues(alpha: 0.8)),
      ),
      color: s.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: s.dialogColor,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor: s.dialogShadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: s.dialogBorder.withValues(alpha: 0.7)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: s.divider,
      thickness: 1,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: s.snackbarBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}