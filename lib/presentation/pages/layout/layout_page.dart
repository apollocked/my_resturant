import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/widgets/shared/connectivity_banner.dart';

class _Nav {
  final IconData outline, filled;
  final String labelKey;
  final int index;
  const _Nav(this.outline, this.filled, this.labelKey, this.index);
}

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    final role = context.watch<RoleCubit>().state.role;
    String t(String key) => Tr.get(key, settings.locale);
    final selectedIndex = navigationShell.currentIndex;
    final isDesktop = R.isDesktop(context);
    final isTablet = R.isTablet(context);

    final items = _buildNavItems(role);

    if (isDesktop && R.height(context) >= 500) {
      return SafeArea(
        child: ConnectivityBanner(
          child: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
              labelType: NavigationRailLabelType.all,
              backgroundColor: cs.surface,
              indicatorColor: AppColors.primarySoft,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/icons/my Restaurant.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('app_name'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              minWidth: 100,
              groupAlignment: 0,
              destinations: items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: item.index == 0 && state.cartCount > 0
                          ? Badge(
                              label: Text(
                                '${state.cartCount}',
                                style: const TextStyle(fontSize: 9),
                              ),
                              child: Icon(item.outline, size: 24),
                            )
                          : Icon(item.outline, size: 24),
                      selectedIcon: item.index == 0 && state.cartCount > 0
                          ? Badge(
                              label: Text(
                                '${state.cartCount}',
                                style: const TextStyle(fontSize: 9),
                              ),
                              child: Icon(item.filled, size: 24),
                            )
                          : Icon(item.filled, size: 24),
                      label: Text(
                        t(item.labelKey),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
        ),
      ),
      );
    }

    if (isTablet && R.height(context) >= 500) {
      return SafeArea(
        child: ConnectivityBanner(
          child: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
              labelType: NavigationRailLabelType.all,
              backgroundColor: cs.surface,
              indicatorColor: AppColors.primarySoft,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/my Restaurant.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              destinations: items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: item.index == 0 && state.cartCount > 0
                          ? Badge(
                              label: Text(
                                '${state.cartCount}',
                                style: const TextStyle(fontSize: 9),
                              ),
                              child: Icon(item.outline),
                            )
                          : Icon(item.outline),
                      selectedIcon: item.index == 0 && state.cartCount > 0
                          ? Badge(
                              label: Text(
                                '${state.cartCount}',
                                style: const TextStyle(fontSize: 9),
                              ),
                              child: Icon(item.filled),
                            )
                          : Icon(item.filled),
                      label: Text(t(item.labelKey)),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
        ),
      ),
      );
    }

    return SafeArea(
      child: ConnectivityBanner(
        child: Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items
                  .map(
                    (item) => _navItem(
                      context,
                      item.outline,
                      item.filled,
                      t(item.labelKey),
                      item.index,
                      item.index == 0 ? state.cartCount : 0,
                      selectedIndex,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }

  List<_Nav> _buildNavItems(Role role) {
    if (role == Role.kitchen) {
      return [
        const _Nav(
          Icons.receipt_long_outlined,
          Icons.receipt_long,
          'kitchen',
          2,
        ),
        const _Nav(Icons.history_outlined, Icons.history, 'history', 3),
        const _Nav(Icons.person_outline, Icons.person, 'profile', 4),
      ];
    }
    if (role == Role.admin) {
      return [
        const _Nav(Icons.shopping_bag_outlined, Icons.shopping_bag, 'cart', 0),
        const _Nav(Icons.menu_book_outlined, Icons.menu_book, 'menu', 1),
        const _Nav(
          Icons.receipt_long_outlined,
          Icons.receipt_long,
          'kitchen',
          2,
        ),
        const _Nav(Icons.history_outlined, Icons.history, 'history', 3),
        const _Nav(Icons.person_outline, Icons.person, 'profile', 4),
      ];
    }
    return [
      const _Nav(Icons.shopping_bag_outlined, Icons.shopping_bag, 'cart', 0),
      const _Nav(Icons.menu_book_outlined, Icons.menu_book, 'menu', 1),
      const _Nav(Icons.receipt_long_outlined, Icons.receipt_long, 'kitchen', 2),
      const _Nav(Icons.person_outline, Icons.person, 'profile', 4),
    ];
  }

  Widget _navItem(
    BuildContext context,
    IconData outline,
    IconData filled,
    String label,
    int index,
    int badge,
    int selectedIndex,
  ) {
    final cs = Theme.of(context).colorScheme;
    final sel = selectedIndex == index;
    return GestureDetector(
      onTap: () => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  sel ? filled : outline,
                  size: 22,
                  color: sel ? AppColors.primary : cs.onSurfaceVariant,
                ),
                if (badge > 0 && index == 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 1.5),
                      ),
                      child: Text(
                        '$badge',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: sel ? AppColors.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
