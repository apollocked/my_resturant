import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/data/mock_data.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/widgets/app_image.dart';

class FoodManagementPage extends StatefulWidget {
  const FoodManagementPage({super.key});
  @override State<FoodManagementPage> createState() => _FoodManagementPageState();
}

class _FoodManagementPageState extends State<FoodManagementPage> {
  int _selectedCat = 0;

  List<Recipe> get _filtered {
    if (_selectedCat == 0) return mockRecipes;
    return mockRecipes.where((r) => r.category == categories[_selectedCat]['key']).toList();
  }

  Future<void> _editRecipe(Recipe r) async {
    final nameCtl = TextEditingController(text: r.name);
    final priceCtl = TextEditingController(text: r.price.toInt().toString());
    final descCtl = TextEditingController(text: r.description);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
        title: const Text('گۆڕینی خواردن'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'ناو', border: OutlineInputBorder()), textDirection: TextDirection.rtl),
          const SizedBox(height: 12),
          TextField(controller: priceCtl, decoration: const InputDecoration(labelText: 'نرخ', border: OutlineInputBorder()), keyboardType: TextInputType.number, textDirection: TextDirection.rtl),
          const SizedBox(height: 12),
          TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'وەسف', border: OutlineInputBorder()), textDirection: TextDirection.rtl, maxLines: 2),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ڕەتکردنەوە')),
          FilledButton(onPressed: () => Navigator.pop(ctx, {'name': nameCtl.text, 'price': double.tryParse(priceCtl.text), 'description': descCtl.text}),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary), child: const Text('نوێکردنەوە')),
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
        title: const Text('سڕینەوەی خواردن'),
        content: Text('دڵنیای لە سڕینەوەی ${r.name}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ڕەتکردنەوە')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error), child: const Text('سڕینەوە')),
        ],
      )),
    );
    if (ok == true) context.read<OrderCubit>().deleteRecipe(r.id);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<OrderCubit>();
    final dishes = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('بەڕێوەبردنی خواردنەکان')),
      body: Directionality(textDirection: TextDirection.rtl, child: Column(children: [
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
                    color: isSel ? AppTheme.primary : const Color(0xFFF0EDEA),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSel ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 8)] : null),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(categories[i]['icon']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(categories[i]['name']!, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: isSel ? Colors.white : AppTheme.textSecondary)),
                  ]),
                ),
              ));
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final r = dishes[index];
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: ClipRRect(borderRadius: BorderRadius.circular(8),
                child: AppImage(r.imageUrl, width: 48, height: 48)),
              title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
              subtitle: Text('${r.price.toInt()} د.ع • ${r.category}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
                  onPressed: () => _editRecipe(r)),
                IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                  onPressed: () => _confirmDelete(r)),
              ]),
            ));
          },
        )),
      ])),
    );
  }
}
