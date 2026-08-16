import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/menu/menu_category_sidebar.dart';
import 'package:my_resturant/presentation/widgets/menu/menu_food_grid.dart';
import 'package:my_resturant/shared/menu_cart_bar.dart';

class MenuDesktopLayout extends StatelessWidget {
  final ColorScheme cs;
  final String Function(String) t;
  final dynamic state;
  final List<Recipe> meals;
  final List<Map<String, String>> cats;
  final int selectedIndex;
  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;
  final void Function(Recipe) onIncrement;
  final void Function(Recipe) onDecrement;
  final void Function(Recipe) onRemove;
  final void Function(Recipe) onLongPress;
  const MenuDesktopLayout({
    super.key,
    required this.cs,
    required this.t,
    required this.state,
    required this.meals,
    required this.cats,
    required this.selectedIndex,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => context.read<OrderCubit>().refresh(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MenuCategorySidebar(
                      cs: cs,
                      t: t,
                      cats: cats,
                      selectedIndex: selectedIndex,
                      onCategoryChanged: onCategoryChanged,
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          R.padding(context),
                          16,
                          R.padding(context),
                          16,
                        ),
                        child: MenuFoodGrid(
                          t: t,
                          meals: meals,
                          state: state,
                          onSearchChanged: onSearchChanged,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                          onRemove: onRemove,
                          onLongPress: onLongPress,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.cartCount > 0)
              MenuCartBar(
                cartCount: state.cartCount,
                cartTotal: state.cartTotal.toInt(),
                onViewCart: () => context.go('/cart'),
              ),
          ],
        ),
      ),
    );
  }
}
