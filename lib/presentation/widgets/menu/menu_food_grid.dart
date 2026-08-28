import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card.dart';
import 'package:my_resturant/shared/empty_state.dart';
import 'package:my_resturant/shared/search_bar_widget.dart';

class MenuFoodGrid extends StatelessWidget {
  const MenuFoodGrid({
    super.key,
    required this.t,
    required this.meals,
    required this.state,
    required this.onSearchChanged,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onLongPress,
  });

  final String Function(String) t;
  final List<Recipe> meals;
  final dynamic state;
  final ValueChanged<String> onSearchChanged;
  final void Function(Recipe) onIncrement;
  final void Function(Recipe) onDecrement;
  final void Function(Recipe) onRemove;
  final void Function(Recipe) onLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SearchBarWidget(onChanged: onSearchChanged),
        const SizedBox(height: 28),
        if (meals.isEmpty)
          SizedBox(
            height: 280,
            child: EmptyState(
              icon: Icons.search_off,
              title: t('no_food_found'),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: R.menuGridColumns(context),
              childAspectRatio: R.menuGridAspectRatio(context),
              crossAxisSpacing: R.gridSpacing(context),
              mainAxisSpacing: R.gridSpacing(context),
            ),
            itemBuilder: (ctx, i) {
              final r = meals[i];
              return FoodCard(
                recipe: r,
                quantity: state.getQuantity(r.id),
                notes: state.getNotes(r.id),
                onIncrement: () => onIncrement(r),
                onDecrement: () => onDecrement(r),
                onRemove: () => onRemove(r),
                onLongPress: () => onLongPress(r),
              );
            },
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}
