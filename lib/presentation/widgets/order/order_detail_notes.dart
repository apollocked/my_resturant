import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class OrderDetailNotes extends StatelessWidget {
  const OrderDetailNotes({super.key, required this.notes, required this.cs});

  final String notes;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        notes,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: R.fontSm(context),
          color: cs.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
