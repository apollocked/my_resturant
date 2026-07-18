import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_state.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';
import 'package:my_resturant/data/repositories/data_repository.dart';
import 'package:my_resturant/core/notifications/order_notification_service.dart';

class OrderCubit extends Cubit<OrderState> {
  final DataRepository _repo;
  final List<StreamSubscription> _subs = [];
  Timer? _pollTimer;
  final OrderNotificationService _notifService = OrderNotificationService();
  Role? _currentRole;
  List<Order> _previousOrders = [];

  OrderCubit({DataRepository? repo}) : _repo = repo ?? AppRepository(), super(const OrderState()) {
    _notifService.init();
    _notifService.requestPermission();
    _load();
  }

  void setCurrentRole(Role? role) => _currentRole = role;

  Future<void> _load() async {
    try {
      final recipes = await _repo.loadRecipes();
      final orders = await _repo.loadOrders();
      final settings = await _repo.loadSettings();
      final cats = await _repo.loadCategories();
      _applySettings(settings);
      if (!isClosed) emit(state.copyWith(recipes: recipes, orders: orders, categories: cats, isLoading: false));
    } catch (e) {
      if (!isClosed) debugPrint('OrderCubit._load error: $e');
    }

    _subscribe(_repo.watchOrders(), (o) {
      if (_currentRole != null) {
        _notifService.checkOrderChanges(_previousOrders, o, _currentRole!);
      }
      _previousOrders = List.from(o);
      if (!isClosed) emit(state.copyWith(orders: o));
    });
    _subscribe(_repo.watchRecipes(), (r) {
      if (!isClosed) emit(state.copyWith(recipes: r));
    });
    _subscribe(_repo.watchSettings(), (s) {
      if (!isClosed) _applySettings(s);
    });
    _subscribe(_repo.watchCategories(), (c) {
      if (!isClosed) emit(state.copyWith(categories: c));
    });

    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _poll());
  }

  void _subscribe<T>(Stream<T> stream, void Function(T) onData) {
    final sub = stream.listen(
      onData,
      onError: (_) => _reconnect(stream, onData),
    );
    _subs.add(sub);
  }

  void _reconnect<T>(Stream<T> stream, void Function(T) onData, [int attempt = 0]) {
    if (isClosed) return;
    final delay = Duration(seconds: min(1 << attempt, 30));
    Future.delayed(delay, () {
      if (isClosed) return;
      stream.listen(
        onData,
        onError: (_) => _reconnect(stream, onData, attempt + 1),
      );
    });
  }

  Future<void> _poll() async {
    if (isClosed) return;
    try {
      final recipes = await _repo.loadRecipes();
      final orders = await _repo.loadOrders();
      if (!isClosed) emit(state.copyWith(recipes: recipes, orders: orders));
    } catch (_) {}
  }

  void _applySettings(Map<String, String> settings) {
    final tableCount = int.tryParse(settings['tableCount'] ?? '10') ?? 10;
    final names = <int, String>{};
    final cleared = <int>{};
    for (final e in settings.entries) {
      if (e.key.startsWith('tableName_')) {
        final n = int.tryParse(e.key.split('_').last);
        if (n != null) names[n] = e.value;
      }
      if (e.key.startsWith('cleared_') && e.value == 'true') {
        final n = int.tryParse(e.key.split('_').last);
        if (n != null) cleared.add(n);
      }
    }
    emit(state.copyWith(tableCount: tableCount, tableNames: names, clearedTables: cleared));
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

  Future<void> addCategory(String key, String name, String icon) async {
    await _repo.addCategory(key, name, icon);
  }

  Future<void> removeCategory(String key) async {
    await _repo.removeCategory(key);
  }

  Future<void> submitOrder(String notes) async {
    if (state.cart.isEmpty || state.selectedTable == 0) return;
    final order = Order(
      id: const Uuid().v4(),
      tableNumber: state.selectedTable,
      tableName: state.getTableName(state.selectedTable),
      items: List.from(state.cart), notes: notes,
    );
    await _repo.saveOrder(order);
    final cleared = Set<int>.from(state.clearedTables)..remove(state.selectedTable);
    _repo.saveSetting('cleared_${state.selectedTable}', 'false');
    emit(state.copyWith(cart: [], selectedTable: 0, pendingNotes: const {}, clearedTables: cleared));
  }

  void clearTable(int tableNumber) {
    final cleared = Set<int>.from(state.clearedTables)..add(tableNumber);
    _repo.saveSetting('cleared_$tableNumber', 'true');
    emit(state.copyWith(clearedTables: cleared));
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _repo.changeOrderStatus(orderId, status);
    await refresh();
  }

  Future<void> deleteAllOrders() async {
    await _repo.deleteAllOrders();
    if (!isClosed) emit(state.copyWith(orders: []));
  }

  Future<void> refresh() async {
    final orders = await _repo.loadOrders();
    final recipes = await _repo.loadRecipes();
    final cats = await _repo.loadCategories();
    if (!isClosed) emit(state.copyWith(orders: orders, recipes: recipes, categories: cats, isLoading: false));
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
