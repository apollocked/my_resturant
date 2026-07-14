import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_state.dart';
import 'package:my_resturant/data/repositories/data_repository.dart';

class OrderCubit extends Cubit<OrderState> {
  final AppRepository _repo;

  OrderCubit({AppRepository? repo}) : _repo = repo ?? AppRepository(), super(const OrderState()) {
    _load();
  }

  Future<void> _load() async {
    final recipes = await _repo.loadRecipes();
    final orders = await _repo.loadOrders();
    final settings = await _repo.loadSettings();
    final tableCount = int.tryParse(settings['tableCount'] ?? '10') ?? 10;
    final names = <int, String>{};
    for (final e in settings.entries) {
      if (e.key.startsWith('tableName_')) {
        final n = int.tryParse(e.key.split('_').last);
        if (n != null) names[n] = e.value;
      }
    }
    emit(state.copyWith(recipes: recipes, orders: orders, tableCount: tableCount, tableNames: names));
  }

  void addToCart(Recipe recipe) {
    final cart = List<CartItem>.from(state.cart);
    final idx = cart.indexWhere((c) => c.recipe.id == recipe.id);
    if (idx >= 0) {
      cart[idx] = CartItem(recipe: cart[idx].recipe, quantity: cart[idx].quantity + 1, notes: cart[idx].notes);
    } else {
      final notes = state.pendingNotes[recipe.id] ?? '';
      final pending = Map<String, String>.from(state.pendingNotes)..remove(recipe.id);
      cart.add(CartItem(recipe: recipe, notes: notes));
      emit(state.copyWith(cart: cart, pendingNotes: pending));
      return;
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
    } else {
      final pending = Map<String, String>.from(state.pendingNotes)..[recipeId] = notes;
      emit(state.copyWith(pendingNotes: pending));
    }
  }

  void updateNotes(int index, String notes) {
    if (index < 0 || index >= state.cart.length) return;
    final cart = List<CartItem>.from(state.cart);
    cart[index] = CartItem(recipe: cart[index].recipe, quantity: cart[index].quantity, notes: notes);
    emit(state.copyWith(cart: cart));
  }

  void clearCart() => emit(state.copyWith(cart: [], pendingNotes: const {}));

  void setSelectedTable(int t) => emit(state.copyWith(selectedTable: t));

  void setTableCount(int v) {
    final names = Map<int, String>.from(state.tableNames);
    names.removeWhere((k, _) => k > v);
    emit(state.copyWith(tableCount: v.clamp(1, 20), tableNames: names));
    _repo.saveSetting('tableCount', v.clamp(1, 20).toString());
  }

  void setTableName(int n, String name) {
    final names = Map<int, String>.from(state.tableNames);
    if (name.trim().isEmpty) { names.remove(n); } else { names[n] = name.trim(); }
    emit(state.copyWith(tableNames: names));
    _repo.saveSetting('tableName_$n', name.trim());
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _repo.addRecipe(recipe);
    emit(state.copyWith(recipes: List.from(state.recipes)..add(recipe)));
  }

  Future<void> deleteRecipe(String id) async {
    await _repo.removeRecipe(id);
    emit(state.copyWith(recipes: state.recipes.where((r) => r.id != id).toList()));
  }

  Future<void> updateRecipe(String id, {String? name, double? price, String? category, String? description}) async {
    await _repo.editRecipe(id, name: name, price: price, category: category, description: description);
    final recipes = state.recipes.map((r) => r.id == id
      ? r.copyWith(name: name, price: price, category: category, description: description) : r).toList();
    emit(state.copyWith(recipes: recipes));
  }

  Future<void> toggleAvailability(String id) async {
    await _repo.toggleRecipe(id);
    final recipes = state.recipes.map((r) => r.id == id
      ? r.copyWith(available: !r.available) : r).toList();
    emit(state.copyWith(recipes: recipes));
  }

  Future<void> submitOrder(String notes) async {
    if (state.cart.isEmpty || state.selectedTable == 0) return;
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableNumber: state.selectedTable,
      tableName: state.getTableName(state.selectedTable),
      items: List.from(state.cart), notes: notes,
    );
    await _repo.saveOrder(order);
    final orders = List<Order>.from(state.orders)..insert(0, order);
    emit(state.copyWith(cart: [], orders: orders, selectedTable: 0, pendingNotes: const {}));
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _repo.changeOrderStatus(orderId, status);
    final orders = state.orders.map((o) => o.id == orderId ? o.copyWith(status: status) : o).toList();
    emit(state.copyWith(orders: orders));
  }

  void refresh() => emit(state.copyWith());
}
