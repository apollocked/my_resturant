import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

/// Colored strip on top of a history tile: short code + served time.
class HistoryOrderHeader extends StatelessWidget {
  final String code;
  final String time;
  final Color color;
  final bool isDesktop;

  const HistoryOrderHeader({
    super.key,
    required this.code,
    required this.time,
    required this.color,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 6 : 4,
        horizontal: 10,
      ),
      color: color.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.fontSm(context) - 1,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: R.fontSm(context) - 2,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}