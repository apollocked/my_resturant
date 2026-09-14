import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class ItemHoldSaveButton extends StatelessWidget {
  const ItemHoldSaveButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.isDesktop,
    required this.isTablet,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isDesktop
              ? 24
              : isTablet
              ? 20
              : 16,
          0,
          isDesktop
              ? 24
              : isTablet
              ? 20
              : 16,
          isDesktop ? 16 : 12,
        ),
        child: SizedBox(
          width: double.infinity,
          height: isDesktop
              ? 52
              : isTablet
              ? 48
              : 46,
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
              child: Text(
                label,
                style: TextStyle(
                  fontSize: R.fontMd(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
