import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class ItemHoldPriceBadge extends StatelessWidget {
  const ItemHoldPriceBadge({
    super.key,
    required this.price,
    required this.priceLabel,
    required this.isDesktop,
    required this.isTablet,
  });

  final double price;
  final String priceLabel;
  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 14
            : isTablet
            ? 12
            : 10,
        vertical: isDesktop ? 6 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        '${price.toInt()} $priceLabel',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: isDesktop
              ? 16
              : isTablet
              ? 14
              : 13,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
