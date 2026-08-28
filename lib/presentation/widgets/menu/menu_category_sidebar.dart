import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/admin/category_chip.dart';

class MenuCategorySidebar extends StatelessWidget {
  const MenuCategorySidebar({
    super.key,
    required this.cs,
    required this.t,
    required this.cats,
    required this.selectedIndex,
    required this.onCategoryChanged,
  });

  final ColorScheme cs;
  final String Function(String) t;
  final List<Map<String, String>> cats;
  final int selectedIndex;
  final ValueChanged<int> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);
    return Container(
      width: isTablet ? 150 : 180,
      padding: EdgeInsetsDirectional.fromSTEB(R.padding(context), 24, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            t('categories'),
            style: TextStyle(
              fontSize: R.fontMd(context),
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: cats.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CategoryChip(
                  icon: cats[index]['icon']!,
                  name: t('cat_${cats[index]['key']!}'),
                  isSelected: selectedIndex == index,
                  index: index,
                  onTap: () => onCategoryChanged(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
