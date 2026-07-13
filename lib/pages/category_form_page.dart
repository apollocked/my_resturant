import 'package:flutter/material.dart';
import 'package:my_resturant/data/mock_data.dart';

const List<String> _iconOptions = [
  '🍽', '🍔', '🍕', '🌯', '🍗', '🥗', '🥪', '🌮', '🥟', '🍜', '🍝', '🍛', '🥘', '🫕', '🥙', '🧆',
  '🥩', '🍖', '🥦', '🥕', '🧅', '🫑', '🥐', '🥯', '🍞', '🥨', '🧀', '🥚', '🍳', '🥮', '🍦', '🍰',
];

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key});
  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _nameCtrl = TextEditingController();
  String _selectedIcon = '🍽';

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final key = name.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    if (categories.any((c) => c['key'] == key)) return;
    categories.add({'key': key, 'name': name, 'icon': _selectedIcon});
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(title: const Text('زیادکردنی بەش')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          TextField(controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'ناوی بەش', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          const Text('هەڵبژاردنی ئایکۆن:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _iconOptions.length,
              itemBuilder: (context, index) {
                final icon = _iconOptions[index];
                final isSelected = icon == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2EC153) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: const Color(0xFF2EC153), width: 2) : null,
                    ),
                    child: Center(child: Text(icon, style: TextStyle(fontSize: isSelected ? 32 : 24))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2EC153),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('زیادکردن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          )),
        ]),
      ),
    ));
  }
}
