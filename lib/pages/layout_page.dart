import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/pages/menu_page.dart';
import 'package:my_resturant/pages/cart_page.dart';
import 'package:my_resturant/pages/kitchen_page.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  late final _pageCtrl = PageController(initialPage: 1);

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageCtrl.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    return Scaffold(
      body: PageView(
        controller: _pageCtrl, physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _selectedIndex = i),
        children: [
          CartPage(onViewKitchen: () => _onItemTapped(2)),
          RestaurantMenuScreen(onNavigateToCart: () => _onItemTapped(0)),
          const KitchenPage(),
          const _ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, -5))]),
        child: SafeArea(child: Container(
          height: 64, padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _navItem(Icons.shopping_bag_outlined, Icons.shopping_bag, 'داواکاری', 0, vm.cartCount),
            _navItem(Icons.menu_book_outlined, Icons.menu_book, 'مینیو', 1, 0),
            _navItem(Icons.receipt_long_outlined, Icons.receipt_long, 'چێشتخانە', 2, 0),
            _navItem(Icons.person_outline, Icons.person, 'پڕۆفایل', 3, 0),
          ]),
        )),
      ),
    );
  }

  Widget _navItem(IconData outline, IconData filled, String label, int index, int badge) {
    final sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, children: [
            Icon(sel ? filled : outline, size: 22, color: sel ? AppTheme.primary : AppTheme.textSecondary),
            if (badge > 0 && index == 0)
              Positioned(top: -4, right: -6, child: Container(
                width: 16, height: 16, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5)),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
          ]),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: sel ? AppTheme.primary : AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const SizedBox(height: 30),
        Center(child: Container(width: 90, height: 90, decoration: BoxDecoration(
          color: AppTheme.primarySoft, shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primary, width: 2)),
          child: const Icon(Icons.person, size: 44, color: AppTheme.primary))),
        const SizedBox(height: 16),
        const Center(child: Text('بەڕێوەبەر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))),
        const Center(child: Text('ڕێستۆرانتەکەم', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
        const Spacer(),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error,
            side: const BorderSide(color: AppTheme.error),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.logout, size: 18), SizedBox(width: 8),
            Text('چوونەدەرەوە'),
          ]))),
        const SizedBox(height: 20),
      ]),
    ));
  }
}
