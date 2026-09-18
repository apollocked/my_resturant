import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

String tableFirstLetters(String s) {
  final trimmed = s.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.split('').take(3).join();
}

/// One table button inside the table-picker dialog: shows lock / cleaning /
/// custom-name states via its resolved flags.
class TablePickerCell extends StatelessWidget {
  final int n;
  final bool selected;
  final bool locked;
  final bool needsClean;
  final bool requestedCleaning;
  final bool hasCustomName;
  final String customName;
  final String number;
  final ColorScheme cs;
  final VoidCallback? onPressed;

  const TablePickerCell({
    super.key,
    required this.n,
    required this.selected,
    required this.locked,
    required this.needsClean,
    required this.requestedCleaning,
    required this.hasCustomName,
    required this.customName,
    required this.number,
    required this.cs,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.warning;
    final sel = selected;
    final labelColor = sel ? cs.onPrimary : cs.onSurface;
    return SizedBox(
      width: 56,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: needsClean
              ? (requestedCleaning ? accent : accent.withValues(alpha: 0.16))
              : locked
              ? cs.surfaceContainerHighest
              : (sel ? AppColors.primary : cs.surface),
          foregroundColor: needsClean
              ? (requestedCleaning ? cs.onPrimary : accent)
              : locked
              ? cs.onSurfaceVariant
              : labelColor,
          side: BorderSide(
            color: needsClean
                ? accent.withValues(alpha: 0.6)
                : locked
                ? cs.outlineVariant
                : (sel ? AppColors.primary : cs.outlineVariant),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: needsClean
            ? Icon(
                requestedCleaning ? Icons.check_circle : Icons.cleaning_services,
                size: 14,
                color: requestedCleaning ? cs.onPrimary : accent,
              )
            : locked
            ? Icon(Icons.lock, size: 14, color: cs.onSurfaceVariant)
            : hasCustomName
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tableFirstLetters(customName),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: labelColor,
                    ),
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: sel
                          ? cs.onPrimary.withValues(alpha: 0.85)
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: R.fontSm(context),
                ),
              ),
      ),
    );
  }
}