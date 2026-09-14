import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    this.obscure = false,
    this.obscureText,
    this.onToggleObscure,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool obscure;
  final bool? obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isObscured = obscureText ?? false;
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  isObscured
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        labelText: label,
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      validator: validator,
    );
  }
}
