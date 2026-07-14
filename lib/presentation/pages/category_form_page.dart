import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/data/models/categories.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

const List<String> _icons = [
  '🍽',
  '🍔',
  '🍕',
  '🌯',
  '🍗',
  '🥗',
  '🥪',
  '🌮',
  '🥟',
  '🍜',
  '🍝',
  '🍛',
  '🥘',
  '🫕',
  '🥙',
  '🧆',
  '🥩',
  '🍖',
  '🥦',
  '🥕',
  '🧅',
  '🫑',
  '🥐',
  '🥯',
  '🍞',
  '🥨',
  '🧀',
  '🥚',
  '🍳',
  '🥮',
  '🍦',
  '🍰',
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
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

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
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(t('add_category'))),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(R.padding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: t('category_name'),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t('choose_icon'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: R.categoryIconColumns(context),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final icon = _icons[index];
                      final sel = icon == _selectedIcon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                            border: sel
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: TextStyle(fontSize: sel ? 30 : 22),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      t('add'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
