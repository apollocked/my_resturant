import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/views/pages/menu_page.dart';
import 'package:my_resturant/views/pages/orders_page.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _buildOrdersIcon(int count, bool active) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Icon(
            active ? Icons.article : Icons.article_outlined,
            size: 26,
          ),
        ),
        if (count > 0)
          Positioned(
            top: -2,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF2EC153),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const OrdersPage(),
          RestaurantMenuScreen(onNavigateToOrders: () => _onItemTapped(0)),
          const Center(child: Text('پڕۆفایل', style: TextStyle(fontSize: 24))),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedItemColor: const Color(0xFF2EC153),
              unselectedItemColor: const Color(0xFF8C8C8C),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _buildOrdersIcon(
                    context.watch<OrderViewModel>().orderCount,
                    false,
                  ),
                  activeIcon: _buildOrdersIcon(
                    context.watch<OrderViewModel>().orderCount,
                    true,
                  ),
                  label: 'داواکارییەکان',
                ),
                const BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.ramen_dining_outlined, size: 26),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.ramen_dining, size: 26),
                  ),
                  label: 'مینیو',
                ),
                const BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.person_outline, size: 26),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.person, size: 26),
                  ),
                  label: 'پڕۆفایل',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
