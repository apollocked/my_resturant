import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.loading,
    required this.onTap,
    required this.label,
  });

  final bool loading;
  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: PressableScale(
        onTap: loading ? null : onTap,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Text(
            'G',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          label: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: R.fontMd(context),
              color: cs.onSurface,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.onSurface,
            disabledForegroundColor: cs.onSurface,
            side: BorderSide(color: cs.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        ),
      ),
    );
  }
}
