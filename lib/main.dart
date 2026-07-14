import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_resturant/router/app_router.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/cubits/settings_cubit.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/database/repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(repo: AppRepository()));
}

class MyApp extends StatelessWidget {
  final AppRepository repo;
  const MyApp({super.key, required this.repo});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OrderCubit(repo: repo)),
        BlocProvider(create: (_) => SettingsCubit()),
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
      supportedLocales: const [Locale('ar'), Locale('en')],
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
