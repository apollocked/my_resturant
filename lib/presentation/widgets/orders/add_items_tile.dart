import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/shared/app_image.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class AddItemsTile extends StatelessWidget {
  const AddItemsTile({
    super.key,
    required this.recipe,
    required this.qty,
    required this.t,
    required this.cs,
    required this.onInc,
    required this.onDec,
  });

  final Recipe recipe;
  final int qty;
  final String Function(String) t;
  final ColorScheme cs;
  final VoidCallback onInc;
  final VoidCallback onDec;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: AppImage(
              recipe.imageUrl,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: TextStyle(
                    fontSize: R.fontMd(context),
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${recipe.price.toInt()} ${t('currency_suffix')}',
                  style: TextStyle(
                    fontSize: R.fontSm(context),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (qty == 0)
            PressableScale(
              onTap: onInc,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.add, size: 20, color: cs.onPrimary),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              height: 34,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stepBtn(Icons.remove, onDec),
                  Text(
                    '$qty',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: R.fontMd(context),
                      color: AppColors.primary,
                    ),
                  ),
                  _stepBtn(Icons.add, onInc),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: 28,
        height: 30,
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
