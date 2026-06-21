import 'package:flutter/foundation.dart';
import 'package:my_resturant/models/recipe.dart';

class OrderViewModel extends ChangeNotifier {
  final List<Recipe> _orders = [];

  List<Recipe> get orders => List.unmodifiable(_orders);
  int get orderCount => _orders.length;

  void addOrder(Recipe recipe) {
    _orders.add(recipe);
    notifyListeners();
  }

  void removeOrder(int index) {
    if (index >= 0 && index < _orders.length) {
      _orders.removeAt(index);
      notifyListeners();
    }
  }

  double get totalPrice =>
      _orders.fold(0.0, (sum, item) => sum + item.price);

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
