import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/data/models/categories.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class CategoryFilterBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CategoryFilterBar({super.key, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsCubit>();
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final height = isDesktop ? 48.0 : isTablet ? 42.0 : 36.0;
    final paddingH = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;
    final paddingV = isDesktop ? 10.0 : isTablet ? 8.0 : 6.0;
    final iconSize = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;
    final textSize = isDesktop ? 15.0 : isTablet ? 14.0 : 13.0;
    String t(String key) => Tr.get(key, settings.state.locale);
    return SizedBox(height: height,
      child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final isSel = selectedIndex == i;
          final catKey = categories[i]['key']!;
          final label = t('cat_$catKey');
          return Padding(padding: EdgeInsets.only(left: isDesktop ? 12 : 8), child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(isDesktop ? 26 : 20),
                boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8)] : null,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(categories[i]['icon']!, style: TextStyle(fontSize: iconSize)),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(
                    fontSize: textSize, fontWeight: FontWeight.w600, color: isSel ? cs.onPrimary : cs.onSurface)),
              ]),
            ),
          ));
        },
      ),
    );
  }
}
