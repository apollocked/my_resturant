import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class OrderDetailFoodsHeader extends StatelessWidget {
  const OrderDetailFoodsHeader({
    super.key,
    required this.time,
    required this.title,
    required this.cs,
    this.isDesktop = false,
  });

  final String time;
  final String title;
  final ColorScheme cs;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: R.fontSm(context),
            color: cs.onSurfaceVariant,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? R.fontXl(context) : R.fontLg(context),
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
