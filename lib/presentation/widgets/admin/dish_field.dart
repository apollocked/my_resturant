import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DishField extends StatelessWidget {
  const DishField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(labelText: label, filled: true),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
