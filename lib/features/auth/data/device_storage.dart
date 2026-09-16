import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _prefDeviceId = 'device_id';

/// Stable random id for this app install. Sent as the `x-device-id` header on
/// every Supabase request so the backend can give each device its own role
/// (`current_role()` / `set_role()` in Postgres).
Future<String> getOrCreateDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString(_prefDeviceId);
  if (id == null || id.isEmpty) {
    id = const Uuid().v4();
    await prefs.setString(_prefDeviceId, id);
  }
  return id;
}