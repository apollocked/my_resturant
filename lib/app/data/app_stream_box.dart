import 'dart:async';

import 'package:my_resturant/features/menu/domain/entities/recipe.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';

/// Broadcast controllers shared by the local repository mixins so each
/// `watch*` stream announces writes from any other mixin.
class AppStreamBox {
  final orders = StreamController<List<Order>>.broadcast();
  final recipes = StreamController<List<Recipe>>.broadcast();
  final settings = StreamController<Map<String, String>>.broadcast();
  final categories = StreamController<List<Map<String, String>>>.broadcast();

  void dispose() {
    orders.close();
    recipes.close();
    settings.close();
    categories.close();
  }
}