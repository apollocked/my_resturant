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
import 'package:my_resturant/pages/dish_form_page.dart';
import 'package:my_resturant/pages/category_form_page.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCart;
  const RestaurantMenuScreen({super.key, this.onNavigateToCart});
  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  // ignore: prefer_final_fields
  List<Recipe> _meals = mockRecipes;
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

  Future<void> _editDish(Recipe recipe) async {
    final r = await Navigator.push<Recipe>(context, MaterialPageRoute(builder: (_) => DishFormPage(recipe: recipe)));
    if (r == null) return;
    final i = _meals.indexWhere((x) => x.id == recipe.id);
    if (i >= 0) { _meals[i] = r; setState(() {}); }
  }

  Future<void> _deleteDish(Recipe recipe) async {
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
        title: const Text('سڕینەوەی خواردن'), content: Text('دڵنیای لە سڕینەوەی ${recipe.name}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ڕەتکردنەوە')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
              child: const Text('سڕینەوە')),
        ],
      )));
    if (ok == true) { _meals.removeWhere((r) => r.id == recipe.id); setState(() {}); }
  }

  Future<void> _addDish() async {
    final r = await Navigator.push<Recipe>(context, MaterialPageRoute(builder: (_) => const DishFormPage()));
    if (r != null) { _meals.add(r); setState(() {}); }
  }

  Future<void> _addCategory() async {
    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const CategoryFormPage()));
    if (ok == true) setState(() {});
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
              const SizedBox(height: 24),
              ActionButtonsRow(onAddSection: _addCategory, onAddFood: _addDish),
              const SizedBox(height: 40),
              sectionLabel('بەشەکان'),
              SizedBox(height: 42, child: ListView.builder(scrollDirection: Axis.horizontal, reverse: true,
                itemCount: categories.length,
                itemBuilder: (context, index) => CategoryChip(
                  icon: categories[index]['icon']!, name: categories[index]['name']!,
                  isSelected: _selectedCategoryIndex == index, index: index,
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                ),
              )),
              const SizedBox(height: 44),
              sectionLabel('خواردنەکان'),
              Consumer<OrderViewModel>(
                builder: (context, vm, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredMeals.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.78, crossAxisSpacing: 14, mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final r = _filteredMeals[index];
                      return FoodCard(recipe: r, quantity: vm.getQuantity(r.id), notes: vm.getNotes(r.id),
                        onIncrement: () => _increment(r), onDecrement: () => _decrement(r),
                        onLongPress: () => _showNotesDialog(r),
                        onEdit: () => _editDish(r), onDelete: () => _deleteDish(r));
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
  @override void initState() { super.initState(); _controller = TextEditingController(text: widget.initialNotes); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
    title: const Text('تێبینی بۆ خواردن'),
    content: TextField(controller: _controller, maxLines: 3,
      decoration: const InputDecoration(hintText: 'تێبینیەکانت بنووسە...', border: OutlineInputBorder())),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('ڕەتکردنەوە')),
      FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('پاشەکەوت')),
    ],
  ));
}
