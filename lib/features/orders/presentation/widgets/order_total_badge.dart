import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

/// Gradient total pill shown at the end of an order's action row.
class OrderTotalBadge extends StatelessWidget {
  final double total;
  final Locale locale;
  final bool isDesktop;

  const OrderTotalBadge({
    super.key,
    required this.total,
    required this.locale,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16.0 : 12.0,
        vertical: isDesktop ? 8.0 : 6.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${total.toInt()} ${Tr.get('currency_suffix', locale)}',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: R.fontMd(context),
          color: cs.onPrimary,
        ),
      ),
    );
  }
}