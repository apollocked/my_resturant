import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';
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
  final List<Recipe> _meals = mockRecipes;
  int _selectedCategoryIndex = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<Recipe> get _filteredMeals {
    var list = _meals;
    final key = categories[_selectedCategoryIndex]['key'];
    if (key != 'all') list = list.where((r) => r.category == key).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) => r.name.contains(_searchQuery)).toList();
    }
    return list;
  }

  void _increment(Recipe r) => context.read<OrderViewModel>().addToCart(r);
  void _decrement(Recipe r) =>
      context.read<OrderViewModel>().decrementOrRemove(r.id);

  Future<void> _notes(Recipe recipe) async {
    final vm = context.read<OrderViewModel>();
    final r = await showDialog<String>(
      context: context,
      builder: (_) => _NotesDialog(initialNotes: vm.getNotes(recipe.id)),
    );
    if (r != null) vm.updateNotesByRecipe(recipe.id, r);
  }

  Future<void> _edit(Recipe recipe) async {
    final r = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(builder: (_) => DishFormPage(recipe: recipe)),
    );
    if (r == null) return;
    final i = _meals.indexWhere((x) => x.id == recipe.id);
    if (i >= 0) {
      _meals[i] = r;
      setState(() {});
    }
  }

  Future<void> _delete(Recipe recipe) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('سڕینەوەی خواردن'),
          content: Text('دڵنیای لە سڕینەوەی ${recipe.name}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ڕەتکردنەوە'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
              child: const Text('سڕینەوە'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      _meals.removeWhere((r) => r.id == recipe.id);
      setState(() {});
    }
  }

  Future<void> _addDish() async {
    final r = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(builder: (_) => const DishFormPage()),
    );
    if (r != null) {
      _meals.add(r);
      setState(() {});
    }
  }

  Future<void> _addCategory() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CategoryFormPage()),
    );
    if (ok == true) setState(() {});
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final meals = _filteredMeals;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppTheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: -20,
                            bottom: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'بەخێربێیت بۆ ڕێستۆرانتەکەم',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'داوای خواردنی خوازەکەت بکە',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Icon(
                              Icons.restaurant_menu,
                              color: Colors.white.withValues(alpha: 0.15),
                              size: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SearchBarWidget(
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ActionButtonsRow(
                      onAddSection: _addCategory,
                      onAddFood: _addDish,
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        'بەشەکان',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        itemCount: categories.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) => CategoryChip(
                          icon: categories[index]['icon']!,
                          name: categories[index]['name']!,
                          isSelected: _selectedCategoryIndex == index,
                          index: index,
                          onTap: () =>
                              setState(() => _selectedCategoryIndex = index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (meals.isEmpty)
                      const SizedBox(
                        height: 160,
                        child: Center(
                          child: Text(
                            'هیچ خواردنێک نەدۆزرایەوە',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: meals.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final r = meals[index];
                            return FoodCard(
                              recipe: r,
                              quantity: vm.getQuantity(r.id),
                              notes: vm.getNotes(r.id),
                              onIncrement: () => _increment(r),
                              onDecrement: () => _decrement(r),
                              onLongPress: () => _notes(r),
                              onEdit: () => _edit(r),
                              onDelete: () => _delete(r),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            if (vm.cartCount > 0)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: const Border(
                    top: BorderSide(color: Color(0xFFF0EDEA)),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${vm.cartTotal.toInt()} د.ع',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: AppTheme.primary,
                              ),
                            ),
                            Text(
                              '${vm.cartCount} دانە',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: widget.onNavigateToCart,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shopping_bag, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'سەیرکردنی داواکاری',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotesDialog extends StatefulWidget {
  final String initialNotes;
  const _NotesDialog({required this.initialNotes});
  @override
  State<_NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<_NotesDialog> {
  late final TextEditingController _c;
  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: AlertDialog(
      title: const Text('تێبینی بۆ خواردن'),
      content: TextField(
        controller: _c,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'تێبینیەکانت بنووسە...'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ڕەتکردنەوە'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _c.text),
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
          child: const Text('پاشەکەوت'),
        ),
      ],
    ),
  );
}
