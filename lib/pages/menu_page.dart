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

  void _increment(Recipe r) => context.read<OrderViewModel>().addToCart(r);
  void _decrement(Recipe r) => context.read<OrderViewModel>().decrementOrRemove(r.id);

  Future<void> _showNotesDialog(Recipe recipe) async {
    final vm = context.read<OrderViewModel>();
    final result = await showDialog<String>(context: context,
      builder: (_) => _NotesDialog(initialNotes: vm.getNotes(recipe.id)));
    if (result != null) vm.updateNotesByRecipe(recipe.id, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const SizedBox(height: 16),
              HeaderWidget(onShoppingBagTap: widget.onNavigateToCart),
              const SizedBox(height: 24), const SearchBarWidget(),
              const SizedBox(height: 24), const ActionButtonsRow(),
              const SizedBox(height: 28),
              sectionLabel('بەشەکان'),
              const SizedBox(height: 12),
              SizedBox(height: 42, child: ListView.builder(scrollDirection: Axis.horizontal, reverse: true,
                itemCount: categories.length,
                itemBuilder: (context, index) => CategoryChip(
                  icon: categories[index]['icon']!, name: categories[index]['name']!,
                  isSelected: _selectedCategoryIndex == index, index: index,
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                ),
              )),
              const SizedBox(height: 28),
              sectionLabel('خواردنەکان'),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Consumer<OrderViewModel>(
                  builder: (context, vm, _) => GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredMeals.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.78, crossAxisSpacing: 14, mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final r = _filteredMeals[index];
                      return FoodCard(recipe: r, quantity: vm.getQuantity(r.id), notes: vm.getNotes(r.id),
                        onIncrement: () => _increment(r), onDecrement: () => _decrement(r),
                        onLongPress: () => _showNotesDialog(r));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget sectionLabel(String text) => Padding(padding: const EdgeInsets.only(right: 20.0),
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF757575))));
}

class _NotesDialog extends StatefulWidget {
  final String initialNotes;
  const _NotesDialog({required this.initialNotes});
  @override
  State<_NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<_NotesDialog> {
  late final TextEditingController _controller;

  @override
  void initState() { super.initState(); _controller = TextEditingController(text: widget.initialNotes); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
      title: const Text('تێبینی بۆ خواردن'),
      content: TextField(controller: _controller, maxLines: 3,
        decoration: const InputDecoration(hintText: 'تێبینیەکانت بنووسە...', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('ڕەتکردنەوە')),
        FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('پاشەکەوت')),
      ],
    ));
  }
}
