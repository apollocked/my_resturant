import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/presentation/widgets/shared/app_image.dart';
import 'package:my_resturant/presentation/widgets/admin/image_picker_button.dart';

class DishFormFields extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, priceCtrl, descCtrl;
  final ValueNotifier<String> imageUrl;
  final String initialCategory;
  final String Function(String) t;
  final bool isEditing;
  final VoidCallback onPickImage;
  final ValueChanged<String> onCategoryChanged;
  final List<Map<String, String>> categories;

  const DishFormFields({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.descCtrl,
    required this.imageUrl,
    required this.initialCategory,
    required this.onCategoryChanged,
    required this.t,
    required this.isEditing,
    required this.onPickImage,
    required this.categories,
  });

  @override
  State<DishFormFields> createState() => _DishFormFieldsState();
}

class _DishFormFieldsState extends State<DishFormFields> {
  late String _cat;

  @override
  void initState() {
    super.initState();
    _cat = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final catKeys = widget.categories.where((c) => c['key'] != 'all').toList();
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          ValueListenableBuilder<String>(
            valueListenable: widget.imageUrl,
            builder: (_, url, _) => url.isEmpty
                ? const SizedBox(height: 130)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppImage(url, width: double.infinity, height: 130),
                  ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.nameCtrl,
            decoration: InputDecoration(
              labelText: widget.t('dish_name'),
              filled: true,
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? widget.t('dish_name_required')
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.priceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: widget.t('price_dinar'),
              filled: true,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return widget.t('price_required');
              final n = int.tryParse(v);
              return (n == null || n <= 0) ? widget.t('price_invalid') : null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.descCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: widget.t('description'),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          ImagePickerButton(
            label: widget.t('pick_image'),
            onPressed: widget.onPickImage,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _cat,
            decoration: InputDecoration(
              labelText: widget.t('section_field'),
              filled: true,
            ),
            items: catKeys
                .map(
                  (c) => DropdownMenuItem(
                    value: c['key'],
                    child: Text('${c['icon']} ${c['name']}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _cat = v);
                widget.onCategoryChanged(v);
              }
            },
          ),
        ],
      ),
    );
  }
}
