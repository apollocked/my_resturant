import 'package:flutter/material.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class CategorySaveButton extends StatelessWidget {
  const CategorySaveButton({
    super.key,
    required this.loading,
    required this.label,
    required this.onTap,
  });

  final bool loading;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 48,
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
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}
