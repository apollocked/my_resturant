import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_button_themes.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/theme/theme_specs.dart';

ThemeData buildAppTheme({required bool dark}) {
  final s = dark ? darkThemeSpec : lightThemeSpec;
  return ThemeData(
    fontFamily: 'NRT',
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: appPageTransitions,
    scaffoldBackgroundColor:
        dark ? AppColors.darkBackground : AppColors.background,
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
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
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