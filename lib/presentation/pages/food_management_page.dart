import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/data/models/categories.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/widgets/app_image.dart';

class FoodManagementPage extends StatefulWidget {
  const FoodManagementPage({super.key});
  @override State<FoodManagementPage> createState() => _FoodManagementPageState();
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
    final nameCtl = TextEditingController(text: r.name);
    final priceCtl = TextEditingController(text: r.price.toInt().toString());
    final descCtl = TextEditingController(text: r.description);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
        title: Text(_t('edit_food')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtl, decoration: InputDecoration(labelText: _t('name'), border: const OutlineInputBorder()), textDirection: TextDirection.rtl),
          const SizedBox(height: 12),
          TextField(controller: priceCtl, decoration: InputDecoration(labelText: _t('price'), border: const OutlineInputBorder()), keyboardType: TextInputType.number, textDirection: TextDirection.rtl),
          const SizedBox(height: 12),
          TextField(controller: descCtl, decoration: InputDecoration(labelText: _t('description'), border: const OutlineInputBorder()), textDirection: TextDirection.rtl, maxLines: 2),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, {'name': nameCtl.text, 'price': double.tryParse(priceCtl.text), 'description': descCtl.text}),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary), child: Text(_t('update'))),
        ],
      )),
    );
    if (result != null) {
      context.read<OrderCubit>().updateRecipe(r.id,
        name: result['name'] as String,
        price: result['price'] as double?,
        description: result['description'] as String?,
      );
    }
  }

  Future<void> _confirmDelete(Recipe r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
        title: Text(_t('delete_food')),
        content: Text(_t('delete_confirm').replaceAll('{name}', r.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error), child: Text(_t('delete'))),
        ],
      )),
    );
    if (ok == true) context.read<OrderCubit>().deleteRecipe(r.id);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<OrderCubit>();
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final dishes = _filtered;
    return Scaffold(
      appBar: AppBar(title: Text(t('food_mgmt_title'))),
      body: SafeArea(child: Directionality(textDirection: TextDirection.rtl, child: Column(children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final isSel = _selectedCat == i;
              return Padding(padding: const EdgeInsets.only(left: 8), child: GestureDetector(
                onTap: () => setState(() => _selectedCat = i),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary : cs.outlineVariant,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8)] : null),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(categories[i]['icon']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(categories[i]['name']!, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: isSel ? cs.onPrimary : cs.onSurfaceVariant)),
                  ]),
                ),
              ));
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: dishes.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 100, height: 100, decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
                child: Icon(Icons.restaurant_menu, size: 44, color: cs.onSurfaceVariant)),
              const SizedBox(height: 20),
              Text(t('no_food_found'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            ]))
          : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final r = dishes[index];
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: ClipRRect(borderRadius: BorderRadius.circular(8),
                child: AppImage(r.imageUrl, width: 48, height: 48)),
              title: Text(r.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
              subtitle: Text('${r.price.toInt()} ${t('currency_suffix')} • ${r.category}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                  onPressed: () => _editRecipe(r)),
                IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: () => _confirmDelete(r)),
              ]),
            ));
          },
        )),
      ]))),
    );
  }
}
