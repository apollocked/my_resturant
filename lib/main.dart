import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/pages/layout_page.dart';
import 'package:my_resturant/cubits/order_cubit.dart';

class AppTheme {
  static const Color primary = Color(0xFFE8611A);
  static const Color primarySoft = Color(0xFFFFF0E8);
  static const Color background = Color(0xFFFAF8F6);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1C1B1A);
  static const Color textSecondary = Color(0xFF8C8C8E);
  static const Color divider = Color(0xFFF0EDEA);
  static const Color success = Color(0xFF2EC153);
  static const Color error = Color(0xFFE53E3E);

  static ThemeData get light => ThemeData(
    fontFamily: 'NRT', useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(primary: primary, secondary: primary,
      surface: surface, error: error),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface, elevation: 0, centerTitle: false,
      titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
      iconTheme: IconThemeData(color: textPrimary)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface, elevation: 0, type: BottomNavigationBarType.fixed,
      selectedItemColor: primary, unselectedItemColor: textSecondary,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontSize: 11)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: primary,
        foregroundColor: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: const Color(0xFFF7F5F3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 13)),
    cardTheme: CardThemeData(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: surface, margin: const EdgeInsets.only(bottom: 12)),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1, space: 0),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderCubit(),
      child: MaterialApp(
        title: 'Restaurant App', debugShowCheckedModeBanner: false,
        theme: AppTheme.light, home: const MainLayout(),
      ),
    );
  }
}
