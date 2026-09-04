import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/admin/category_manage_card.dart';
import 'package:my_resturant/presentation/widgets/admin/category_manage_tile.dart';
import 'package:my_resturant/shared/empty_state.dart';

class CategoryManageList extends StatelessWidget {
  const CategoryManageList({
    super.key,
    required this.categories,
    required this.t,
    required this.onDelete,
  });

  final List<Map<String, String>> categories;
  final String Function(String) t;
  final ValueChanged<Map<String, String>> onDelete;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        title: t('categories_empty'),
        subtitle: t('categories_empty_subtitle'),
      );
    }
    final cs = Theme.of(context).colorScheme;
    if (R.isPhone(context)) {
      return ListView.builder(
        padding: EdgeInsets.all(R.padding(context)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final c = categories[index];
          return CategoryManageTile(
            emoji: c['icon'] ?? '🍽',
            name: c['name'] ?? '',
            keyName: c['key'] ?? '',
            cs: cs,
            onDelete: () => onDelete(c),
          );
        },
      );
    }
    return GridView.builder(
      padding: EdgeInsets.all(R.padding(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: R.tableGridColumns(context),
        childAspectRatio: 0.7,
        crossAxisSpacing: R.gridSpacing(context),
        mainAxisSpacing: R.gridSpacing(context),
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final c = categories[index];
        return CategoryManageCard(
          emoji: c['icon'] ?? '🍽',
          name: c['name'] ?? '',
          keyName: c['key'] ?? '',
          cs: cs,
          onDelete: () => onDelete(c),
        );
      },
    );
  }
}
