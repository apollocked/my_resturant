import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class SettingsOptionButton extends StatelessWidget {
  const SettingsOptionButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? AppColors.primary : cs.surface,
          foregroundColor: selected ? cs.onPrimary : cs.onSurface,
          side: BorderSide(
            color: selected ? AppColors.primary : cs.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: R.fontSm(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
