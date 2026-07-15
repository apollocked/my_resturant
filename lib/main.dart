import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:my_resturant/core/config/supabase_credentials.dart';
import 'package:my_resturant/core/router/app_router.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/theme/app_theme.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';
// Swap imports below to switch between mock (local) and real (Supabase) repos
import 'package:my_resturant/data/repositories/data_repository.dart';
import 'package:my_resturant/data/repositories/auth_repository_impl.dart';
// import 'package:my_resturant/data/repositories/supabase_data_repo.dart';
// import 'package:my_resturant/data/repositories/supabase_auth_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseCredentials.url,
    publishableKey: SupabaseCredentials.publishableKey,
  );

  // Swap constructors below when using Supabase repos
  final authRepo = LocalAuthRepository();
  final dataRepo = AppRepository();
  // final authRepo = SupabaseAuthRepository();
  // final dataRepo = SupabaseDataRepository();
  final acct = AccountCubit(repo: authRepo);
  await acct.load();
  final role = RoleCubit(repo: authRepo);
  await role.load();
  runApp(MyApp(repo: dataRepo, acct: acct, role: role));
}

class MyApp extends StatelessWidget {
  final DataRepository repo;
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
        if (locale == null) return const Locale('en');
        if (supported.contains(locale) &&
            GlobalMaterialLocalizations.delegate.isSupported(locale)) {
          return locale;
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
