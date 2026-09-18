import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/l10n/ku_localizations.dart';
import 'package:my_resturant/core/router/app_router.dart';
import 'package:my_resturant/core/theme/app_theme.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_state.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_state.dart';
import 'package:my_resturant/features/orders/presentation/widgets/auto_print_listener.dart';
import 'package:my_resturant/features/permissions/presentation/permission_gate.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});
  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  RoleState? _lastRole;
  Locale? _lastLocale;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final role = context.watch<RoleCubit>().state;
    final orderCubit = context.read<OrderCubit>();
    if (role.isLoggedIn != _lastRole?.isLoggedIn ||
        role.role != _lastRole?.role) {
      _lastRole = role;
      orderCubit.setCurrentRole(role.isLoggedIn ? role.role : null);
    }
    if (_lastLocale != settings.locale) {
      _lastLocale = settings.locale;
      orderCubit.setCurrentLocale(settings.locale);
    }
    String t(String key) => Tr.get(key, settings.locale);
    return MaterialApp.router(
      title: t('app_name'),
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      supportedLocales: const [Locale('ku'), Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        KuMaterialLocalizationsDelegate(),
        KuCupertinoLocalizationsDelegate(),
        KuWidgetsLocalizationsDelegate(),
        ...GlobalMaterialLocalizations.delegates,
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('en');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('en');
      },
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return BlocListener<OrderCubit, OrderState>(
          listenWhen: (p, c) =>
              p.errorMessage != c.errorMessage && c.errorMessage != null,
          listener: (context, state) {
            final msg = Tr.get(state.errorMessage!, settings.locale);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
            context.read<OrderCubit>().clearError();
          },
          child: PermissionGate(
            child: AutoPrintListener(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}