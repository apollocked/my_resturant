import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';
import 'package:my_resturant/widgets/header_widget.dart';
import 'package:my_resturant/widgets/search_bar_widget.dart';
import 'package:my_resturant/widgets/action_buttons_row.dart';
import 'package:my_resturant/widgets/category_chip.dart';
import 'package:my_resturant/widgets/food_card.dart';

import 'package:my_resturant/data/mock_data.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCart;
  const RestaurantMenuScreen({super.key, this.onNavigateToCart});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final List<Recipe> _meals = mockRecipes;
  int _selectedCategoryIndex = 0;

  List<Recipe> get _filteredMeals {
    final key = categories[_selectedCategoryIndex]['key'];
    return key == 'all' ? _meals : _meals.where((r) => r.category == key).toList();
  }

  void _increment(Recipe recipe) {
    context.read<OrderViewModel>().addToCart(recipe);
  }

  void _decrement(Recipe recipe) {
    context.read<OrderViewModel>().decrementOrRemove(recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 16),
                HeaderWidget(onShoppingBagTap: widget.onNavigateToCart),
                const SizedBox(height: 24),
                const SearchBarWidget(),
                const SizedBox(height: 24),
                const ActionButtonsRow(),
                const SizedBox(height: 28),
                const Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text('بەشەکان',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF757575))),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return CategoryChip(
                        icon: categories[index]['icon']!,
                        name: categories[index]['name']!,
                        isSelected: _selectedCategoryIndex == index,
                        index: index,
                        onTap: () => setState(() => _selectedCategoryIndex = index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                const Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text('خواردنەکان',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF757575))),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Consumer<OrderViewModel>(
                    builder: (context, vm, _) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredMeals.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.78, crossAxisSpacing: 14, mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final recipe = _filteredMeals[index];
                          return FoodCard(
                            recipe: recipe,
                            quantity: vm.getQuantity(recipe.id),
                            onIncrement: () => _increment(recipe),
                            onDecrement: () => _decrement(recipe),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
