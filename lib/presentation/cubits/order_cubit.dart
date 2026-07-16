import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_state.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';
import 'package:my_resturant/data/repositories/data_repository.dart';

class OrderCubit extends Cubit<OrderState> {
  final DataRepository _repo;
  StreamSubscription? _orderSub;
  StreamSubscription? _recipeSub;
  StreamSubscription? _settingSub;

  OrderCubit({DataRepository? repo}) : _repo = repo ?? AppRepository(), super(const OrderState()) {
    _load();
  }

  Future<void> _load() async {
    final recipes = await _repo.loadRecipes();
    final orders = await _repo.loadOrders();
    final settings = await _repo.loadSettings();
    _applySettings(settings);
    emit(state.copyWith(recipes: recipes, orders: orders));

    _orderSub = _repo.watchOrders().listen((o) {
      if (!isClosed) emit(state.copyWith(orders: o));
    });
    _recipeSub = _repo.watchRecipes().listen((r) {
      if (!isClosed) emit(state.copyWith(recipes: r));
    });
    _settingSub = _repo.watchSettings().listen((s) {
      if (!isClosed) _applySettings(s);
    });
  }

  void _applySettings(Map<String, String> settings) {
    final tableCount = int.tryParse(settings['tableCount'] ?? '10') ?? 10;
    final names = <int, String>{};
    for (final e in settings.entries) {
      if (e.key.startsWith('tableName_')) {
        final n = int.tryParse(e.key.split('_').last);
        if (n != null) names[n] = e.value;
      }
    }
    emit(state.copyWith(tableCount: tableCount, tableNames: names));
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

  void removeFromCartById(String recipeId) {
    final cart = List<CartItem>.from(state.cart);
    cart.removeWhere((c) => c.recipe.id == recipeId);
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
    emit(state.copyWith(tableCount: v.clamp(1, 35), tableNames: names));
    _repo.saveSetting('tableCount', v.clamp(1, 35).toString());
  }

  void setTableName(int n, String name) {
    final names = Map<int, String>.from(state.tableNames);
    if (name.trim().isEmpty) { names.remove(n); } else { names[n] = name.trim(); }
    emit(state.copyWith(tableNames: names));
    _repo.saveSetting('tableName_$n', name.trim());
  }

  Future<void> addRecipe(Recipe recipe) async => _repo.addRecipe(recipe);

  Future<void> deleteRecipe(String id) async => _repo.removeRecipe(id);

  Future<void> updateRecipe(String id, {String? name, double? price, String? category, String? description}) async =>
      _repo.editRecipe(id, name: name, price: price, category: category, description: description);

  Future<void> toggleAvailability(String id) async => _repo.toggleRecipe(id);

  Future<void> submitOrder(String notes) async {
    if (state.cart.isEmpty || state.selectedTable == 0) return;
    final order = Order(
      id: const Uuid().v4(),
      tableNumber: state.selectedTable,
      tableName: state.getTableName(state.selectedTable),
      items: List.from(state.cart), notes: notes,
    );
    await _repo.saveOrder(order);
    emit(state.copyWith(cart: [], selectedTable: 0, pendingNotes: const {}));
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async =>
      _repo.changeOrderStatus(orderId, status);

  Future<void> deleteAllOrders() async {
    await _repo.deleteAllOrders();
    if (!isClosed) emit(state.copyWith(orders: []));
  }

  Future<void> refresh() async {
    final orders = await _repo.loadOrders();
    if (!isClosed) emit(state.copyWith(orders: orders));
  }

  @override
  Future<void> close() {
    _orderSub?.cancel();
    _recipeSub?.cancel();
    _settingSub?.cancel();
    return super.close();
  }
}
