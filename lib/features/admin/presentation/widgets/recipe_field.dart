import 'package:flutter/material.dart';

class RecipeField extends StatelessWidget {
  const RecipeField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
