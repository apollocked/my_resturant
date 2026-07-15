import 'package:flutter/material.dart';

enum ScreenSize { phone, tablet, desktop }

abstract class R {
  R._();

  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isPhone(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) => width(context) >= 600 && width(context) < 1024;
  static bool isDesktop(BuildContext context) => width(context) >= 1024;
  static bool isLargePhone(BuildContext context) => width(context) >= 400;

  static ScreenSize screenSize(BuildContext context) {
    if (isDesktop(context)) return ScreenSize.desktop;
    if (isTablet(context)) return ScreenSize.tablet;
    return ScreenSize.phone;
  }

  static int menuGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double menuGridAspectRatio(BuildContext context) {
    if (isDesktop(context)) return 1.05;
    if (isTablet(context)) return 0.9;
    return 0.78;
  }

  static int tableGridColumns(BuildContext context) {
    final w = width(context);
    if (w >= 1024) return 8;
    if (w >= 600) return 6;
    return 4;
  }

  static int categoryIconColumns(BuildContext context) {
    final w = width(context);
    if (w >= 1024) return 10;
    if (w >= 600) return 8;
    return 6;
  }

  static double hp(BuildContext context, double percent) =>
      width(context) * percent / 100;
  static double vp(BuildContext context, double percent) =>
      height(context) * percent / 100;

  static double padding(BuildContext context) {
    if (isDesktop(context)) return 32.0;
    if (isTablet(context)) return 24.0;
    return 16.0;
  }

  static double cardPadding(BuildContext context) {
    if (isDesktop(context)) return 20.0;
    if (isTablet(context)) return 16.0;
    return 12.0;
  }

  static double gridSpacing(BuildContext context) {
    if (isDesktop(context)) return 20.0;
    if (isTablet(context)) return 16.0;
    return 12.0;
  }

  static double fontSm(BuildContext context) {
    if (isDesktop(context)) return 14.0;
    if (isTablet(context)) return 13.0;
    return 11.0;
  }

  static double fontMd(BuildContext context) {
    if (isDesktop(context)) return 16.0;
    if (isTablet(context)) return 15.0;
    return 13.0;
  }

  static double fontLg(BuildContext context) {
    if (isDesktop(context)) return 20.0;
    if (isTablet(context)) return 18.0;
    return 15.0;
  }

  static double fontXl(BuildContext context) {
    if (isDesktop(context)) return 26.0;
    if (isTablet(context)) return 22.0;
    return 18.0;
  }

  static double fontXxl(BuildContext context) {
    if (isDesktop(context)) return 34.0;
    if (isTablet(context)) return 28.0;
    return 24.0;
  }

  static double avatarSize(BuildContext context) {
    if (isDesktop(context)) return 88;
    if (isTablet(context)) return 72;
    return 56;
  }
}
