import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/models/cart_item.dart';
import 'package:my_resturant/models/order_model.dart';
import 'package:my_resturant/cubits/order_state.dart';
import 'package:my_resturant/data/mock_data.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(const OrderState());

  void addToCart(Recipe recipe) {
    final cart = List<CartItem>.from(state.cart);
    final idx = cart.indexWhere((c) => c.recipe.id == recipe.id);
    if (idx >= 0) {
      cart[idx] = CartItem(recipe: cart[idx].recipe, quantity: cart[idx].quantity + 1, notes: cart[idx].notes);
    } else {
      cart.add(CartItem(recipe: recipe));
    }
    emit(state.copyWith(cart: cart));
  }

  void decrementOrRemove(String recipeId) {
    final cart = List<CartItem>.from(state.cart);
    final idx = cart.indexWhere((c) => c.recipe.id == recipeId);
    if (idx < 0) return;
    if (cart[idx].quantity > 1) {
      cart[idx] = CartItem(recipe: cart[idx].recipe, quantity: cart[idx].quantity - 1, notes: cart[idx].notes);
    } else {
      cart.removeAt(idx);
    }
    emit(state.copyWith(cart: cart));
  }

  void updateQuantity(int index, int delta) {
    if (index < 0 || index >= state.cart.length) return;
    final cart = List<CartItem>.from(state.cart);
    final newQty = cart[index].quantity + delta;
    if (newQty <= 0) {
      cart.removeAt(index);
    } else {
      cart[index] = CartItem(recipe: cart[index].recipe, quantity: newQty.clamp(1, 99), notes: cart[index].notes);
    }
    emit(state.copyWith(cart: cart));
  }

  void removeFromCart(int index) {
    if (index < 0 || index >= state.cart.length) return;
    final cart = List<CartItem>.from(state.cart)..removeAt(index);
    emit(state.copyWith(cart: cart));
  }

  void updateNotesByRecipe(String recipeId, String notes) {
    final cart = List<CartItem>.from(state.cart);
    final idx = cart.indexWhere((c) => c.recipe.id == recipeId);
    if (idx >= 0) {
      cart[idx] = CartItem(recipe: cart[idx].recipe, quantity: cart[idx].quantity, notes: notes);
      emit(state.copyWith(cart: cart));
    }
  }

  void updateNotes(int index, String notes) {
    if (index < 0 || index >= state.cart.length) return;
    final cart = List<CartItem>.from(state.cart);
    cart[index] = CartItem(recipe: cart[index].recipe, quantity: cart[index].quantity, notes: notes);
    emit(state.copyWith(cart: cart));
  }

  void clearCart() => emit(state.copyWith(cart: []));

  void setSelectedTable(int t) => emit(state.copyWith(selectedTable: t));

  void setTableCount(int v) {
    final names = Map<int, String>.from(state.tableNames);
    names.removeWhere((k, _) => k > v);
    emit(state.copyWith(tableCount: v.clamp(1, 20), tableNames: names));
  }

  void setTableName(int n, String name) {
    final names = Map<int, String>.from(state.tableNames);
    if (name.trim().isEmpty) { names.remove(n); } else { names[n] = name.trim(); }
    emit(state.copyWith(tableNames: names));
  }

  void deleteRecipe(String id) {
    mockRecipes.removeWhere((r) => r.id == id);
    emit(state.copyWith());
  }

  void updateRecipe(String id, {String? name, double? price, String? category, String? description}) {
    final i = mockRecipes.indexWhere((r) => r.id == id);
    if (i >= 0) {
      mockRecipes[i] = mockRecipes[i].copyWith(
        name: name, price: price, category: category, description: description,
      );
    }
    emit(state.copyWith());
  }

  void toggleAvailability(String id) {
    final i = mockRecipes.indexWhere((r) => r.id == id);
    if (i >= 0) { mockRecipes[i] = mockRecipes[i].copyWith(available: !mockRecipes[i].available); }
    emit(state.copyWith());
  }

  void submitOrder(String notes) {
    if (state.cart.isEmpty || state.selectedTable == 0) return;
    final orders = List<Order>.from(state.orders);
    orders.insert(0, Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableNumber: state.selectedTable,
      tableName: state.getTableName(state.selectedTable),
      items: List.from(state.cart), notes: notes,
    ));
    emit(state.copyWith(cart: [], orders: orders, selectedTable: 0));
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final orders = state.orders.map((o) => o.id == orderId ? o.copyWith(status: status) : o).toList();
    emit(state.copyWith(orders: orders));
  }
}
