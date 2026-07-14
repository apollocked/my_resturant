import 'package:flutter/material.dart';
import 'package:my_resturant/main.dart';

class CategoryChip extends StatelessWidget {
  final String icon, name;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.icon, required this.name, required this.isSelected,
    required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: index > 0 ? 8 : 0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? null : Border.all(color: const Color(0xFFE8E4E0)),
            boxShadow: isSelected
                ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(name, style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
