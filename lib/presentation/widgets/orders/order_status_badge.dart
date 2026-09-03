import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/widgets/orders/order_status_style.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    required this.locale,
    required this.showCode,
    required this.trackingCode,
    this.isDesktop = false,
  });

  final OrderStatus status;
  final Locale locale;
  final bool showCode;
  final String trackingCode;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = OrderStatusStyle.color(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 14 : 10,
        vertical: isDesktop ? 7 : 5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              OrderStatusStyle.label(status, locale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: R.fontSm(context),
              ),
            ),
          ),
          if (showCode) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                trackingCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onPrimary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: R.fontSm(context) - 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
