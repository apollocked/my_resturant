import 'package:my_resturant/domain/repositories/recipe_repository.dart';
import 'package:my_resturant/domain/repositories/order_repository.dart';
import 'package:my_resturant/domain/repositories/settings_repository.dart';

abstract class DataRepository implements RecipeRepository, OrderRepository, SettingsRepository {}
