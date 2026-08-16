import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';

abstract class SupabaseAuthRepositoryBase implements AuthRepository {
  SupabaseClient get client => Supabase.instance.client;
}
