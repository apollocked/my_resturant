import 'package:flutter/material.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/data/mock_data.dart';

class DishFormPage extends StatefulWidget {
  final Recipe? recipe;
  const DishFormPage({super.key, this.recipe});
  @override
  State<DishFormPage> createState() => _DishFormPageState();
}

class _DishFormPageState extends State<DishFormPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageCtrl;
  late String _category;
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _priceCtrl = TextEditingController(text: r?.price.toInt().toString() ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _imageCtrl = TextEditingController(text: r?.imageUrl ?? 'https://picsum.photos/seed/');
    _category = r?.category ?? categories[1]['key']!;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _priceCtrl.dispose(); _descCtrl.dispose(); _imageCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final r = Recipe(
      id: _isEditing ? widget.recipe!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(), price: price,
      description: _descCtrl.text.trim(), category: _category,
      imageUrl: _imageCtrl.text.trim().isEmpty ? 'https://picsum.photos/seed/${_nameCtrl.text.trim()}/400/300' : _imageCtrl.text.trim(),
    );
    Navigator.pop(context, r);
  }

  @override
  Widget build(BuildContext context) {
    final catKeys = categories.where((c) => c['key'] != 'all').toList();
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'نووسینەوەی خواردن' : 'زیادکردنی خواردن')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          if (_imageCtrl.text.isNotEmpty)
            ClipRRect(borderRadius: BorderRadius.circular(8),
              child: Image.network(_imageCtrl.text, height: 120, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 120, color: const Color(0xFFF0F0F0),
                    child: const Icon(Icons.restaurant, color: Color(0xFFD0D0D0), size: 40)))),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'ناوی خواردن', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _priceCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'نرخ (دینار)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, maxLines: 2,
              decoration: const InputDecoration(labelText: 'وەسف', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _imageCtrl,
              decoration: const InputDecoration(labelText: 'لینکی وێنە', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category, decoration: const InputDecoration(labelText: 'بەش', border: OutlineInputBorder()),
            items: catKeys.map((c) => DropdownMenuItem(value: c['key'], child: Text('${c['icon']} ${c['name']}'))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2EC153),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text(_isEditing ? 'نووسینەوە' : 'زیادکردن',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          )),
        ]),
      ),
    ));
  }
}
