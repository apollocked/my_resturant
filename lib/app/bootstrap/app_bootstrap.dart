import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:my_resturant/core/config/supabase_credentials.dart';
import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/core/router/app_router.dart';
import 'package:my_resturant/features/printer/data/printer_service.dart';
import 'package:my_resturant/features/printer/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/features/auth/data/device_storage.dart';
import 'package:my_resturant/features/auth/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/app/domain/data_repository.dart';
import 'package:my_resturant/app/data/supabase_data_repo.dart';
import 'package:my_resturant/features/auth/data/repositories/supabase_auth_repo.dart';
import 'package:my_resturant/firebase_options.dart';

/// Everything main() needs to hand to the widget tree, assembled once.
typedef AppDependencies = ({
  DataRepository repo,
  AccountCubit acct,
  RoleCubit role,
  SettingsCubit settings,
  PrinterCubit printer,
});

/// Global error handlers so an uncaught exception logs instead of taking down
/// the whole app (the "app won't crash" guarantee).
void bootstrapErrorHandlers() {
  FlutterError.onError = (details) {
    debugPrint('[app] Unhandled Flutter error: ${details.exception}');
    debugPrint('[app] Stack: ${details.stack}');
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[app] Uncaught async error: $error\n$stack');
    return true;
  };
}

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[app] background message init failed: $e');
  }
}

Future<AppDependencies> bootstrapApp() async {
  bootstrapErrorHandlers();
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('[app] dotenv load failed: $e');
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  } catch (e) {
    debugPrint('[app] Firebase init failed: $e');
  }
  String deviceId = '';
  try {
    deviceId = await getOrCreateDeviceId();
  } catch (e) {
    debugPrint('[app] device id init failed: $e');
  }
  try {
    await Supabase.initialize(
      url: SupabaseCredentials.url,
      publishableKey: SupabaseCredentials.publishableKey,
      headers: {'x-device-id': deviceId},
    );
  } catch (e) {
    debugPrint('[app] Supabase init failed: $e');
  }
  try {
    await NetworkService.instance.init();
  } catch (e) {
    debugPrint('[app] NetworkService init failed: $e');
  }

  final authRepo = SupabaseAuthRepository();
  final dataRepo = SupabaseDataRepository();
  final acct = AccountCubit(repo: authRepo);
  try {
    await acct.load();
  } catch (e) {
    debugPrint('[app] acct.load failed: $e');
  }
  final role = RoleCubit(repo: authRepo);
  try {
    await role.load();
  } catch (e) {
    debugPrint('[app] role.load failed: $e');
  }
  final settings = await SettingsCubit.create();
  acct.stream.listen((_) => routeRefresh.value++);
  role.stream.listen((_) => routeRefresh.value++);
  settings.stream.listen((_) => routeRefresh.value++);
  final printer = PrinterCubit(PrinterService());
  try {
    await printer.init();
  } catch (e) {
    debugPrint('[app] printer.init failed: $e');
  }
  return (
    repo: dataRepo,
    acct: acct,
    role: role,
    settings: settings,
    printer: printer,
  );
}