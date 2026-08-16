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
  });

  final Recipe recipe;
  final ColorScheme cs;
  final String priceLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
        subtitle: Text(
          '${recipe.price.toInt()} $priceLabel • ${recipe.category}',
          style: TextStyle(
            fontSize: R.fontSm(context),
            color: cs.onSurfaceVariant,
          ),
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
