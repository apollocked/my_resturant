import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

const List<String> categoryIcons = [
  '🍽',
  '🍔',
  '🍕',
  '🌯',
  '🍗',
  '🥗',
  '🥪',
  '🌮',
  '🥟',
  '🍜',
  '🍝',
  '🍛',
  '🥘',
  '🫕',
  '🥙',
  '🧆',
  '🥩',
  '🍖',
  '🥦',
  '🥕',
  '🧅',
  '🫑',
  '🥐',
  '🥯',
  '🍞',
  '🥨',
  '🧀',
  '🥚',
  '🍳',
  '🥮',
  '🍦',
  '🍰',
  '🥤',
  '🧋',
  '☕',
  '🍵',
  '🫖',
  '🥛',
  '🧃',
  '🍹',
  '🍸',
  '🍺',
  '🍻',
  '🍷',
  '🥂',
  '🍾',
];

class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: R.categoryIconColumns(context),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categoryIcons.length,
      itemBuilder: (context, index) {
        final icon = categoryIcons[index];
        final sel = icon == selected;
        return PressableScale(
          onTap: () => onSelect(icon),
          child: Container(
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: sel
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(icon, style: TextStyle(fontSize: sel ? 30 : 22)),
            ),
          ),
        );
      },
    );
  }
}
