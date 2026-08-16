import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class PinField extends StatelessWidget {
  const PinField({super.key, required this.controller, required this.t});

  final TextEditingController controller;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: true,
      maxLength: 6,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: R.fontXl(context),
        fontWeight: FontWeight.w700,
        letterSpacing: R.fontXl(context) / 3,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: t('pin_hint'),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
