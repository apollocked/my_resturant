import 'package:flutter/foundation.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/models/cart_item.dart';
import 'package:my_resturant/models/order_model.dart';

class OrderViewModel extends ChangeNotifier {
  final List<CartItem> _cart = [];
  final List<Order> _orders = [];
  int _selectedTable = 1;

  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Order> get orders => List.unmodifiable(_orders);
  int get selectedTable => _selectedTable;
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  set selectedTable(int table) {
    _selectedTable = table;
    notifyListeners();
  }

  int getQuantity(String recipeId) =>
      _cart.where((c) => c.recipe.id == recipeId).firstOrNull?.quantity ?? 0;

  void addToCart(Recipe recipe) {
    final existing = _cart.where((c) => c.recipe.id == recipe.id).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      _cart.add(CartItem(recipe: recipe));
    }
    notifyListeners();
  }

  void decrementOrRemove(String recipeId) {
    final index = _cart.indexWhere((c) => c.recipe.id == recipeId);
    if (index < 0) return;
    if (_cart[index].quantity > 1) {
      _cart[index].quantity--;
    } else {
      _cart.removeAt(index);
    }
    notifyListeners();
  }

  void updateQuantity(int index, int delta) {
    if (index < 0 || index >= _cart.length) return;
    final item = _cart[index];
    final newQty = item.quantity + delta;
    if (newQty <= 0) {
      _cart.removeAt(index);
    } else {
      item.quantity = newQty.clamp(1, 99);
    }
    notifyListeners();
  }

  void updateNotes(int index, String notes) {
    if (index < 0 || index >= _cart.length) return;
    _cart[index].notes = notes;
    notifyListeners();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cart.length) {
      _cart.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void submitOrder(String notes) {
    if (_cart.isEmpty) return;
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableNumber: _selectedTable,
      items: List.from(_cart),
      notes: notes,
    );
    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
    }
  }
}
