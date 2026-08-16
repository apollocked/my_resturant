import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/widgets/order/elapsed_time_chip.dart';

class OrderTableRow extends StatelessWidget {
  const OrderTableRow({
    super.key,
    required this.status,
    required this.createdAt,
    required this.table,
    required this.locale,
    this.isDesktop = false,
  });

  final OrderStatus status;
  final DateTime createdAt;
  final String table;
  final Locale locale;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showElapsed =
        status != OrderStatus.served &&
        DateTime.now().difference(createdAt).inMinutes > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showElapsed) ...[
          ElapsedTimeChip(createdAt: createdAt, locale: locale),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            table,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: R.fontLg(context),
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.table_restaurant_outlined,
            size: isDesktop ? 20 : 16,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
