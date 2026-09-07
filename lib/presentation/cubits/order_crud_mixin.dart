import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/order_cubit_base.dart';

mixin OrderCrudMixin on OrderCubitBase {
  Future<bool> addRecipe(Recipe recipe) async {
    try {
      await repo.addRecipe(recipe);
      return true;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
      return false;
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await repo.removeRecipe(id);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<bool> updateRecipe(
    String id, {
    String? name,
    double? price,
    String? category,
    String? description,
    String? imageUrl,
  }) async {
    try {
      await repo.editRecipe(
        id,
        name: name,
        price: price,
        category: category,
        description: description,
        imageUrl: imageUrl,
      );
      return true;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
      return false;
    }
  }

  Future<void> toggleAvailability(String id) async {
    try {
      await repo.toggleRecipe(id);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<bool> addCategory(String key, String name, String icon) async {
    try {
      await repo.addCategory(key, name, icon);
      return true;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
      return false;
    }
  }

  Future<void> removeCategory(String key) async {
    try {
      await repo.removeCategory(key);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> removeItemFromOrder(String orderId, int itemIndex) async {
    try {
      final order = state.orders.firstWhere((o) => o.id == orderId);
      final updated = List<CartItem>.from(order.items);
      updated.removeAt(itemIndex);
      await repo.updateOrderItems(orderId, updated);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> updateItemQuantity(
    String orderId,
    int itemIndex,
    int quantity,
  ) async {
    try {
      final order = state.orders.firstWhere((o) => o.id == orderId);
      final updated = List<CartItem>.from(order.items);
      if (quantity <= 0) {
        updated.removeAt(itemIndex);
      } else {
        final old = updated[itemIndex];
        updated[itemIndex] = CartItem(
          recipe: old.recipe,
          quantity: quantity,
          notes: old.notes,
        );
      }
      await repo.updateOrderItems(orderId, updated);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> updateOrderNotes(String orderId, String notes) async {
    try {
      await repo.updateOrderNotes(orderId, notes);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }
}
