import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/layout/nav_destination.dart';
import 'package:my_resturant/presentation/widgets/layout/nav_item.dart';

class SideNavRail extends StatelessWidget {
  const SideNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.cartCount,
    required this.t,
    required this.onTap,
    required this.showTitle,
    this.iconSize,
    this.labelSize,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final int cartCount;
  final String Function(String) t;
  final ValueChanged<int> onTap;
  final bool showTitle;
  final double? iconSize;
  final double? labelSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) {
        HapticFeedback.selectionClick();
        onTap(i);
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: cs.surface,
      indicatorColor: AppColors.primarySoft,
      leading: showTitle ? _titleLeading(t('app_name')) : _logo(32),
      minWidth: showTitle ? 100 : null,
      groupAlignment: 0,
      destinations: items
          .map(
            (item) =>
                NavDestination(item: item, cartCount: cartCount).destination(
                  label: t(item.labelKey),
                  iconSize: iconSize,
                  labelSize: labelSize,
                ),
          )
          .toList(),
    );
  }

  Widget _titleLeading(String appName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _logo(36),
          const SizedBox(height: 4),
          Text(
            appName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Image.asset(
        'assets/images/appicon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
