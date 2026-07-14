import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/data/categories.dart';
import 'package:my_resturant/cubits/settings_cubit.dart';
import 'package:my_resturant/l10n/tr.dart';
import 'package:my_resturant/widgets/app_image.dart';

class DishFormPage extends StatefulWidget {
  final Recipe? recipe;
  const DishFormPage({super.key, this.recipe});
  @override
  State<DishFormPage> createState() => _DishFormPageState();
}

class _DishFormPageState extends State<DishFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl, _priceCtrl, _descCtrl;
  final _imageUrl = ValueNotifier<String>('');
  late String _category;
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _priceCtrl = TextEditingController(text: r?.price.toInt().toString() ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _imageUrl.value = r?.imageUrl ?? '';
    _category = r?.category ?? categories[1]['key']!;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _priceCtrl.dispose(); _descCtrl.dispose(); _imageUrl.dispose();
    super.dispose();
  }

  String _t(String key) => Tr.get(key, context.read<SettingsCubit>().state.locale);

  Future<void> _pickImage() async {
    try {
      final perm = await PhotoManager.requestPermissionExtend();
      if (perm != PermissionState.authorized && perm != PermissionState.limited) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_t('permission_needed'))));
        }
        return;
      }
      final files = await AssetPicker.pickAssets(context,
          pickerConfig: const AssetPickerConfig(maxAssets: 1, requestType: RequestType.image));
      if (files == null || files.isEmpty) return;
      final file = await files.first.file;
      if (file == null) return;
      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(toolbarTitle: _t('crop_image'), toolbarColor: AppTheme.primary),
          IOSUiSettings(title: _t('crop_image')),
        ],
      );
      if (cropped != null) _imageUrl.value = cropped.path;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final r = Recipe(
      id: _isEditing ? widget.recipe!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(), price: double.tryParse(_priceCtrl.text) ?? 0,
      description: _descCtrl.text.trim(), category: _category,
      imageUrl: _imageUrl.value.isEmpty
          ? 'https://picsum.photos/seed/${_nameCtrl.text.trim()}/400/300' : _imageUrl.value,
    );
    Navigator.pop(context, r);
  }

  @override
  Widget build(BuildContext context) {
    final catKeys = categories.where((c) => c['key'] != 'all').toList();
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(title: Text(_isEditing ? _t('edit_dish') : _t('add_dish'))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(children: [
        ValueListenableBuilder<String>(valueListenable: _imageUrl,
          builder: (_, url, _) => url.isEmpty ? const SizedBox(height: 130)
              : ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: AppImage(url, width: double.infinity, height: 130))),
        const SizedBox(height: 16),
        TextFormField(controller: _nameCtrl,
          decoration: InputDecoration(labelText: _t('dish_name'), filled: true),
          validator: (v) => v == null || v.trim().isEmpty ? _t('dish_name_required') : null),
        const SizedBox(height: 12),
        TextFormField(controller: _priceCtrl, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: _t('price_dinar'), filled: true),
          validator: (v) {
            if (v == null || v.isEmpty) return _t('price_required');
            final n = int.tryParse(v);
            return (n == null || n <= 0) ? _t('price_invalid') : null;
          }),
        const SizedBox(height: 12),
        TextFormField(controller: _descCtrl, maxLines: 2,
          decoration: InputDecoration(labelText: _t('description'), filled: true)),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: _pickImage,
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary,
            side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.wallpaper, size: 18), const SizedBox(width: 8),
            Text(_t('pick_image'), style: const TextStyle(fontWeight: FontWeight.w600)),
          ]))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: _category,
          decoration: InputDecoration(labelText: _t('section_field'), filled: true),
          items: catKeys.map((c) => DropdownMenuItem(value: c['key'],
              child: Text('${c['icon']} ${c['name']}'))).toList(),
          onChanged: (v) => setState(() => _category = v!)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
          onPressed: _save,
          child: Text(_isEditing ? _t('update_btn') : _t('add_btn'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
      ]))),
    ));
  }
}
