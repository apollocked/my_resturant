import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit_base.dart';

mixin OrderCartMixin on OrderCubitBase {
  void addToCart(Recipe recipe) {
    final cart = List<CartItem>.from(state.cart);
    final idx = cart.indexWhere((c) => c.recipe.id == recipe.id);
    if (idx >= 0) {
      final pending = state.pendingNotes[recipe.id];
      final newNotes = pending != null && pending.isNotEmpty
          ? pending
          : cart[idx].notes;
      cart[idx] = CartItem(
        recipe: cart[idx].recipe,
        quantity: cart[idx].quantity + 1,
        notes: newNotes,
      );
      final updatedPending = pending != null
          ? (Map<String, String>.from(state.pendingNotes)..remove(recipe.id))
          : null;
      emit(
        state.copyWith(
          cart: cart,
          pendingNotes: updatedPending ?? state.pendingNotes,
        ),
      );
      saveDraft();
    } else {
      final notes = state.pendingNotes[recipe.id] ?? '';
      final pending = Map<String, String>.from(state.pendingNotes)
        ..remove(recipe.id);
      cart.add(CartItem(recipe: recipe, notes: notes));
      emit(state.copyWith(cart: cart, pendingNotes: pending));
      saveDraft();
      return;
    }
  }

  void decrementOrRemove(String recipeId) {
    final cart = List<CartItem>.from(state.cart);
    final idx = cart.indexWhere((c) => c.recipe.id == recipeId);
    if (idx < 0) return;
    if (cart[idx].quantity > 1) {
      cart[idx] = CartItem(
        recipe: cart[idx].recipe,
        quantity: cart[idx].quantity - 1,
        notes: cart[idx].notes,
      );
    } else {
      cart.removeAt(idx);
    }
    emit(state.copyWith(cart: cart));
    saveDraft();
  }

  void updateQuantity(int index, int delta) {
    if (index < 0 || index >= state.cart.length) return;
    final cart = List<CartItem>.from(state.cart);
    final newQty = cart[index].quantity + delta;
    if (newQty <= 0) {
      cart.removeAt(index);
    } else {
      cart[index] = CartItem(
        recipe: cart[index].recipe,
        quantity: newQty.clamp(1, 99),
        notes: cart[index].notes,
      );
    }
    emit(state.copyWith(cart: cart));
    saveDraft();
  }

  void removeFromCart(int index) {
    if (index < 0 || index >= state.cart.length) return;
    final cart = List<CartItem>.from(state.cart)..removeAt(index);
    emit(state.copyWith(cart: cart));
    saveDraft();
  }

  void removeFromCartById(String recipeId) {
    final cart = List<CartItem>.from(state.cart);
    cart.removeWhere((c) => c.recipe.id == recipeId);
    emit(state.copyWith(cart: cart));
    saveDraft();
  }

  void updateNotesByRecipe(String recipeId, String notes) {
    final cart = List<CartItem>.from(state.cart);
    final idx = cart.indexWhere((c) => c.recipe.id == recipeId);
    if (idx >= 0) {
      cart[idx] = CartItem(
        recipe: cart[idx].recipe,
        quantity: cart[idx].quantity,
        notes: notes,
      );
      emit(state.copyWith(cart: cart));
      saveDraft();
    } else {
      final pending = Map<String, String>.from(state.pendingNotes)
        ..[recipeId] = notes;
      emit(state.copyWith(pendingNotes: pending));
      saveDraft();
    }
  }

  void updateNotes(int index, String notes) {
    if (index < 0 || index >= state.cart.length) return;
    final cart = List<CartItem>.from(state.cart);
    cart[index] = CartItem(
      recipe: cart[index].recipe,
      quantity: cart[index].quantity,
      notes: notes,
    );
    emit(state.copyWith(cart: cart));
    saveDraft();
  }

  void clearCart() {
    emit(state.copyWith(cart: [], pendingNotes: const {}));
    saveDraft();
  }

  void setSelectedTable(int t) {
    emit(state.copyWith(selectedTable: t));
    saveDraft();
  }
}
