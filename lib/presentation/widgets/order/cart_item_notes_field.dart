import 'package:flutter/material.dart';

class CartItemNotesField extends StatelessWidget {
  const CartItemNotesField({
    super.key,
    required this.controller,
    required this.hint,
    required this.cs,
    required this.isDesktop,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ColorScheme cs;
  final bool isDesktop;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      maxLength: 120,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant.withValues(alpha: 0.4),
          fontSize: isDesktop ? 13 : 12,
        ),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isDesktop ? 12 : 10,
        ),
        isDense: true,
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      style: TextStyle(fontSize: isDesktop ? 13 : 12, color: cs.onSurface),
      onChanged: onChanged,
    );
  }
}
