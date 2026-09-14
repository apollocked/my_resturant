import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class AddItemsFooterButton extends StatelessWidget {
  const AddItemsFooterButton({
    super.key,
    required this.count,
    required this.totalPrice,
    required this.t,
    required this.cs,
    this.onTap,
    this.isDesktop = false,
  });

  final int count;
  final double totalPrice;
  final String Function(String) t;
  final ColorScheme cs;
  final VoidCallback? onTap;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final enabled = count > 0;
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 52 : 46,
      child: PressableScale(
        onTap: onTap,
        child: FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            backgroundColor: enabled
                ? AppColors.primary
                : cs.surfaceContainerHighest,
            disabledBackgroundColor: cs.surfaceContainerHighest,
            disabledForegroundColor: cs.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(
            enabled
                ? '${t('add_to_order')}  (${totalPrice.toInt()} ${t('currency_suffix')})'
                : t('add_to_order'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
