import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/features/menu/domain/default_categories.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/admin/presentation/widgets/dish_form_fields_view.dart';

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
    return DishFormFieldsView.build(
      context: context,
      formKey: widget.formKey,
      nameCtrl: widget.nameCtrl,
      priceCtrl: widget.priceCtrl,
      descCtrl: widget.descCtrl,
      imageUrl: widget.imageUrl,
      cats: cats,
      cat: _cat,
      t: widget.t,
      isDesktop: R.isDesktop(context),
      isEditing: widget.isEditing,
      onPickImage: widget.onPickImage,
      onCategoryChanged: (v) {
        setState(() => _cat = v);
        widget.onCategoryChanged(v);
      },
      onAddCategory: _addCategory,
    );
  }
}