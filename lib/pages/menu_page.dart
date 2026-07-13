import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';
import 'package:my_resturant/widgets/header_widget.dart';
import 'package:my_resturant/widgets/search_bar_widget.dart';
import 'package:my_resturant/widgets/action_buttons_row.dart';
import 'package:my_resturant/widgets/category_chip.dart';
import 'package:my_resturant/widgets/food_card.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final VoidCallback? onNavigateToOrders;
  const RestaurantMenuScreen({super.key, this.onNavigateToOrders});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  List<Recipe> _meals = [];
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'هەموو', 'icon': '🍕'},
    {'name': 'پیتزا', 'icon': '🍕'},
    {'name': 'بەرگر', 'icon': '🍔'},
    {'name': 'شاورمە', 'icon': '🌯'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=Beef'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = (data['meals'] as List?)?.take(12).toList() ?? [];
        setState(() {
          _meals = meals.map((m) => Recipe.fromMealApi(m)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
                HeaderWidget(onShoppingBagTap: widget.onNavigateToOrders),
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
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return CategoryChip(
                        icon: _categories[index]['icon'],
                        name: _categories[index]['name'],
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2EC153)))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _meals.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 0.78, crossAxisSpacing: 14, mainAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) {
                            final recipe = _meals[index];
                            return FoodCard(
                              recipe: recipe,
                              onAdd: () => context.read<OrderViewModel>().addOrder(recipe),
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
