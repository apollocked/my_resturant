import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/widgets/menu/item_hold_price_badge.dart';

class ItemHoldHeaderInfo extends StatelessWidget {
  const ItemHoldHeaderInfo({
    super.key,
    required this.name,
    required this.price,
    required this.priceLabel,
    required this.description,
    required this.cs,
    required this.isDesktop,
    required this.isTablet,
  });

  final String name;
  final double price;
  final String priceLabel;
  final String description;
  final ColorScheme cs;
  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: isDesktop
                      ? 22
                      : isTablet
                      ? 20
                      : 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
            ItemHoldPriceBadge(
              price: price,
              priceLabel: priceLabel,
              isDesktop: isDesktop,
              isTablet: isTablet,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (description.isNotEmpty)
          Text(
            description,
            style: TextStyle(
              fontSize: isDesktop
                  ? 15
                  : isTablet
                  ? 14
                  : 13,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
      ],
    );
  }
}
