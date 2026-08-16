import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/pages/layout/exit_scope.dart';
import 'package:my_resturant/presentation/pages/layout/nav_item.dart';
import 'package:my_resturant/presentation/pages/layout/side_nav_rail.dart';
import 'package:my_resturant/shared/connectivity_banner.dart';
import 'package:my_resturant/shared/liquid_glass_nav_bar.dart';
import 'package:my_resturant/shared/liquid_nav_item.dart';
import 'package:my_resturant/shared/tab_entrance.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    final role = context.watch<RoleCubit>().state.role;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String t(String key) => Tr.get(key, settings.locale);
    final items = NavItem.forRole(role);
    var selectedIndex = items.indexWhere(
      (item) => item.index == navigationShell.currentIndex,
    );
    if (selectedIndex == -1) selectedIndex = 0;
    final isDesktop = R.isDesktop(context);
    final isTablet = R.isTablet(context);

    if (isDesktop && R.height(context) >= 500) {
      return _rail(
        context,
        t,
        items,
        selectedIndex,
        state.cartCount,
        showTitle: true,
        iconSize: 24,
        labelSize: 12,
      );
    }
    if (isTablet && R.height(context) >= 500) {
      return _rail(
        context,
        t,
        items,
        selectedIndex,
        state.cartCount,
        showTitle: false,
      );
    }
    return ExitScope(
      t: t,
      child: ConnectivityBanner(
        child: Scaffold(
          extendBody: true,
          body: SafeArea(
            top: true,
            bottom: false,
            child: TabEntrance(index: selectedIndex, child: navigationShell),
          ),
          bottomNavigationBar: LiquidGlassNavBar(
            items: items
                .map(
                  (item) => LiquidNavItem(
                    icon: item.outline,
                    activeIcon: item.filled,
                    label: t(item.labelKey),
                  ),
                )
                .toList(),
            selectedIndex: selectedIndex,
            onTap: (i) {
              debugPrint(
                '[NAV] goBranch branch=${items[i].index} tappedIndex=$i '
                'current=${navigationShell.currentIndex} item=${items[i].labelKey}',
              );
              HapticFeedback.selectionClick();
              navigationShell.goBranch(
                items[i].index,
                initialLocation: items[i].index == navigationShell.currentIndex,
              );
            },
            badgeCount: state.cartCount,
            badgeIndex: 0,
            accentColor: AppColors.primary,
            isDark: isDark,
          ),
        ),
      ),
    );
  }

  Widget _rail(
    BuildContext context,
    String Function(String) t,
    List<NavItem> items,
    int selectedIndex,
    int cartCount, {
    required bool showTitle,
    double? iconSize,
    double? labelSize,
  }) {
    return ExitScope(
      t: t,
      child: SafeArea(
        child: ConnectivityBanner(
          child: Scaffold(
            body: Row(
              children: [
                SideNavRail(
                  items: items,
                  selectedIndex: selectedIndex,
                  cartCount: cartCount,
                  t: t,
                  showTitle: showTitle,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: (i) {
                    final branch = items[i].index;
                    navigationShell.goBranch(
                      branch,
                      initialLocation: branch == navigationShell.currentIndex,
                    );
                  },
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TabEntrance(
                    index: selectedIndex,
                    child: navigationShell,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
