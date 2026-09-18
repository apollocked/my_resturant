import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/theme_factory.dart';

class AppTheme {
  static ThemeData get light => buildAppTheme(dark: false);
  static ThemeData get dark => buildAppTheme(dark: true);
}