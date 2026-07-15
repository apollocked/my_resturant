import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/role.dart';

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

    final items = role == Role.kitchen
        ? [
            const _Nav(
              Icons.receipt_long_outlined,
              Icons.receipt_long,
              'kitchen',
              2,
            ),
            const _Nav(Icons.history_outlined, Icons.history, 'history', 3),
            const _Nav(Icons.person_outline, Icons.person, 'profile', 4),
          ]
        : role == Role.admin
        ? [
            const _Nav(
              Icons.shopping_bag_outlined,
              Icons.shopping_bag,
              'cart',
              0,
            ),
            const _Nav(Icons.menu_book_outlined, Icons.menu_book, 'menu', 1),
            const _Nav(
              Icons.receipt_long_outlined,
              Icons.receipt_long,
              'kitchen',
              2,
            ),
            const _Nav(Icons.history_outlined, Icons.history, 'history', 3),
            const _Nav(Icons.person_outline, Icons.person, 'profile', 4),
          ]
        : [
            const _Nav(
              Icons.shopping_bag_outlined,
              Icons.shopping_bag,
              'cart',
              0,
            ),
            const _Nav(Icons.menu_book_outlined, Icons.menu_book, 'menu', 1),
            const _Nav(
              Icons.receipt_long_outlined,
              Icons.receipt_long,
              'kitchen',
              2,
            ),
            const _Nav(Icons.person_outline, Icons.person, 'profile', 4),
          ];

    return Scaffold(
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
    );
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
