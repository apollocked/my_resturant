import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/theme/button_styles.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    fontFamily: 'NRT',
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: _pageTransitions,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
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
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: PhysicalButtons.filled(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        overlayColor: Colors.white.withValues(alpha: 0.18),
        shadowColor: AppColors.primary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: PhysicalButtons.filled(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        overlayColor: Colors.white.withValues(alpha: 0.18),
        shadowColor: AppColors.primary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: PhysicalButtons.text(
        foregroundColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: PhysicalButtons.outlined(
        foregroundColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        shadowColor: AppColors.primary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    ),
    cardTheme: _cardTheme(
      color: AppColors.surface,
      border: AppColors.outlineVariant,
      shadow: AppColors.onSurface,
    ),
    dialogTheme: _dialogTheme(
      color: AppColors.surfaceLowest,
      border: AppColors.outlineVariant,
      shadow: AppColors.onSurface,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.onSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  static ThemeData get dark => ThemeData(
    fontFamily: 'NRT',
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: _pageTransitions,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
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
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.darkOnSurface),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.darkOnSurfaceVariant,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: PhysicalButtons.filled(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        overlayColor: Colors.white.withValues(alpha: 0.18),
        shadowColor: AppColors.primary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: PhysicalButtons.filled(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        overlayColor: Colors.white.withValues(alpha: 0.18),
        shadowColor: AppColors.primary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: PhysicalButtons.text(
        foregroundColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: PhysicalButtons.outlined(
        foregroundColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        shadowColor: AppColors.primary,
      ),
    ),
    dialogTheme: _dialogTheme(
      color: AppColors.darkSurfaceLowest,
      border: AppColors.darkOutlineVariant,
      shadow: AppColors.darkShadow,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        color: AppColors.darkOnSurfaceVariant,
        fontSize: 13,
      ),
    ),
    cardTheme: _cardTheme(
      color: AppColors.darkSurface,
      border: AppColors.darkOutlineVariant,
      shadow: AppColors.darkShadow,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.darkOnSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  /// Shared soft-squircle card surface: generous radius, hairline border and a
  /// whisper of shadow so it floats without feeling heavy.
  static CardThemeData _cardTheme({
    required Color color,
    required Color border,
    required Color shadow,
  }) {
    return CardThemeData(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shadowColor: shadow.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border.withValues(alpha: 0.8)),
      ),
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
    );
  }

  /// Floating rounded dialog: matches the card language so modals feel like
  /// the same material as the rest of the app.
  static DialogThemeData _dialogTheme({
    required Color color,
    required Color border,
    required Color shadow,
  }) {
    return DialogThemeData(
      backgroundColor: color,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor: shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: border.withValues(alpha: 0.7)),
      ),
    );
  }

  static const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
    },
  );
}