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
  const MenuDesktopLayout({super.key, required this.cs, required this.t, required this.state, required this.meals, required this.cats,
    required this.selectedIndex, required this.onCategoryChanged, required this.onSearchChanged,
    required this.onIncrement, required this.onDecrement, required this.onRemove, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Column(children: [
      Expanded(child: RefreshIndicator(
        onRefresh: () async => context.read<OrderCubit>().refresh(),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 180, padding: EdgeInsets.fromLTRB(R.padding(context), 24, 0, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(t('categories'), style: TextStyle(fontSize: R.fontMd(context), fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 16),
              Expanded(child: ListView.builder(
                itemCount: cats.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CategoryChip(icon: cats[index]['icon']!, name: t('cat_${cats[index]['key']!}'),
                    isSelected: selectedIndex == index, index: index, onTap: () => onCategoryChanged(index)),
                ),
              )),
            ]),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(R.padding(context), 16, R.padding(context), 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              SearchBarWidget(onChanged: onSearchChanged),
              const SizedBox(height: 28),
              if (meals.isEmpty)
                SizedBox(height: 280, child: EmptyState(icon: Icons.search_off, title: t('no_food_found')))
              else
                GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: meals.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: R.menuGridAspectRatio(context), crossAxisSpacing: R.gridSpacing(context), mainAxisSpacing: R.gridSpacing(context)),
                  itemBuilder: (ctx, i) {
                    final r = meals[i];
                    return FoodCard(recipe: r, quantity: state.getQuantity(r.id), notes: state.getNotes(r.id),
                      onIncrement: () => onIncrement(r), onDecrement: () => onDecrement(r), onRemove: () => onRemove(r), onLongPress: () => onLongPress(r));
                  }),
              const SizedBox(height: 100),
            ]),
          )),
        ]),
      )),
      if (state.cartCount > 0) MenuCartBar(cartCount: state.cartCount, cartTotal: state.cartTotal.toInt(), onViewCart: () => context.go('/cart')),
    ])));
  }
}
