import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/data/models/default_categories.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/dish_field.dart';
import 'package:my_resturant/presentation/widgets/admin/dish_preview_image.dart';
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
    final cats = effectiveCategories(widget.categories);
    final match = cats.any((c) => c['key'] == widget.initialCategory);
    _cat = match
        ? widget.initialCategory
        : (cats.isNotEmpty ? cats.first['key']! : 'burger');
  }

  Future<void> _addCategory() async {
    final created = await context.push<Map<String, String>>('/category-form');
    if (!mounted || created == null) return;
    setState(() {
      _cat = created['key']!;
      widget.onCategoryChanged(created['key']!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cats = effectiveCategories(
      context.watch<OrderCubit>().state.categories,
    );
    final isDesktop = R.isDesktop(context);
    final nameField = DishField(
      label: widget.t('dish_name'),
      controller: widget.nameCtrl,
      maxLength: 80,
      validator: (v) =>
          v == null || v.trim().isEmpty ? widget.t('dish_name_required') : null,
    );
    final priceField = DishField(
      label: widget.t('price_dinar'),
      controller: widget.priceCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) {
        if (v == null || v.isEmpty) return widget.t('price_required');
        final n = int.tryParse(v);
        return (n == null || n <= 0) ? widget.t('price_invalid') : null;
      },
    );
    final descField = DishField(
      label: widget.t('description'),
      controller: widget.descCtrl,
      maxLines: 2,
      maxLength: 1000,
    );
    final imageButton = ImagePickerButton(
      label: widget.t('pick_image'),
      onPressed: widget.onPickImage,
    );
    final categoryField = DropdownButtonFormField<String>(
      initialValue: _cat,
      decoration: InputDecoration(
        labelText: widget.t('section_field'),
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
        if (v != null) {
          setState(() => _cat = v);
          widget.onCategoryChanged(v);
        }
      },
    );
    final categoryRow = Row(
      children: [
        Expanded(child: categoryField),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: _addCategory,
          icon: const Icon(Icons.add),
          tooltip: widget.t('add_category'),
        ),
      ],
    );
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          DishPreviewImage(url: widget.imageUrl),
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
