import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:my_resturant/core/config/supabase_credentials.dart';
import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/core/router/app_router.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/theme/app_theme.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';
import 'package:my_resturant/data/repositories/supabase_data_repo.dart';
import 'package:my_resturant/data/repositories/supabase_auth_repo.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  await Supabase.initialize(
    url: SupabaseCredentials.url,
    publishableKey: SupabaseCredentials.publishableKey,
    httpClient: _TimeoutClient(http.Client()),
  );
  await NetworkService.instance.init();
  final authRepo = SupabaseAuthRepository();
  final dataRepo = SupabaseDataRepository();
  final acct = AccountCubit(repo: authRepo);
  await acct.load();
  final role = RoleCubit(repo: authRepo);
  await role.load();
  final settings = await SettingsCubit.create();
  runApp(MyApp(repo: dataRepo, acct: acct, role: role, settings: settings));
}

class MyApp extends StatelessWidget {
  final DataRepository repo;
  final AccountCubit acct;

  final RoleCubit role;
  final SettingsCubit settings;
  const MyApp({
    super.key,
    required this.repo,
    required this.acct,
    required this.role,
    required this.settings,
  });
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OrderCubit(repo: repo)),
        BlocProvider(create: (_) => settings),
        BlocProvider(create: (_) => acct),
        BlocProvider(create: (_) => role),
      ],
      child: const AppView(),
    );
  }
}

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
      builder: (context, child) {
        return BlocListener<OrderCubit, OrderState>(
          listenWhen: (prev, curr) =>
              prev.errorMessage != curr.errorMessage &&
              curr.errorMessage != null,
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
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _TimeoutClient extends http.Client {
  _TimeoutClient(this._inner, {Duration timeout = const Duration(seconds: 20)})
      : _timeout = timeout;
  final http.Client _inner;
  final Duration _timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request).timeout(_timeout);

  @override
  void close() => _inner.close();
}
