import 'dart:async';
import 'dart:ui';

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

class OrderCubit extends OrderCubitBase
    with OrderStreamMixin, OrderCartMixin, OrderTableMixin, OrderCrudMixin {
  StreamSubscription? _authSub;
  bool _wasAuthed = false;

  OrderCubit({super.repo}) {
    _wasAuthed = Supabase.instance.client.auth.currentSession != null;
    notifier.init();
    loadAndSubscribe();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      final authed = state.session != null;
      if (authed && !_wasAuthed) {
        loadAndSubscribe();
      } else if (!authed && _wasAuthed) {
        disposeSubs();
      }
      _wasAuthed = authed;
    });
  }

  void setCurrentRole(Role? role) => notifier.setRole(role);

  void setCurrentLocale(Locale locale) => notifier.setLocale(locale);

  Future<void> submitOrder(String notes) async {
    if (state.cart.isEmpty || state.selectedTable == 0 || state.isSubmitting) {
      return;
    }
    if (!isClosed) emit(state.copyWith(isSubmitting: true));
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
    } catch (e) {
      if (!isClosed) emit(state.copyWith(isSubmitting: false));
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await repo.changeOrderStatus(orderId, status);
    await refresh();
  }

  Future<void> addItemsToOrder(String orderId, List<CartItem> items) async {
    if (items.isEmpty) return;
    await repo.appendItemsToOrder(orderId, items);
    await refresh();
  }

  Future<void> deleteAllOrders() async {
    await repo.deleteAllOrders();
    if (!isClosed) emit(state.copyWith(orders: []));
  }

  Future<void> refresh() async {
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
        ),
      );
    }
  }

  @override
  Future<void> close() {
    disposeSubs();
    _authSub?.cancel();
    return super.close();
  }
}
