import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class DishSaveButton extends StatelessWidget {
  const DishSaveButton({
    super.key,
    required this.isEditing,
    required this.t,
    required this.onTap,
  });

  final bool isEditing;
  final String Function(String) t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: R.isDesktop(context) ? 56 : 48,
      child: PressableScale(
        onTap: onTap,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            disabledBackgroundColor: cs.primary,
            disabledForegroundColor: cs.onPrimary,
          ),
          child: Text(
            isEditing ? t('update_btn') : t('add_btn'),
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
