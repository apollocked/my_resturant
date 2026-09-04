import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/category_icon_picker.dart';
import 'package:my_resturant/presentation/widgets/admin/category_save_button.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key});
  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _nameCtrl = TextEditingController();
  String _selectedIcon = '🍽';
  bool _saving = false;

  String _t(String key) =>
      Tr.get(key, context.read<SettingsCubit>().state.locale);

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _saving) return;
    final key = name.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    if (!RegExp(r'^[a-z0-9_]{1,32}$').hasMatch(key) || key == 'all') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('invalid_category')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final existing = context.read<OrderCubit>().state.categories;
    if (existing.any((c) => c['key'] == key)) return;
    setState(() => _saving = true);
    try {
      await context.read<OrderCubit>().addCategory(key, name, _selectedIcon);
      if (mounted) {
        Navigator.pop(context, {'key': key, 'name': name, 'icon': _selectedIcon});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t('add_category'))),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(R.padding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _nameCtrl,
                maxLength: 32,
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
                  fontSize: R.fontMd(context),
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CategoryIconPicker(
                  selected: _selectedIcon,
                  onSelect: (icon) => setState(() => _selectedIcon = icon),
                ),
              ),
              const SizedBox(height: 16),
              CategorySaveButton(
                loading: _saving,
                label: t('add'),
                onTap: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
