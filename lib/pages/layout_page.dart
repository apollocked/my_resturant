import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/cubits/settings_cubit.dart';
import 'package:my_resturant/l10n/tr.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final selectedIndex = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Container(height: 64, padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _navItem(Icons.shopping_bag_outlined, Icons.shopping_bag, t('cart'), 0, state.cartCount, selectedIndex),
              _navItem(Icons.menu_book_outlined, Icons.menu_book, t('menu'), 1, 0, selectedIndex),
              _navItem(Icons.receipt_long_outlined, Icons.receipt_long, t('kitchen'), 2, 0, selectedIndex),
              _navItem(Icons.person_outline, Icons.person, t('profile'), 3, 0, selectedIndex),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData outline, IconData filled, String label, int index, int badge, int selectedIndex) {
    final sel = selectedIndex == index;
    return GestureDetector(
      onTap: () => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: sel ? AppTheme.primarySoft : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, children: [
            Icon(sel ? filled : outline, size: 22, color: sel ? AppTheme.primary : AppTheme.textSecondary),
            if (badge > 0 && index == 0)
              Positioned(top: -4, right: -6, child: Container(width: 16, height: 16, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
          ]),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: sel ? AppTheme.primary : AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}
