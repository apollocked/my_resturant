import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/shared/app_image.dart';

class FoodDishCard extends StatelessWidget {
  const FoodDishCard({
    super.key,
    required this.recipe,
    required this.cs,
    required this.priceLabel,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final Recipe recipe;
  final ColorScheme cs;
  final String priceLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(R.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: AppImage(recipe.imageUrl, width: 44, height: 44),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: recipe.available,
                  onChanged: (_) => onToggle(),
                  activeTrackColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const Spacer(),
            Text(
              recipe.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: R.fontMd(context),
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${recipe.price.toInt()} $priceLabel • ${recipe.category}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.fontSm(context),
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
