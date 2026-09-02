import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/shared/app_image.dart';

class FoodDishTile extends StatelessWidget {
  const FoodDishTile({
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AppImage(recipe.imageUrl, width: 48, height: 48),
        ),
        title: Text(
          recipe.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: R.fontMd(context),
            color: cs.onSurface,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                '${recipe.price.toInt()} $priceLabel • ${recipe.category}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: R.fontSm(context),
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            Switch(
              value: recipe.available,
              onChanged: (_) => onToggle(),
              activeTrackColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: onEdit,
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
