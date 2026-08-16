import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class PromoTextField extends StatelessWidget {
  const PromoTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      textCapitalization: TextCapitalization.characters,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 6,
        color: cs.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'XXXX-XXXX',
        hintStyle: TextStyle(
          letterSpacing: 6,
          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
        LengthLimitingTextInputFormatter(9),
      ],
      onSubmitted: onSubmitted,
    );
  }
}
