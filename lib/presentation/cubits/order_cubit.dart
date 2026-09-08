import 'dart:async';
import 'dart:ui';

import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cart_mixin.dart';
import 'package:my_resturant/presentation/cubits/order_crud_mixin.dart';
import 'package:my_resturant/presentation/cubits/order_cubit_base.dart';
import 'package:my_resturant/presentation/cubits/order_stream_mixin.dart';
import 'package:my_resturant/presentation/cubits/order_table_mixin.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:uuid/uuid.dart';

String errorKey(Object e) => networkErrorKey(e);

class OrderCubit extends OrderCubitBase
    with OrderStreamMixin, OrderCartMixin, OrderTableMixin, OrderCrudMixin {
  StreamSubscription? _authSub;
  StreamSubscription<bool>? _connSub;
  bool _wasAuthed = false;

  OrderCubit({super.repo}) {
    _wasAuthed = _sessionActive();
    notifier.init();
    loadAndSubscribe();
    _authSub = _listenAuth();
    _connSub = NetworkService.instance.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  bool _sessionActive() {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  StreamSubscription? _listenAuth() {
    try {
      return Supabase.instance.client.auth.onAuthStateChange.listen((state) {
        final authed = state.session != null;
        if (authed && !_wasAuthed) {
          loadAndSubscribe();
        } else if (!authed && _wasAuthed) {
          disposeSubs();
        }
        _wasAuthed = authed;
      });
    } catch (_) {
      return null;
    }
  }

  /// When connectivity comes back, re-fetch everything and re-subscribe to the
  /// realtime streams (they give up with capped backoff while offline).
  void _onConnectivityChanged(bool connected) {
    if (connected && _wasAuthed) {
      loadAndSubscribe();
    }
  }

  void setCurrentRole(Role? role) => notifier.setRole(role);

  void setCurrentLocale(Locale locale) => notifier.setLocale(locale);

  void clearError() {
    if (!isClosed) emit(state.copyWith(errorMessage: null));
  }

  Future<bool> submitOrder(String notes) async {
    if (state.cart.isEmpty || state.selectedTable == 0 || state.isSubmitting) {
      return false;
    }
    if (!isClosed) emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final order = Order(
        id: const Uuid().v4(),
        tableNumber: state.selectedTable,
        tableName: state.getTableName(state.selectedTable),
        items: List.from(state.cart),
        notes: notes,
      );
      await repo.saveOrder(order);
      final cleared = Set<int>.from(state.clearedTables)
        ..remove(state.selectedTable);
      await repo.saveSetting('cleared_${state.selectedTable}', 'false');
      if (!isClosed) {
        emit(
          state.copyWith(
            cart: [],
            selectedTable: 0,
            pendingNotes: const {},
            clearedTables: cleared,
            isSubmitting: false,
          ),
        );
      }
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isSubmitting: false, errorMessage: errorKey(e)));
      }
      return false;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await repo.changeOrderStatus(orderId, status);
      await refresh();
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> addItemsToOrder(String orderId, List<CartItem> items) async {
    if (items.isEmpty) return;
    try {
      await repo.appendItemsToOrder(orderId, items);
      await refresh();
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> deleteAllOrders() async {
    try {
      await repo.deleteAllOrders();
      if (!isClosed) emit(state.copyWith(orders: [], errorMessage: null));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> refresh() async {
    try {
      final orders = await repo.loadOrders();
      final recipes = await repo.loadRecipes();
      final cats = await repo.loadCategories();
      if (!isClosed) {
        emit(
          state.copyWith(
            orders: orders,
            recipes: recipes,
            categories: cats,
            isLoading: false,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, errorMessage: errorKey(e)));
      }
    }
  }

  @override
  Future<void> close() {
    disposeSubs();
    _authSub?.cancel();
    _connSub?.cancel();
    return super.close();
  }
}
