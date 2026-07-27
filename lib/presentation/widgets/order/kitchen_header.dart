import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class KitchenHeader extends StatelessWidget {
  final String title;
  final String countLabel;
  final int selectedIndex;
  final List<String> tabLabels;
  final ValueChanged<int> onTabChanged;
  const KitchenHeader({super.key, required this.title, required this.countLabel, required this.selectedIndex, required this.tabLabels, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(R.padding(context), 16, R.padding(context), 0),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: R.fontXl(context), fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(countLabel, style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            for (int i = 0; i < tabLabels.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              _TabPill(label: tabLabels[i], index: i, isSelected: selectedIndex == i, isDesktop: isDesktop, onTap: () => onTabChanged(i)),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected, isDesktop;
  final VoidCallback onTap;
  const _TabPill({required this.label, required this.index, required this.isSelected, required this.isDesktop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 14, vertical: isDesktop ? 10 : 7),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: TextStyle(fontSize: isDesktop ? 14 : 12, fontWeight: FontWeight.w700, color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }
}
