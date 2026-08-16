import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetupPasscodeField extends StatelessWidget {
  const SetupPasscodeField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.obscure,
    required this.onToggleObscure,
    required this.t,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      maxLength: 6,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: onToggleObscure,
        ),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      validator: (v) => v == null || v.isEmpty
          ? t('pin_required')
          : v.length < 4
          ? t('pin_too_short')
          : null,
    );
  }
}
