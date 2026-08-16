// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/dish_form_fields.dart';
import 'package:my_resturant/presentation/widgets/admin/dish_image_picker.dart';
import 'package:my_resturant/presentation/widgets/admin/dish_image_uploader.dart';
import 'package:my_resturant/presentation/widgets/admin/dish_save_button.dart';
import 'package:uuid/uuid.dart';

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
  late final DishImagePicker _picker;
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _priceCtrl = TextEditingController(text: r?.price.toInt().toString() ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _imageUrl.value = r?.imageUrl ?? '';
    _category = r?.category ?? 'burger';
    _picker = DishImagePicker(t: _t, onPicked: (v) => _imageUrl.value = v);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = _isEditing ? widget.recipe!.id : const Uuid().v4();
    String imageUrl = _imageUrl.value;
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      try {
        imageUrl = await uploadDishImage(id, imageUrl);
      } catch (e) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t('error_occurred')),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      if (mounted) Navigator.pop(context);
    }
    final r = Recipe(
      id: id,
      name: _nameCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      description: _descCtrl.text.trim(),
      category: _category,
      imageUrl: imageUrl,
    );
    if (mounted) Navigator.pop(context, r);
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
            padding: EdgeInsets.all(R.padding(context)),
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
                  onPickImage: () => _picker.showSourceSheet(context),
                  onCategoryChanged: (v) => _category = v,
                  categories: context.read<OrderCubit>().state.categories,
                ),
                const SizedBox(height: 24),
                DishSaveButton(isEditing: _isEditing, t: _t, onTap: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
