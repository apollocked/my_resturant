import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/pages/account_login_page.dart';
import 'package:my_resturant/presentation/pages/create_account_page.dart';
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
import 'package:my_resturant/presentation/pages/change_passcodes_page.dart';
import 'package:my_resturant/presentation/pages/setup_page.dart';
import 'package:my_resturant/presentation/pages/layout_page.dart';
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

    // 1. Account not created → force create-account
    if (!acct.isAccountCreated && loc != '/create-account') return '/create-account';

    // 2. On create-account: if account exists but not logged in → login
    if (loc == '/create-account') {
      if (acct.isAccountCreated && !acct.isLoggedIn) return '/account-login';
      return null;
    }

    // 3. Not logged in → force account-login
    if (!acct.isLoggedIn && loc != '/account-login') return '/account-login';

    // 4. Logged in on login page → go to app
    if (loc == '/account-login' && acct.isLoggedIn) return '/menu';

    // 5. Role passcodes not set → force setup
    if (!rs.isConfigured && loc != '/setup') return '/setup';
    if (loc == '/setup' && rs.isConfigured) return '/menu';

    // 6. Role-based page gating
    if (rs.role == Role.kitchen && (loc == '/cart' || loc == '/menu')) return '/kitchen';
    if (rs.role == Role.waiter && loc == '/kitchen') return '/menu';
    if (adminRoutes.any((r) => loc.startsWith(r)) && rs.role != Role.admin) return '/menu';

    return null;
  },
  routes: [
    GoRoute(path: '/create-account', builder: (_, _) => const CreateAccountPage()),
    GoRoute(path: '/account-login', builder: (_, _) => const AccountLoginPage()),
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
