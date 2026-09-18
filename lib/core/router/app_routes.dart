import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/features/auth/presentation/pages/account_auth_page.dart';
import 'package:my_resturant/features/auth/presentation/pages/promo_code_page.dart';
import 'package:my_resturant/features/auth/presentation/pages/role_login_page.dart';
import 'package:my_resturant/features/cart/presentation/pages/cart_page.dart';
import 'package:my_resturant/features/menu/presentation/pages/menu_page.dart';
import 'package:my_resturant/features/orders/presentation/pages/kitchen_page.dart';
import 'package:my_resturant/features/profile/presentation/pages/profile_page.dart';
import 'package:my_resturant/features/orders/presentation/pages/order_detail_page.dart';
import 'package:my_resturant/features/admin/presentation/pages/table_management_page.dart';
import 'package:my_resturant/features/admin/presentation/pages/food_management_page.dart';
import 'package:my_resturant/features/admin/presentation/pages/availability_page.dart';
import 'package:my_resturant/features/orders/presentation/pages/order_history_page.dart';
import 'package:my_resturant/features/reports/presentation/pages/report_page.dart';
import 'package:my_resturant/features/admin/presentation/pages/dish_form_page.dart';
import 'package:my_resturant/features/admin/presentation/pages/category_form_page.dart';
import 'package:my_resturant/features/admin/presentation/pages/category_management_page.dart';
import 'package:my_resturant/features/admin/presentation/pages/change_passcodes_page.dart';
import 'package:my_resturant/features/printer/presentation/pages/printer_settings_page.dart';
import 'package:my_resturant/features/printer/presentation/pages/printer_discovery_page.dart';
import 'package:my_resturant/features/admin/presentation/pages/info_page.dart';
import 'package:my_resturant/features/setup/presentation/pages/setup_page.dart';
import 'package:my_resturant/features/shell/presentation/pages/layout_page.dart';
import 'package:my_resturant/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/menu/domain/entities/recipe.dart';

/// The root shell branches stay reachable independent of the redirect logic.
List<RouteBase> buildAppRoutes(GlobalKey<NavigatorState> rootNavigator) {
  return [
    GoRoute(
      path: '/',
      redirect: (_, _) => '/menu',
    ),
    GoRoute(path: '/account-auth', builder: (_, _) => const AccountAuthPage()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
    GoRoute(path: '/promo-code', builder: (_, _) => const PromoCodePage()),
    GoRoute(path: '/role-login', builder: (_, _) => const RoleLoginPage()),
    GoRoute(path: '/setup', builder: (_, _) => const SetupPage()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/cart', builder: (_, _) => const CartPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/menu', builder: (_, _) => const RestaurantMenuScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/kitchen', builder: (_, _) => const KitchenPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (_, _) => const OrderHistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/order-detail',
      parentNavigatorKey: rootNavigator,
      builder: (_, state) => OrderDetailPage(order: state.extra as Order),
    ),
    GoRoute(
      path: '/table-management',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const TableManagementPage(),
    ),
    GoRoute(
      path: '/food-management',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const FoodManagementPage(),
    ),
    GoRoute(
      path: '/availability',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const AvailabilityPage(),
    ),
    GoRoute(
      path: '/report',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const ReportPage(),
    ),
    GoRoute(
      path: '/dish-form',
      parentNavigatorKey: rootNavigator,
      builder: (_, state) => DishFormPage(recipe: state.extra as Recipe?),
    ),
    GoRoute(
      path: '/category-form',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const CategoryFormPage(),
    ),
    GoRoute(
      path: '/category-management',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const CategoryManagementPage(),
    ),
    GoRoute(
      path: '/change-passcodes',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const ChangePasscodesPage(),
    ),
    GoRoute(
      path: '/printer-settings',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const PrinterSettingsPage(),
    ),
    GoRoute(
      path: '/printer-discover',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const PrinterDiscoveryPage(),
    ),
    GoRoute(
      path: '/info',
      parentNavigatorKey: rootNavigator,
      builder: (_, _) => const InfoPage(),
    ),
  ];
}