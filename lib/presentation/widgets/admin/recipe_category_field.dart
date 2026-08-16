import 'package:flutter/material.dart';

class RecipeCategoryField extends StatelessWidget {
  const RecipeCategoryField({
    super.key,
    required this.label,
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<Map<String, String>> categories;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (ctx, setLocal) => DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: categories
            .map(
              (c) => DropdownMenuItem(
                value: c['key'],
                child: Text('${c['icon']} ${c['name']}'),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) {
            setLocal(() {});
            onChanged(v);
          }
        },
      ),
    );
  }
}
