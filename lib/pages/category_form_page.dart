import 'package:flutter/material.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/data/mock_data.dart';

const List<String> _icons = [
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
      body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        TextField(controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'ناوی بەش', filled: true)),
        const SizedBox(height: 24),
        const Text('هەڵبژاردنی ئایکۆن:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Expanded(child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: _icons.length,
          itemBuilder: (context, index) {
            final icon = _icons[index];
            final sel = icon == _selectedIcon;
            return GestureDetector(onTap: () => setState(() => _selectedIcon = icon),
              child: Container(
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary : const Color(0xFFF5F3F0),
                  borderRadius: BorderRadius.circular(10),
                  border: sel ? Border.all(color: AppTheme.primary, width: 2) : null),
                child: Center(child: Text(icon, style: TextStyle(fontSize: sel ? 30 : 22))),
              ),
            );
          },
        )),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
          onPressed: _save,
          child: const Text('زیادکردن', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
      ])),
    ));
  }
}
