import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/data/models/default_categories.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/category_filter_bar.dart';
import 'package:my_resturant/presentation/widgets/admin/delete_confirm_dialog.dart';
import 'package:my_resturant/presentation/widgets/admin/food_list_view.dart';

class FoodManagementPage extends StatefulWidget {
  const FoodManagementPage({super.key});
  @override
  State<FoodManagementPage> createState() => _FoodManagementPageState();
}

class _FoodManagementPageState extends State<FoodManagementPage> {
  int _selectedCat = 0;

  List<Recipe> get _filtered {
    final state = context.read<OrderCubit>().state;
    final recipes = state.recipes;
    if (_selectedCat == 0) return recipes;
    final cats = effectiveCategories(state.categories);
    final idx = _selectedCat - 1;
    if (idx >= cats.length) return recipes;
    return recipes.where((r) => r.category == cats[idx]['key']).toList();
  }

  String _t(String key) =>
      Tr.get(key, context.read<SettingsCubit>().state.locale);

  Future<void> _editRecipe(Recipe r) async {
    if (!mounted) return;
    final orderCubit = context.read<OrderCubit>();
    final result = await context.push<Recipe>('/dish-form', extra: r);
    if (!mounted || result == null) return;
    final ok = await orderCubit.updateRecipe(
        result.id,
        name: result.name,
        price: result.price,
        description: result.description,
        category: result.category,
        imageUrl: result.imageUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_t(ok ? 'dish_updated' : 'error_occurred'))));
      }
  }

  Future<void> _confirmDelete(Recipe r) async {
    if (!mounted) return;
    final orderCubit = context.read<OrderCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(
        title: _t('delete_food'),
        content: _t('delete_confirm').replaceAll('{name}', r.name),
        cancelLabel: _t('cancel'),
        deleteLabel: _t('delete'),
      ),
    );
    if (!mounted) return;
    if (ok == true) orderCubit.deleteRecipe(r.id);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<OrderCubit>();
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t('food_mgmt_title'))),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            CategoryFilterBar(
              selectedIndex: _selectedCat,
              onChanged: (i) => setState(() => _selectedCat = i),
              categories: context.read<OrderCubit>().state.categories,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FoodListView(
                isLoading: context.read<OrderCubit>().state.isLoading,
                dishes: _filtered,
                isGrid: !R.isPhone(context),
                t: t,
                cs: cs,
                onEdit: _editRecipe,
                onDelete: _confirmDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
