import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class OrderDetailHeader extends StatelessWidget {
  const OrderDetailHeader({
    super.key,
    required this.color,
    required this.statusLabel,
    required this.total,
    required this.t,
    this.isDesktop = false,
  });

  final Color color;
  final String statusLabel;
  final double total;
  final String Function(String) t;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 18 : 14,
            vertical: isDesktop ? 9 : 7,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: R.fontMd(context),
            ),
          ),
        ),
        Text(
          '${total.toInt()} ${t('currency_suffix')}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: isDesktop ? R.fontXxl(context) : R.fontXl(context),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
