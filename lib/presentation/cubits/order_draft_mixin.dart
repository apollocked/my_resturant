import 'dart:async';

import 'package:my_resturant/core/services/cart_draft_store.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/presentation/cubits/order_cubit_base.dart';

mixin OrderDraftMixin on OrderCubitBase {
  bool _draftRestoreDone = false;

  /// Restores the last unsent cart (and selected table) after a crash or a
  /// normal app restart so no draft order is ever lost.
  Future<void> restoreDraft() async {
    if (_draftRestoreDone) return;
    _draftRestoreDone = true;
    try {
      final draft = await CartDraftStore.instance.load();
      if (draft == null || draft.items.isEmpty || isClosed) return;
      final cart = draft.items
          .map(
            (i) => CartItem(
              recipe: i.recipe,
              quantity: i.quantity.clamp(1, 99),
              notes: i.notes,
            ),
          )
          .toList();
      emit(
        state.copyWith(
          cart: cart,
          selectedTable: draft.selectedTable,
          pendingNotes: draft.pendingNotes,
        ),
      );
    } catch (_) {
      // A corrupt draft is dropped quietly; the app must never crash on boot.
    }
  }

  /// Persists the current cart as a draft in the background. Best-effort and
  /// never blocks or throws: if the device crashes, the draft survives.
  void saveDraft() {
    if (state.cart.isEmpty) {
      unawaited(CartDraftStore.instance.clear());
      return;
    }
    unawaited(
      CartDraftStore.instance.save(
        CartDraft(
          items: List.from(state.cart),
          selectedTable: state.selectedTable,
          pendingNotes: Map.from(state.pendingNotes),
        ),
      ),
    );
  }
}