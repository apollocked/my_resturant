import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/data/models/default_categories.dart';

class EditRecipeDialog extends StatefulWidget {
  final String name, description;
  final double price;
  final String category;
  final String Function(String) t;
  final List<Map<String, String>> categories;

  const EditRecipeDialog({super.key, required this.name, required this.price, required this.description, required this.category, required this.t, required this.categories});

  @override
  State<EditRecipeDialog> createState() => _EditRecipeDialogState();
}

class _EditRecipeDialogState extends State<EditRecipeDialog> {
  late final TextEditingController _nameCtl, _priceCtl, _descCtl;
  late String _cat;

  @override void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.name);
    _priceCtl = TextEditingController(text: widget.price.toInt().toString());
    _descCtl = TextEditingController(text: widget.description);
    final cats = effectiveCategories(widget.categories);
    final match = cats.any((c) => c['key'] == widget.category);
    _cat = match ? widget.category : (cats.isNotEmpty ? cats.first['key']! : 'burger');
  }

  @override void dispose() { _nameCtl.dispose(); _priceCtl.dispose(); _descCtl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cats = effectiveCategories(widget.categories);
    final isWide = R.isDesktop(context) || R.isTablet(context);
    final nameField = TextField(controller: _nameCtl, decoration: InputDecoration(labelText: widget.t('name'), border: const OutlineInputBorder()), textDirection: TextDirection.rtl);
    final priceField = TextField(controller: _priceCtl, decoration: InputDecoration(labelText: widget.t('price'), border: const OutlineInputBorder()), keyboardType: TextInputType.number, textDirection: TextDirection.rtl);
    final categoryField = StatefulBuilder(builder: (ctx, setLocal) => DropdownButtonFormField<String>(
      initialValue: _cat,
      decoration: InputDecoration(labelText: widget.t('category'), border: const OutlineInputBorder()),
      items: cats.map((c) => DropdownMenuItem(value: c['key'], child: Text('${c['icon']} ${c['name']}'))).toList(),
      onChanged: (v) { if (v != null) setLocal(() => _cat = v); },
    ));
    final descField = TextField(controller: _descCtl, decoration: InputDecoration(labelText: widget.t('description'), border: const OutlineInputBorder()), textDirection: TextDirection.rtl, maxLines: 2);
    return Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
      title: Text(widget.t('edit_food')),
      constraints: isWide ? const BoxConstraints(maxWidth: 560) : null,
      content: SingleChildScrollView(
        child: isWide
            ? LayoutBuilder(builder: (ctx, c) {
                final half = (c.maxWidth - 12) / 2;
                return Wrap(spacing: 12, runSpacing: 12, children: [
                  SizedBox(width: half, child: nameField),
                  SizedBox(width: half, child: priceField),
                  SizedBox(width: c.maxWidth, child: categoryField),
                  SizedBox(width: c.maxWidth, child: descField),
                ]);
              })
            : Column(mainAxisSize: MainAxisSize.min, children: [
                nameField,
                const SizedBox(height: 12),
                priceField,
                const SizedBox(height: 12),
                categoryField,
                const SizedBox(height: 12),
                descField,
              ]),
      ),
      actions: [
        OverflowBar(spacing: 8, alignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, {
            'name': _nameCtl.text, 'price': double.tryParse(_priceCtl.text) ?? widget.price, 'description': _descCtl.text, 'category': _cat,
          }), style: FilledButton.styleFrom(backgroundColor: AppColors.primary), child: Text(widget.t('update'))),
        ]),
      ],
    ));
  }
}
