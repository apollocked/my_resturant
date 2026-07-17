import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/pages/auth/account_auth_page.dart';
import 'package:my_resturant/presentation/pages/auth/role_login_page.dart';
import 'package:my_resturant/presentation/pages/menu/cart_page.dart';
import 'package:my_resturant/presentation/pages/menu/menu_page.dart';
import 'package:my_resturant/presentation/pages/orders/kitchen_page.dart';
import 'package:my_resturant/presentation/pages/admin/profile_page.dart';
import 'package:my_resturant/presentation/pages/orders/order_detail_page.dart';
import 'package:my_resturant/presentation/pages/admin/table_management_page.dart';
import 'package:my_resturant/presentation/pages/admin/food_management_page.dart';
import 'package:my_resturant/presentation/pages/admin/availability_page.dart';
import 'package:my_resturant/presentation/pages/orders/order_history_page.dart';
import 'package:my_resturant/presentation/pages/admin/report_page.dart';
import 'package:my_resturant/presentation/pages/admin/dish_form_page.dart';
import 'package:my_resturant/presentation/pages/admin/category_form_page.dart';
import 'package:my_resturant/presentation/pages/admin/change_passcodes_page.dart';
import 'package:my_resturant/presentation/pages/setup/setup_page.dart';
import 'package:my_resturant/presentation/pages/layout/layout_page.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

final GlobalKey<NavigatorState> _rootNavigator = GlobalKey<NavigatorState>();

final List<String> adminRoutes = ['/table-management', '/food-management', '/availability', '/report', '/dish-form', '/category-form'];

final appRouter = GoRouter(
  navigatorKey: _rootNavigator,
  initialLocation: '/menu',
  redirect: (context, state) {
    final acct = context.read<AccountCubit>().state;
    final rs = context.read<RoleCubit>().state;
    final loc = state.matchedLocation;

    if (!acct.isLoggedIn) {
      if (loc != '/account-auth') return '/account-auth';
      return null;
    }

    if (!rs.isConfigured) {
      if (loc != '/setup') return '/setup';
      return null;
    }

    if (!rs.isLoggedIn) {
      if (loc != '/role-login') return '/role-login';
      return null;
    }

    if (loc == '/role-login') return '/menu';

    if (rs.role == Role.kitchen && (loc == '/cart' || loc == '/menu')) return '/kitchen';
    if (adminRoutes.any((r) => loc.startsWith(r)) && rs.role != Role.admin) return '/menu';

    return null;
  },
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/menu'),
    GoRoute(path: '/account-auth', builder: (_, _) => const AccountAuthPage()),
    GoRoute(path: '/role-login', builder: (_, _) => const RoleLoginPage()),
    GoRoute(path: '/setup', builder: (_, _) => const SetupPage()),
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
      builder: (_, _) => const TableManagementPage()),
    GoRoute(path: '/food-management', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const FoodManagementPage()),
    GoRoute(path: '/availability', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const AvailabilityPage()),
    GoRoute(path: '/report', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const ReportPage()),
    GoRoute(path: '/dish-form', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const DishFormPage()),
    GoRoute(path: '/category-form', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const CategoryFormPage()),
    GoRoute(path: '/change-passcodes', parentNavigatorKey: _rootNavigator,
      builder: (_, _) => const ChangePasscodesPage()),
  ],
);
