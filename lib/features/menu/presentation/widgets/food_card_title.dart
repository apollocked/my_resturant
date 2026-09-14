import 'package:flutter/material.dart';

class FoodCardTitle extends StatelessWidget {
  const FoodCardTitle({
    super.key,
    required this.name,
    required this.description,
    required this.cs,
    required this.nameSize,
    required this.descSize,
  });

  final String name;
  final String description;
  final ColorScheme cs;
  final double nameSize;
  final double descSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: nameSize,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: descSize),
        ),
      ],
    );
  }
}
