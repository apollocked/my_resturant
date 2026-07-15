// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/data/models/categories.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/admin/dish_form_fields.dart';

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
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  String _t(String key) =>
      Tr.get(key, context.read<SettingsCubit>().state.locale);

  Future<void> _pickImage() async {
    try {
      final perm = await PhotoManager.requestPermissionExtend();
      if (perm != PermissionState.authorized &&
          perm != PermissionState.limited) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_t('permission_needed'))));
        }
        return;
      }
      final files = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
        ),
      );
      if (files == null || files.isEmpty) return;
      final file = await files.first.file;
      if (file == null) return;
      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: _t('crop_image'),
            toolbarColor: AppColors.primary,
          ),
          IOSUiSettings(title: _t('crop_image')),
        ],
      );
      if (cropped != null) _imageUrl.value = cropped.path;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final r = Recipe(
      id: _isEditing
          ? widget.recipe!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      description: _descCtrl.text.trim(),
      category: _category,
      imageUrl: _imageUrl.value.isEmpty
          ? 'https://picsum.photos/seed/${_nameCtrl.text.trim()}/400/300'
          : _imageUrl.value,
    );
    Navigator.pop(context, r);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? _t('edit_dish') : _t('add_dish')),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                DishFormFields(
                  formKey: _formKey,
                  nameCtrl: _nameCtrl,
                  priceCtrl: _priceCtrl,
                  descCtrl: _descCtrl,
                  imageUrl: _imageUrl,
                  initialCategory: _category,
                  t: _t,
                  isEditing: _isEditing,
                  onPickImage: _pickImage,
                  onCategoryChanged: (v) => _category = v,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      _isEditing ? _t('update_btn') : _t('add_btn'),
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
