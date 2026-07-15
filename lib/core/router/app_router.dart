import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/domain/entities/role.dart';
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
import 'package:my_resturant/presentation/widgets/shared/admin_gate.dart';

final GlobalKey<NavigatorState> _rootNavigator = GlobalKey<NavigatorState>();

final List<String> adminRoutes = ['/table-management', '/food-management', '/availability', '/report', '/dish-form', '/category-form'];

final appRouter = GoRouter(
  navigatorKey: _rootNavigator,
  initialLocation: '/menu',
  redirect: (context, state) {
    final roleCubit = context.read<RoleCubit>();
    final role = roleCubit.state.role;
    final loc = state.matchedLocation;
    if (role == Role.kitchen && (loc == '/cart' || loc == '/menu')) return '/kitchen';
    if (role == Role.waiter && loc == '/kitchen') return '/menu';
    if (adminRoutes.any((r) => loc.startsWith(r)) && role != Role.admin) return '/menu';
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/cart', builder: (_, _) => const CartPage())]),
        StatefulShellBranch(routes: [GoRoute(path: '/menu', builder: (_, _) => const RestaurantMenuScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/kitchen', builder: (_, _) => const KitchenPage())]),
        StatefulShellBranch(routes: [GoRoute(path: '/history', builder: (_, _) => const OrderHistoryPage())]),
        StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfilePage())]),
      ],
    ),
    GoRoute(path: '/order-detail', parentNavigatorKey: _rootNavigator,
      builder: (_, state) => OrderDetailPage(order: state.extra as Order)),
    GoRoute(path: '/table-management', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => AdminGate(builder: (_) => const TableManagementPage())),
    GoRoute(path: '/food-management', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => AdminGate(builder: (_) => const FoodManagementPage())),
    GoRoute(path: '/availability', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => AdminGate(builder: (_) => const AvailabilityPage())),
    GoRoute(path: '/order-history', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => AdminGate(builder: (_) => const OrderHistoryPage())),
    GoRoute(path: '/report', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => AdminGate(builder: (_) => const ReportPage())),
    GoRoute(path: '/dish-form', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => AdminGate(builder: (_) => const DishFormPage())),
    GoRoute(path: '/category-form', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => AdminGate(builder: (_) => const CategoryFormPage())),
  ],
);
