import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/data/models/default_categories.dart';
import 'package:my_resturant/presentation/widgets/menu/item_on_hold_sheet.dart';
import 'package:my_resturant/presentation/widgets/menu/table_picker.dart';
import 'package:my_resturant/presentation/widgets/menu/menu_shimmer_loader.dart';
import 'package:my_resturant/presentation/widgets/menu/menu_layout.dart';
import 'package:my_resturant/shared/table_selector.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/confirm_dialog.dart';

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});
  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  String _selectedCategoryKey = 'all';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<Map<String, String>> _allCats(
    List<Map<String, String>> dbCats,
    String Function(String) t,
  ) => [
    {'key': 'all', 'name': t('cat_all'), 'icon': '🍽️'},
    ...effectiveCategories(dbCats),
  ];

  List<Recipe> _filteredMeals(
    List<Recipe> allRecipes,
    List<Map<String, String>> cats,
  ) {
    var list = allRecipes.where((r) => r.available).toList();
    final key = cats.any((c) => c['key'] == _selectedCategoryKey)
        ? _selectedCategoryKey
        : 'all';
    if (key != 'all') list = list.where((r) => r.category == key).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) => r.name.contains(_searchQuery)).toList();
    }
    return list;
  }

  void _increment(Recipe r) => context.read<OrderCubit>().addToCart(r);
  void _decrement(Recipe r) =>
      context.read<OrderCubit>().decrementOrRemove(r.id);
  Future<void> _remove(Recipe r) async {
    if (!mounted) return;
    final settings = context.read<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final ok = await showConfirmDialog(
      context,
      title: t('delete_from_order'),
      message: t('delete_confirm').replaceAll('{name}', r.name),
      confirmLabel: t('delete'),
      cancelLabel: t('cancel'),
      confirmColor: AppColors.error,
    );
    if (ok && mounted) {
      context.read<OrderCubit>().removeFromCartById(r.id);
    }
  }

  Future<void> _notes(Recipe recipe) async {
    if (!mounted) return;
    final orderCubit = context.read<OrderCubit>();
    final r = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemOnHoldSheet(
        recipe: recipe,
        initialNotes: orderCubit.state.getNotes(recipe.id),
      ),
    );
    if (!mounted) return;
    if (r != null) orderCubit.updateNotesByRecipe(recipe.id, r);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<OrderCubit>().state;

    if (state.selectedTable == 0) return const TablePicker();
    if (state.isLoading && state.recipes.isEmpty) {
      return const MenuShimmerLoader();
    }

    final cats = _allCats(state.categories, t);
    final meals = _filteredMeals(state.recipes, cats);
    final selectedIndex = cats.indexWhere((c) => c['key'] == _selectedCategoryKey);
    void onCat(int i) =>
        setState(() => _selectedCategoryKey = cats[i]['key']!);
    void onSearch(String v) => setState(() => _searchQuery = v);

    final Widget layout = MenuLayout(
      cs: cs,
      t: t,
      state: state,
      meals: meals,
      cats: cats,
      selectedIndex: selectedIndex,
      onCategoryChanged: onCat,
      onSearchChanged: onSearch,
      onIncrement: _increment,
      onDecrement: _decrement,
      onRemove: _remove,
      onLongPress: _notes,
    );

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            R.padding(context),
            R.padding(context),
            R.padding(context),
            0,
          ),
          child: Row(
            children: [
              const Spacer(),
              TableSelector(
                selectedTable: state.selectedTable,
                onChanged: (t) =>
                    context.read<OrderCubit>().setSelectedTable(t),
                reservedTables: state.reservedTables,
              ),
            ],
          ),
        ),
        Expanded(child: layout),
      ],
    );
  }
}
