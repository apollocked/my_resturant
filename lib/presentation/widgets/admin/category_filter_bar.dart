import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/data/models/categories.dart';

class CategoryFilterBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CategoryFilterBar({super.key, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(height: 36,
      child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final isSel = selectedIndex == i;
          return Padding(padding: const EdgeInsets.only(left: 8), child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : cs.outlineVariant,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8)] : null,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(categories[i]['icon']!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(categories[i]['name']!, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: isSel ? cs.onPrimary : cs.onSurfaceVariant)),
              ]),
            ),
          ));
        },
      ),
    );
  }
}
