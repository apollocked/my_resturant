import 'package:flutter/material.dart';

abstract class R {
  R._();

  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isTablet(BuildContext context) => width(context) >= 600;
  static bool isLargePhone(BuildContext context) => width(context) >= 400;

  static int menuGridColumns(BuildContext context) => isTablet(context) ? 3 : 2;
  static double menuGridAspectRatio(BuildContext context) =>
      isTablet(context) ? 0.9 : 0.72;

  static int tableGridColumns(BuildContext context) {
    final w = width(context);
    if (w >= 900) return 8;
    if (w >= 600) return 6;
    return 4;
  }

  static int categoryIconColumns(BuildContext context) {
    final w = width(context);
    if (w >= 900) return 10;
    if (w >= 600) return 8;
    return 6;
  }

  static double hp(BuildContext context, double percent) =>
      width(context) * percent / 100;
  static double vp(BuildContext context, double percent) =>
      height(context) * percent / 100;

  static double padding(BuildContext context) => isTablet(context) ? 24.0 : 16.0;
  static double cardPadding(BuildContext context) => isTablet(context) ? 16.0 : 12.0;
  static double gridSpacing(BuildContext context) => isTablet(context) ? 16.0 : 12.0;

  static double fontSm(BuildContext context) => isTablet(context) ? 13.0 : 11.0;
  static double fontMd(BuildContext context) => isTablet(context) ? 15.0 : 13.0;
  static double fontLg(BuildContext context) => isTablet(context) ? 18.0 : 15.0;
  static double fontXl(BuildContext context) => isTablet(context) ? 22.0 : 18.0;
}
