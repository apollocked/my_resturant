import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/features/admin/presentation/widgets/dish_field.dart';
import 'package:my_resturant/features/admin/presentation/widgets/dish_preview_image.dart';
import 'package:my_resturant/features/admin/presentation/widgets/image_picker_button.dart';

/// Pure view for the dish form: builds the fields + category row. All state
/// (controllers, category selection, image) is owned by the page.
class DishFormFieldsView {
  static Widget build({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameCtrl,
    required TextEditingController priceCtrl,
    required TextEditingController descCtrl,
    required ValueNotifier<String> imageUrl,
    required List<Map<String, String>> cats,
    required String cat,
    required String Function(String) t,
    required bool isDesktop,
    required bool isEditing,
    required VoidCallback onPickImage,
    required ValueChanged<String> onCategoryChanged,
    required VoidCallback onAddCategory,
  }) {
    final nameField = DishField(
      label: t('dish_name'),
      controller: nameCtrl,
      maxLength: 80,
      validator: (v) =>
          v == null || v.trim().isEmpty ? t('dish_name_required') : null,
    );
    final priceField = DishField(
      label: t('price_dinar'),
      controller: priceCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text)) return newValue;
          return oldValue;
        }),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return t('price_required');
        final n = double.tryParse(v);
        return (n == null || n <= 0) ? t('price_invalid') : null;
      },
    );
    final descField = DishField(
      label: t('description'),
      controller: descCtrl,
      maxLines: 2,
      maxLength: 1000,
    );
    final imageButton = ImagePickerButton(
      label: t('pick_image'),
      onPressed: onPickImage,
    );
    final categoryField = DropdownButtonFormField<String>(
      initialValue: cat,
      decoration: InputDecoration(
        labelText: t('section_field'),
        filled: true,
      ),
      items: cats
          .map(
            (c) => DropdownMenuItem(
              value: c['key'],
              child: Text('${c['icon']} ${c['name']}'),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onCategoryChanged(v);
      },
    );
    final categoryRow = Row(
      children: [
        Expanded(child: categoryField),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onAddCategory,
          icon: const Icon(Icons.add),
          tooltip: t('add_category'),
        ),
      ],
    );
    return Form(
      key: formKey,
      child: Column(
        children: [
          DishPreviewImage(url: imageUrl),
          const SizedBox(height: 16),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: nameField),
                const SizedBox(width: 12),
                Expanded(child: priceField),
              ],
            )
          else ...[
            nameField,
            const SizedBox(height: 12),
            priceField,
          ],
          const SizedBox(height: 12),
          descField,
          const SizedBox(height: 12),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: categoryRow),
                const SizedBox(width: 12),
                Expanded(child: imageButton),
              ],
            )
          else ...[
            imageButton,
            const SizedBox(height: 12),
            categoryRow,
          ],
        ],
      ),
    );
  }
}