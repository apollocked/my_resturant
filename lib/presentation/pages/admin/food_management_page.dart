import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/widgets/shared/app_image.dart';
import 'package:my_resturant/data/models/default_categories.dart';
import 'package:my_resturant/presentation/widgets/admin/delete_confirm_dialog.dart';
import 'package:my_resturant/presentation/widgets/admin/category_filter_bar.dart';
import 'package:my_resturant/presentation/widgets/shared/shimmer_skeletons.dart';
import 'package:my_resturant/presentation/widgets/shared/empty_state.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

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

  String _t(String key) => Tr.get(key, context.read<SettingsCubit>().state.locale);

  Future<void> _editRecipe(Recipe r) async {
    if (!mounted) return;
    final orderCubit = context.read<OrderCubit>();
    final result = await context.push<Recipe>('/dish-form', extra: r);
    if (!mounted || result == null) return;
    try {
      await orderCubit.updateRecipe(
        result.id,
        name: result.name,
        price: result.price,
        description: result.description,
        category: result.category,
        imageUrl: result.imageUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('dish_updated'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_t('error_occurred')}: $e')),
        );
      }
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
    final dishes = _filtered;
    final isGrid = !R.isPhone(context);
    return Scaffold(
      appBar: AppBar(title: Text(t('food_mgmt_title'))),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const SizedBox(height: 12),
              CategoryFilterBar(selectedIndex: _selectedCat, onChanged: (i) => setState(() => _selectedCat = i), categories: context.read<OrderCubit>().state.categories),
              const SizedBox(height: 8),
              Expanded(
                child: context.read<OrderCubit>().state.isLoading && dishes.isEmpty
                    ? isGrid
                        ? GridView(
                            padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: R.menuGridColumns(context), childAspectRatio: 1.9,
                              crossAxisSpacing: R.gridSpacing(context), mainAxisSpacing: R.gridSpacing(context),
                            ),
                            children: List.generate(6, (_) => const ShimmerListTile()))
                        : ShimmerListView(itemCount: 6, itemBuilder: () => const ShimmerListTile())
                    : dishes.isEmpty
                    ? EmptyState(icon: Icons.restaurant_menu, title: t('no_food_found'), subtitle: t('no_food_found_subtitle'))
                    : isGrid
                        ? GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: R.menuGridColumns(context),
                              childAspectRatio: 1.9,
                              crossAxisSpacing: R.gridSpacing(context),
                              mainAxisSpacing: R.gridSpacing(context),
                            ),
                            itemCount: dishes.length,
                            itemBuilder: (context, index) => _dishCard(dishes[index], cs, t),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                            itemCount: dishes.length,
                            itemBuilder: (context, index) => _dishTile(dishes[index], cs, t),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dishTile(Recipe r, ColorScheme cs, String Function(String) t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: AppImage(r.imageUrl, width: 48, height: 48)),
        title: Text(r.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: R.fontMd(context), color: cs.onSurface)),
        subtitle: Text('${r.price.toInt()} ${t('currency_suffix')} • ${r.category}', style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20), onPressed: () => _editRecipe(r)),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => _confirmDelete(r)),
        ]),
      ),
    );
  }

  Widget _dishCard(Recipe r, ColorScheme cs, String Function(String) t) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(R.cardPadding(context)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18), onPressed: () => _editRecipe(r), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18), onPressed: () => _confirmDelete(r), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            const Spacer(),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: AppImage(r.imageUrl, width: 44, height: 44)),
            const SizedBox(width: 10),
          ]),
          const Spacer(),
          Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: R.fontMd(context), color: cs.onSurface)),
          const SizedBox(height: 2),
          Text('${r.price.toInt()} ${t('currency_suffix')} • ${r.category}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
