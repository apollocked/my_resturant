import 'dart:async';
import 'dart:ui';

import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/core/services/cart_draft_store.dart';
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
    restoreDraft();
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

  /// Sends the order in the background and returns immediately, so the UI
  /// animations and navigation never wait on the network. The cart is cleared
  /// optimistically (a durable device draft keeps everything recoverable).
  /// The DB write is only verified at the point it actually fails: the error
  /// snackbar fires and the unsent items come back automatically.
  Future<bool> submitOrder(String notes) async {
    if (state.cart.isEmpty || state.selectedTable == 0 || state.isSubmitting) {
      return false;
    }
    final order = Order(
      id: const Uuid().v4(),
      tableNumber: state.selectedTable,
      tableName: state.getTableName(state.selectedTable),
      items: List.from(state.cart),
      notes: notes,
    );
    if (!isClosed) {
      emit(
        state.copyWith(
          cart: [],
          selectedTable: 0,
          pendingNotes: const {},
          clearedTables: Set<int>.from(state.clearedTables)
            ..remove(order.tableNumber),
          errorMessage: null,
        ),
      );
    }
    saveDraft();
    unawaited(_sendOrderInBackground(order));
    return true;
  }

  Future<void> _sendOrderInBackground(Order order) async {
    try {
      await repo.saveOrder(order);
      if (!isClosed) {
        emit(state.copyWith(errorMessage: null));
      }
      // Post-save housekeeping is best effort and must never surface an error
      // for a confirmed order (which could trigger a duplicate send).
      unawaited(_clearTableFlag(order.tableNumber));
    } catch (e) {
      if (isClosed) return;
      if (state.cart.isEmpty) {
        // Nothing new has been typed yet: bring the unsent order back so the
        // user can retry with one tap and no data is lost.
        unawaited(
          CartDraftStore.instance.save(
            CartDraft(
              items: List.from(order.items),
              selectedTable: order.tableNumber,
              pendingNotes: const {},
            ),
          ),
        );
        emit(
          state.copyWith(
            cart: List.from(order.items),
            selectedTable: order.tableNumber,
            errorMessage: errorKey(e),
          ),
        );
      } else {
        // A new cart is already in progress: never clobber it, just report the
        // failure (the failed snapshot is still safe in the device draft).
        emit(state.copyWith(errorMessage: errorKey(e)));
      }
    }
  }

  Future<void> _clearTableFlag(int table) async {
    try {
      await repo.saveSetting('cleared_$table', 'false');
    } catch (_) {
      // Best effort; the flag is cosmetic.
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
