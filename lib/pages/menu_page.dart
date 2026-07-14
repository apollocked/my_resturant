import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/widgets/search_bar_widget.dart';
import 'package:my_resturant/widgets/action_buttons_row.dart';
import 'package:my_resturant/widgets/category_chip.dart';
import 'package:my_resturant/widgets/food_card.dart';
import 'package:my_resturant/widgets/menu_hero.dart';
import 'package:my_resturant/widgets/menu_cart_bar.dart';
import 'package:my_resturant/widgets/notes_dialog.dart';
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
  final List<Recipe> _meals = mockRecipes;
  int _selectedCategoryIndex = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<Recipe> get _filteredMeals {
    var list = _meals.where((r) => r.available).toList();
    final key = categories[_selectedCategoryIndex]['key'];
    if (key != 'all') list = list.where((r) => r.category == key).toList();
    if (_searchQuery.isNotEmpty) list = list.where((r) => r.name.contains(_searchQuery)).toList();
    return list;
  }

  void _increment(Recipe r) => context.read<OrderCubit>().addToCart(r);
  void _decrement(Recipe r) => context.read<OrderCubit>().decrementOrRemove(r.id);

  Future<void> _notes(Recipe recipe) async {
    final s = context.read<OrderCubit>().state;
    final r = await showDialog<String>(context: context, builder: (_) => NotesDialog(initialNotes: s.getNotes(recipe.id)));
    if (r != null) context.read<OrderCubit>().updateNotesByRecipe(recipe.id, r);
  }

  Future<void> _edit(Recipe recipe) async {
    final r = await Navigator.push<Recipe>(context, MaterialPageRoute(builder: (_) => DishFormPage(recipe: recipe)));
    if (r == null) return;
    final i = _meals.indexWhere((x) => x.id == recipe.id);
    if (i >= 0) { _meals[i] = r; setState(() {}); }
  }

  Future<void> _addDish() async {
    final r = await Navigator.push<Recipe>(context, MaterialPageRoute(builder: (_) => const DishFormPage()));
    if (r != null) { _meals.add(r); setState(() {}); }
  }

  Future<void> _addCategory() async {
    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const CategoryFormPage()));
    if (ok == true) setState(() {});
  }

  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final meals = _filteredMeals;
    return Scaffold(body: SafeArea(child: Column(children: [
      Expanded(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const MenuHero(),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SearchBarWidget(onChanged: (v) => setState(() => _searchQuery = v))),
        const SizedBox(height: 12),
        ActionButtonsRow(onAddSection: _addCategory, onAddFood: _addDish),
        const SizedBox(height: 28),
        Padding(padding: const EdgeInsets.only(right: 20), child: Text('بەشەکان',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary.withValues(alpha: 0.6)))),
        const SizedBox(height: 12),
        SizedBox(height: 40, child: ListView.builder(scrollDirection: Axis.horizontal, reverse: true,
          itemCount: categories.length, padding: EdgeInsets.zero,
          itemBuilder: (context, index) => CategoryChip(icon: categories[index]['icon']!, name: categories[index]['name']!,
            isSelected: _selectedCategoryIndex == index, index: index,
            onTap: () => setState(() => _selectedCategoryIndex = index)))),
        const SizedBox(height: 24),
        if (meals.isEmpty)
          const SizedBox(height: 160, child: Center(child: Text('هیچ خواردنێک نەدۆزرایەوە',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))))
        else
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: GridView.builder(shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), itemCount: meals.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (context, index) { final r = meals[index]; return FoodCard(recipe: r,
              quantity: state.getQuantity(r.id), notes: state.getNotes(r.id),
              onIncrement: () => _increment(r), onDecrement: () => _decrement(r),
              onLongPress: () => _notes(r), onEdit: () => _edit(r)); })),
        const SizedBox(height: 100),
      ]))),
      if (state.cartCount > 0)
        MenuCartBar(cartCount: state.cartCount, cartTotal: state.cartTotal.toInt(), onViewCart: widget.onNavigateToCart),
    ])));
  }
}
