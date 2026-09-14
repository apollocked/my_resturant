import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class CategoryManageCard extends StatelessWidget {
  const CategoryManageCard({
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
      child: Padding(
        padding: EdgeInsets.all(R.cardPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: R.fontXl(context))),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: R.fontMd(context),
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                keyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.fontSm(context),
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
