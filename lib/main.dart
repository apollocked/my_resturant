import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/app/bootstrap/app_bootstrap.dart';
import 'package:my_resturant/app/domain/data_repository.dart';
import 'package:my_resturant/app/presentation/app_view.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/auth/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/printer/presentation/cubits/printer_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await bootstrapApp();
  runApp(
    MyApp(
      repo: deps.repo,
      acct: deps.acct,
      role: deps.role,
      settings: deps.settings,
      printer: deps.printer,
    ),
  );
}

class MyApp extends StatelessWidget {
  final DataRepository repo;
  final AccountCubit acct;
  final RoleCubit role;
  final SettingsCubit settings;
  final PrinterCubit printer;
  const MyApp({
    super.key,
    required this.repo,
    required this.acct,
    required this.role,
    required this.settings,
    required this.printer,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OrderCubit(repo: repo)),
        BlocProvider(create: (_) => settings),
        BlocProvider(create: (_) => acct),
        BlocProvider(create: (_) => role),
        BlocProvider.value(value: printer),
      ],
      child: const AppView(),
    );
  }
}