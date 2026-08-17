import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class ItemHoldNotesField extends StatelessWidget {
  const ItemHoldNotesField({
    super.key,
    required this.controller,
    required this.cs,
    required this.label,
    required this.hint,
    required this.isDesktop,
    required this.isTablet,
  });

  final TextEditingController controller;
  final ColorScheme cs;
  final String label;
  final String hint;
  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop
                ? 15
                : isTablet
                ? 14
                : 13,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            style: TextStyle(
              fontSize: isDesktop
                  ? 15
                  : isTablet
                  ? 14
                  : 13,
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(
                isDesktop
                    ? 16
                    : isTablet
                    ? 14
                    : 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
