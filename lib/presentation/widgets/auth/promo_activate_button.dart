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
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
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
