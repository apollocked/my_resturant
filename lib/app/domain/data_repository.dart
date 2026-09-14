import 'package:my_resturant/features/menu/domain/repositories/recipe_repository.dart';
import 'package:my_resturant/features/orders/domain/repositories/order_repository.dart';
import 'package:my_resturant/features/settings/domain/repositories/settings_repository.dart';

abstract class DataRepository implements RecipeRepository, OrderRepository, SettingsRepository {
  Future<List<Map<String, String>>> loadCategories();
  Future<void> addCategory(String key, String name, String icon);
  Future<void> removeCategory(String key);
  Stream<List<Map<String, String>>> watchCategories();
}
