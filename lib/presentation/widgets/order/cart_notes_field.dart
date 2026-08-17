import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class CartNotesField extends StatelessWidget {
  const CartNotesField({
    super.key,
    required this.controller,
    required this.hint,
    required this.cs,
  });

  final TextEditingController controller;
  final String hint;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      maxLength: 200,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 12,
        ),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
    );
  }
}
