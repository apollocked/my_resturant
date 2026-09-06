import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/widgets/admin/food_dish_card.dart';
import 'package:my_resturant/presentation/widgets/admin/food_dish_tile.dart';
import 'package:my_resturant/shared/empty_state.dart';
import 'package:my_resturant/shared/shimmer_skeletons.dart';

class FoodListView extends StatelessWidget {
  const FoodListView({
    super.key,
    required this.isLoading,
    required this.dishes,
    required this.isGrid,
    required this.t,
    required this.cs,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isLoading;
  final List<Recipe> dishes;
  final bool isGrid;
  final String Function(String) t;
  final ColorScheme cs;
  final ValueChanged<Recipe> onEdit;
  final ValueChanged<Recipe> onDelete;

  @override
  Widget build(BuildContext context) {
    if (isLoading && dishes.isEmpty) {
      return isGrid
          ? GridView(
              padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: R.menuGridColumns(context),
                childAspectRatio: 1.9,
                crossAxisSpacing: R.gridSpacing(context),
                mainAxisSpacing: R.gridSpacing(context),
              ),
              children: List.generate(6, (_) => const ShimmerListTile()),
            )
          : ShimmerListView(
              itemCount: 6,
              itemBuilder: () => const ShimmerListTile(),
            );
    }
    if (dishes.isEmpty) {
      return EmptyState(
        icon: Icons.restaurant_menu,
        title: t('no_food_found'),
        subtitle: t('no_food_found_subtitle'),
      );
    }
    if (isGrid) {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: R.menuGridColumns(context),
          childAspectRatio: 1.9,
          crossAxisSpacing: R.gridSpacing(context),
          mainAxisSpacing: R.gridSpacing(context),
        ),
        itemCount: dishes.length,
        itemBuilder: (context, index) => FoodDishCard(
          recipe: dishes[index],
          cs: cs,
          priceLabel: t('currency_suffix'),
          onEdit: () => onEdit(dishes[index]),
          onDelete: () => onDelete(dishes[index]),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
      itemCount: dishes.length,
      itemBuilder: (context, index) => FoodDishTile(
        recipe: dishes[index],
        cs: cs,
        priceLabel: t('currency_suffix'),
        onEdit: () => onEdit(dishes[index]),
        onDelete: () => onDelete(dishes[index]),
      ),
    );
  }
}
