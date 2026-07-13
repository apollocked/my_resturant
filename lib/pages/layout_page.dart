import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/pages/menu_page.dart';
import 'package:my_resturant/pages/cart_page.dart';
import 'package:my_resturant/pages/kitchen_page.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _navIcon(IconData icon) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(icon, size: 26));

  Widget _cartBadge(int count) {
    return Stack(clipBehavior: Clip.none, children: [
      Padding(padding: const EdgeInsets.only(bottom: 4), child: const Icon(Icons.shopping_cart_outlined, size: 26)),
      if (count > 0)
        Positioned(top: -2, right: -6, child: Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(color: Color(0xFF2EC153), shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
          child: Text('$count', textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: [
        CartPage(onViewKitchen: () => _onItemTapped(2)),
        RestaurantMenuScreen(onNavigateToCart: () => _onItemTapped(0)),
        const KitchenPage(),
        const Center(child: Text('پڕۆفایل', style: TextStyle(fontSize: 24))),
      ])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, -5)),
        ]),
        child: SafeArea(child: SizedBox(height: 70, child: BottomNavigationBar(
          backgroundColor: Colors.white, elevation: 0,
          currentIndex: _selectedIndex, onTap: _onItemTapped,
          showSelectedLabels: true, showUnselectedLabels: false,
          selectedItemColor: const Color(0xFF2EC153),
          unselectedItemColor: const Color(0xFF8C8C8C),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          items: [
            BottomNavigationBarItem(icon: _cartBadge(vm.cartCount), activeIcon: _cartBadge(vm.cartCount), label: 'داواکاری'),
            BottomNavigationBarItem(icon: _navIcon(Icons.ramen_dining_outlined), activeIcon: _navIcon(Icons.ramen_dining), label: 'مینیو'),
            BottomNavigationBarItem(icon: _navIcon(Icons.receipt_long_outlined), activeIcon: _navIcon(Icons.receipt_long), label: 'چێشتخانە'),
            BottomNavigationBarItem(icon: _navIcon(Icons.person_outline), activeIcon: _navIcon(Icons.person), label: 'پڕۆفایل'),
          ],
        ))),
      ),
    );
  }
}
