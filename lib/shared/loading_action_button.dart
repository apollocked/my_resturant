import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class LoadingActionButton extends StatelessWidget {
  const LoadingActionButton({
    super.key,
    required this.loading,
    required this.t,
    required this.labelKey,
    required this.onTap,
  });

  final bool loading;
  final String Function(String) t;
  final String labelKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: PressableScale(
        onTap: loading ? null : onTap,
        child: FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary,
            disabledForegroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onPrimary,
                  ),
                )
              : Text(
                  t(labelKey),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: R.fontMd(context),
                  ),
                ),
        ),
      ),
    );
  }
}
