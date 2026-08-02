import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/shared/search_bar_widget.dart';
import 'package:my_resturant/presentation/widgets/admin/category_chip.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card.dart';
import 'package:my_resturant/presentation/widgets/shared/menu_cart_bar.dart';
import 'package:my_resturant/presentation/widgets/shared/empty_state.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class MenuMobileLayout extends StatelessWidget {
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
  const MenuMobileLayout({super.key, required this.cs, required this.t, required this.state, required this.meals, required this.cats,
    required this.selectedIndex, required this.onCategoryChanged, required this.onSearchChanged,
    required this.onIncrement, required this.onDecrement, required this.onRemove, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
      Expanded(child: RefreshIndicator(
        onRefresh: () async => context.read<OrderCubit>().refresh(),
        child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            SizedBox(height: R.isTablet(context) ? 20 : 16),
            Padding(padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
              child: SearchBarWidget(onChanged: onSearchChanged)),
            SizedBox(height: R.isTablet(context) ? 32 : 28),
            Padding(padding: EdgeInsets.only(right: R.padding(context)),
              child: Text(t('categories'), style: TextStyle(fontSize: R.isTablet(context) ? 16 : 14, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.6)))),
            const SizedBox(height: 12),
            SizedBox(height: R.isTablet(context) ? 48 : 40,
              child: ListView.builder(scrollDirection: Axis.horizontal, reverse: true, itemCount: cats.length, padding: EdgeInsets.zero,
                itemBuilder: (ctx, i) => CategoryChip(icon: cats[i]['icon']!, name: t('cat_${cats[i]['key']!}'),
                  isSelected: selectedIndex == i, index: i, onTap: () => onCategoryChanged(i)))),
            SizedBox(height: R.isTablet(context) ? 28 : 24),
            if (meals.isEmpty)
              SizedBox(height: 240, child: EmptyState(icon: Icons.search_off, title: t('no_food_found')))
            else
              Padding(padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                child: GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: meals.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: R.menuGridColumns(context), childAspectRatio: R.menuGridAspectRatio(context), crossAxisSpacing: R.gridSpacing(context), mainAxisSpacing: R.gridSpacing(context)),
                  itemBuilder: (ctx, i) {
                    final r = meals[i];
                    return FoodCard(recipe: r, quantity: state.getQuantity(r.id), notes: state.getNotes(r.id),
                      onIncrement: () => onIncrement(r), onDecrement: () => onDecrement(r), onRemove: () => onRemove(r), onLongPress: () => onLongPress(r));
                  })),
            const SizedBox(height: 100),
          ]),
        ),
      )),
      if (state.cartCount > 0) MenuCartBar(cartCount: state.cartCount, cartTotal: state.cartTotal.toInt(), onViewCart: () => context.go('/cart')),
    ]));
  }
}
