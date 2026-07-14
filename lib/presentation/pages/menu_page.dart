import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/search_bar_widget.dart';
import 'package:my_resturant/presentation/widgets/category_chip.dart';
import 'package:my_resturant/presentation/widgets/food_card.dart';
import 'package:my_resturant/presentation/widgets/menu_cart_bar.dart';
import 'package:my_resturant/presentation/widgets/notes_dialog.dart';
import 'package:my_resturant/presentation/widgets/settings_button.dart';
import 'package:my_resturant/data/models/categories.dart';

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});
  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  int _selectedCategoryIndex = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<Recipe> _filteredMeals(List<Recipe> allRecipes) {
    var list = allRecipes.where((r) => r.available).toList();
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

  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final state = context.watch<OrderCubit>().state;
    if (state.selectedTable == 0) return _buildTablePicker();
    final meals = _filteredMeals(state.recipes);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const SizedBox(height: 16),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SearchBarWidget(onChanged: (v) => setState(() => _searchQuery = v))),
                const SizedBox(height: 28),
                Padding(padding: const EdgeInsets.only(right: 20), child: Text(t('categories'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary.withValues(alpha: 0.6)))),
                const SizedBox(height: 12),
                SizedBox(height: 40, child: ListView.builder(scrollDirection: Axis.horizontal, reverse: true,
                  itemCount: categories.length, padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => CategoryChip(icon: categories[index]['icon']!, name: categories[index]['name']!,
                    isSelected: _selectedCategoryIndex == index, index: index, onTap: () => setState(() => _selectedCategoryIndex = index)))),
                const SizedBox(height: 24),
                if (meals.isEmpty)
                  SizedBox(height: 160, child: Center(child: Text(t('no_food_found'),
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14))))
                else
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: GridView.builder(shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), itemCount: meals.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemBuilder: (context, index) { final r = meals[index]; return FoodCard(recipe: r,
                      quantity: state.getQuantity(r.id), notes: state.getNotes(r.id),
                      onIncrement: () => _increment(r), onDecrement: () => _decrement(r), onLongPress: () => _notes(r)); })),
                const SizedBox(height: 100),
              ]),
            ),
          ),
          if (state.cartCount > 0)
            MenuCartBar(cartCount: state.cartCount, cartTotal: state.cartTotal.toInt(), onViewCart: () => context.go('/cart')),
        ]),
      ),
    );
  }

  Widget _buildTablePicker() {
    final s = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 8),
            Row(children: [const Spacer(), const SettingsButton()]),
            const SizedBox(height: 40),
            Container(width: 100, height: 100,
              decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
              child: const Icon(Icons.table_restaurant, size: 48, color: AppColors.primary)),
            const SizedBox(height: 24),
            Text(t('select_table'), textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1),
                itemCount: s.tableCount,
                itemBuilder: (context, i) {
                  final n = i + 1;
                  final locked = s.reservedTables.contains(n);
                  return Material(
                    color: locked ? cs.outline : AppColors.primary, borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: locked ? null : () => context.read<OrderCubit>().setSelectedTable(n),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        if (locked) ...[
                          Icon(Icons.lock, color: cs.surface, size: 20),
                          const SizedBox(height: 2),
                          Text('${t('table')} $n', style: TextStyle(color: cs.surface, fontSize: 13, fontWeight: FontWeight.w600)),
                        ] else ...[
                          Text('$n', style: TextStyle(color: cs.surface, fontSize: 24, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(t('table'), style: TextStyle(color: cs.surface.withValues(alpha: 0.7), fontSize: 11)),
                        ],
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}