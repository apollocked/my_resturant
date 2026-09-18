import 'package:flutter/material.dart';

import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

/// Clean-request Sent pill shown after a waiter flags a served table.
class CleaningRequestBar extends StatelessWidget {
  final int n;
  final bool requested;
  final String Function(String) t;
  final ColorScheme cs;
  final VoidCallback onRequest;

  const CleaningRequestBar({
    super.key,
    required this.n,
    required this.requested,
    required this.t,
    required this.cs,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.warning;
    if (requested) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: accent),
            const SizedBox(width: 6),
            Text(
              t('cleaning_requested'),
              style: TextStyle(
                color: accent,
                fontSize: R.fontSm(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    return PressableScale(
      onTap: onRequest,
      child: SizedBox(
        height: 36,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.cleaning_services, size: 15),
          label: Text(
            t('request_cleaning'),
            style: TextStyle(
              fontSize: R.fontSm(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent.withValues(alpha: 0.6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
    );
  }
}