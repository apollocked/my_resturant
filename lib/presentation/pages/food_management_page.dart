import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/data/models/categories.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/widgets/shared/app_image.dart';
import 'package:my_resturant/presentation/widgets/admin/edit_recipe_dialog.dart';
import 'package:my_resturant/presentation/widgets/admin/delete_confirm_dialog.dart';
import 'package:my_resturant/presentation/widgets/admin/category_filter_bar.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class FoodManagementPage extends StatefulWidget {
  const FoodManagementPage({super.key});
  @override
  State<FoodManagementPage> createState() => _FoodManagementPageState();
}

class _FoodManagementPageState extends State<FoodManagementPage> {
  int _selectedCat = 0;

  List<Recipe> get _filtered {
    final recipes = context.read<OrderCubit>().state.recipes;
    if (_selectedCat == 0) return recipes;
    return recipes.where((r) => r.category == categories[_selectedCat]['key']).toList();
  }

  String _t(String key) => Tr.get(key, context.read<SettingsCubit>().state.locale);

  Future<void> _editRecipe(Recipe r) async {
    if (!mounted) return;
    final orderCubit = context.read<OrderCubit>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditRecipeDialog(
        name: r.name, price: r.price, description: r.description, category: r.category, t: _t,
      ),
    );
    if (!mounted) return;
    if (result != null) {
      orderCubit.updateRecipe(r.id,
        name: result['name'] as String,
        price: result['price'] as double?,
        description: result['description'] as String?,
        category: result['category'] as String?,
      );
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
    final isDesktop = R.isDesktop(context);
    return Scaffold(
      appBar: AppBar(title: Text(t('food_mgmt_title'))),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const SizedBox(height: 12),
              CategoryFilterBar(selectedIndex: _selectedCat, onChanged: (i) => setState(() => _selectedCat = i)),
              const SizedBox(height: 8),
              Expanded(
                child: dishes.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(width: isDesktop ? 120 : 100, height: isDesktop ? 120 : 100,
                          decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
                          child: Icon(Icons.restaurant_menu, size: isDesktop ? 56 : 44, color: cs.onSurfaceVariant)),
                        const SizedBox(height: 20),
                        Text(t('no_food_found'), style: TextStyle(fontSize: R.fontLg(context), fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ]))
                    : isDesktop
                        ? GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.2,
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
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18), onPressed: () => _editRecipe(r), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18), onPressed: () => _confirmDelete(r), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            const Spacer(),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: AppImage(r.imageUrl, width: 44, height: 44)),
            const SizedBox(width: 10),
          ]),
          const Spacer(),
          Text(r.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text('${r.price.toInt()} ${t('currency_suffix')} • ${r.category}', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
