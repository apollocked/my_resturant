import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class CartSendButton extends StatelessWidget {
  const CartSendButton({
    super.key,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
    required this.cs,
    required this.label,
    required this.fontSize,
    required this.padH,
    this.icon = Icons.send_rounded,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final ColorScheme cs;
  final String label;
  final double fontSize;
  final double padH;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: canSubmit && !isSubmitting ? onSubmit : null,
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: cs.onPrimary,
            disabledBackgroundColor: AppColors.primary,
            disabledForegroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: padH),
          ),
          child: isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onPrimary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
