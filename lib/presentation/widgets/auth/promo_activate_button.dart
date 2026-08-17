import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class PromoActivateButton extends StatelessWidget {
  const PromoActivateButton({
    super.key,
    required this.loading,
    required this.onTap,
  });

  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: PressableScale(
        onTap: onTap,
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
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: cs.onPrimary,
                  ),
                )
              : Text(
                  'Activate',
                  style: TextStyle(
                    fontSize: R.fontMd(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
