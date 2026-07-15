import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:my_resturant/core/config/supabase_credentials.dart';
import 'package:my_resturant/core/router/app_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/theme/app_theme.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';
import 'package:my_resturant/data/repositories/data_repository.dart';
import 'package:my_resturant/data/repositories/auth_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseCredentials.url,
    publishableKey: SupabaseCredentials.publishableKey,
  );

  final authRepo = LocalAuthRepository();
  final dataRepo = AppRepository();

  if (!await authRepo.isAccountCreated()) {
    await authRepo.createAccount('admin@demo.com', 'password');
    await authRepo.savePasscodes('1111', '2222', '3333');
  }

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
    String t(String key) => Tr.get(key, settings.locale);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog(context, t);
      },
      child: MaterialApp.router(
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
    ),
    );
  }

  void _showExitDialog(BuildContext context, String Function(String) t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('app_name')),
        content: Text(t('exit_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              SystemNavigator.pop();
            },
            child: Text(t('exit'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
