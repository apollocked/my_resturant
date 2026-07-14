import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/data/models/categories.dart';

class EditRecipeDialog extends StatefulWidget {
  final String name, description;
  final double price;
  final String category;
  final String Function(String) t;

  const EditRecipeDialog({super.key, required this.name, required this.price, required this.description, required this.category, required this.t});

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
    _cat = widget.category;
  }

  @override void dispose() { _nameCtl.dispose(); _priceCtl.dispose(); _descCtl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
      title: Text(widget.t('edit_food')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nameCtl, decoration: InputDecoration(labelText: widget.t('name'), border: const OutlineInputBorder()), textDirection: TextDirection.rtl),
        const SizedBox(height: 12),
        TextField(controller: _priceCtl, decoration: InputDecoration(labelText: widget.t('price'), border: const OutlineInputBorder()), keyboardType: TextInputType.number, textDirection: TextDirection.rtl),
        const SizedBox(height: 12),
        StatefulBuilder(builder: (ctx, setLocal) => DropdownButtonFormField<String>(
          initialValue: _cat, decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
          items: categories.where((c) => c['key'] != 'all').map((c) => DropdownMenuItem(value: c['key'], child: Text('${c['icon']} ${c['name']}'))).toList(),
          onChanged: (v) { if (v != null) setLocal(() => _cat = v); },
        )),
        const SizedBox(height: 12),
        TextField(controller: _descCtl, decoration: InputDecoration(labelText: widget.t('description'), border: const OutlineInputBorder()), textDirection: TextDirection.rtl, maxLines: 2),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.t('cancel'))),
        FilledButton(onPressed: () => Navigator.pop(context, {
          'name': _nameCtl.text, 'price': double.tryParse(_priceCtl.text), 'description': _descCtl.text, 'category': _cat,
        }), style: FilledButton.styleFrom(backgroundColor: AppColors.primary), child: Text(widget.t('update'))),
      ],
    ));
  }
}
