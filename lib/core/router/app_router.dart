import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/router/app_routes.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/features/auth/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';

final GlobalKey<NavigatorState> _rootNavigator = GlobalKey<NavigatorState>();

/// Bumped whenever Account/Role/Settings state changes so the router
/// re-evaluates its [redirect] callback (go_router has no other way to
/// react to non-navigation state changes).
final ValueNotifier<int> routeRefresh = ValueNotifier<int>(0);

final List<String> adminRoutes = [
  '/table-management',
  '/food-management',
  '/availability',
  '/report',
  '/dish-form',
  '/category-form',
  '/category-management',
  '/change-passcodes',
];

bool _roleAllowed(Role role, String loc) {
  switch (role) {
    case Role.admin:
      return true;
    case Role.kitchen:
      return loc == '/kitchen' ||
          loc == '/profile' ||
          loc == '/info' ||
          loc == '/printer-settings' ||
          loc == '/printer-discover' ||
          loc.startsWith('/order-detail');
    case Role.waiter:
      return loc == '/menu' ||
          loc == '/cart' ||
          loc == '/kitchen' ||
          loc == '/profile' ||
          loc == '/info' ||
          loc == '/printer-settings' ||
          loc == '/printer-discover' ||
          loc.startsWith('/order-detail');
  }
}

String homeForRole(Role role) {
  switch (role) {
    case Role.admin:
      return '/menu';
    case Role.kitchen:
      return '/kitchen';
    case Role.waiter:
      return '/menu';
  }
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigator,
  initialLocation: '/menu',
  refreshListenable: routeRefresh,
  redirect: (context, state) {
    final acct = context.read<AccountCubit>().state;
    final rs = context.read<RoleCubit>().state;
    final settings = context.read<SettingsCubit>().state;
    final loc = state.matchedLocation;

    String? result;
    if (!settings.onboardingComplete) {
      result = loc != '/onboarding' ? '/onboarding' : null;
    } else if (!acct.isLoggedIn) {
      result = loc != '/account-auth' ? '/account-auth' : null;
    } else if (!acct.isActivated) {
      result = loc != '/promo-code' ? '/promo-code' : null;
    } else if (!rs.isConfigured) {
      result = loc != '/setup' ? '/setup' : null;
    } else if (!rs.isLoggedIn) {
      result = loc != '/role-login' ? '/role-login' : null;
    } else if (loc == '/role-login') {
      result = homeForRole(rs.role);
    } else if (loc == '/setup' ||
        loc == '/promo-code' ||
        loc == '/account-auth' ||
        loc == '/onboarding') {
      // Fully configured and logged into a role: never stay on an auth/setup
      // page, send the user to their role home instead.
      result = homeForRole(rs.role);
    } else if (adminRoutes.any((r) => loc.startsWith(r)) &&
        rs.role != Role.admin) {
      result = homeForRole(rs.role);
    } else if (!_roleAllowed(rs.role, loc)) {
      result = homeForRole(rs.role);
    } else if (loc == '/order-detail' && state.extra is! Order) {
      result = '/menu';
    }
    debugPrint(
      '[NAV] redirect: loc=$loc role=${rs.role} '
      'onboarding=${settings.onboardingComplete} loggedIn=${acct.isLoggedIn} '
      'activated=${acct.isActivated} configured=${rs.isConfigured} '
      'roleLoggedIn=${rs.isLoggedIn} cartExtra=${state.extra is Order} '
      '=> ${result ?? 'no-redirect'}',
    );
    return result;
  },
  routes: buildAppRoutes(_rootNavigator),
);