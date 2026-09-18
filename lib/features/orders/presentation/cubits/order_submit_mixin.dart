import 'dart:async';

import 'package:my_resturant/features/cart/data/cart_draft_store.dart';
import 'package:my_resturant/features/cart/domain/entities/cart_draft.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit_base.dart';
import 'package:uuid/uuid.dart';

/// Sends orders in the background so the UI never blocks on the network, with
/// an optimistically-cleared cart kept recoverable via the durable device
/// draft.
mixin OrderSubmitMixin on OrderCubitBase {
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
          cleaningRequests: Map<int, DateTime>.from(state.cleaningRequests)
            ..remove(order.tableNumber),
          errorMessage: null,
        ),
      );
    }
    saveDraft();
    unawaited(sendOrderInBackground(order));
    return true;
  }

  Future<void> sendOrderInBackground(Order order) async {
    try {
      await repo.saveOrder(order);
      if (!isClosed) {
        emit(state.copyWith(errorMessage: null));
      }
      // Post-save housekeeping is best effort and must never surface an error
      // for a confirmed order (which could trigger a duplicate send).
      unawaited(clearTableFlag(order.tableNumber));
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

  Future<void> clearTableFlag(int table) async {
    try {
      await repo.saveSetting('cleared_$table', 'false');
    } catch (_) {
      // Best effort; the flag is cosmetic.
    }
    try {
      await repo.saveSetting('request_clean_$table', '');
    } catch (_) {
      // Best effort; the flag is cosmetic.
    }
  }
}