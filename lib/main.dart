import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_resturant/core/router/app_router.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/theme/app_theme.dart';
import 'package:my_resturant/data/repositories/data_repository.dart';
import 'package:my_resturant/data/repositories/auth_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final acct = AccountCubit(repo: LocalAuthRepository());
  await acct.load();
  final role = RoleCubit();
  await role.load();
  runApp(MyApp(repo: AppRepository(), acct: acct, role: role));
}

class MyApp extends StatelessWidget {
  final AppRepository repo;
  final AccountCubit acct;
  final RoleCubit role;
  const MyApp({super.key, required this.repo, required this.acct, required this.role});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OrderCubit(repo: repo)),
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => acct),
        BlocProvider(create: (_) => role),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    return MaterialApp.router(
      title: 'Restaurant App',
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      supportedLocales: const [Locale('ku'), Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('ku');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return locale;
        }
        return const Locale('en');
      },
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: appRouter,
    );
  }
}
