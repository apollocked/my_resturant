import 'package:flutter/material.dart';

class AddItemsSearchField extends StatelessWidget {
  const AddItemsSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.t,
    required this.cs,
    this.isDesktop = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String Function(String) t;
  final ColorScheme cs;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: t('search_hint'),
          hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
