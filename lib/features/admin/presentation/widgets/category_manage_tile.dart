import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class CategoryManageTile extends StatelessWidget {
  const CategoryManageTile({
    super.key,
    required this.emoji,
    required this.name,
    required this.keyName,
    required this.cs,
    required this.onDelete,
  });

  final String emoji;
  final String name;
  final String keyName;
  final ColorScheme cs;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(emoji, style: TextStyle(fontSize: R.fontXl(context))),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: R.fontMd(context),
            color: cs.onSurface,
          ),
        ),
        subtitle: Text(
          keyName,
          style: TextStyle(
            fontSize: R.fontSm(context),
            color: cs.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: AppColors.error,
            size: 20,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
