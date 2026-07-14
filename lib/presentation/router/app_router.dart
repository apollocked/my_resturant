import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/presentation/pages/cart_page.dart';
import 'package:my_resturant/presentation/pages/menu_page.dart';
import 'package:my_resturant/presentation/pages/kitchen_page.dart';
import 'package:my_resturant/presentation/pages/profile_page.dart';
import 'package:my_resturant/presentation/pages/order_detail_page.dart';
import 'package:my_resturant/presentation/pages/table_management_page.dart';
import 'package:my_resturant/presentation/pages/food_management_page.dart';
import 'package:my_resturant/presentation/pages/availability_page.dart';
import 'package:my_resturant/presentation/pages/order_history_page.dart';
import 'package:my_resturant/presentation/pages/report_page.dart';
import 'package:my_resturant/presentation/pages/dish_form_page.dart';
import 'package:my_resturant/presentation/pages/category_form_page.dart';
import 'package:my_resturant/presentation/pages/layout_page.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

final GlobalKey<NavigatorState> _rootNavigator = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigator,
  initialLocation: '/menu',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/cart', builder: (_, _) => const CartPage())]),
        StatefulShellBranch(routes: [GoRoute(path: '/menu', builder: (_, _) => const RestaurantMenuScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/kitchen', builder: (_, _) => const KitchenPage())]),
        StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfilePage())]),
      ],
    ),
    GoRoute(path: '/order-detail', parentNavigatorKey: _rootNavigator,
      builder: (_, state) => OrderDetailPage(order: state.extra as Order)),
    GoRoute(path: '/table-management', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const TableManagementPage()),
    GoRoute(path: '/food-management', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const FoodManagementPage()),
    GoRoute(path: '/availability', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const AvailabilityPage()),
    GoRoute(path: '/order-history', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const OrderHistoryPage()),
    GoRoute(path: '/report', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const ReportPage()),
    GoRoute(path: '/dish-form', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const DishFormPage()),
    GoRoute(path: '/category-form', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const CategoryFormPage()),
  ],
);
