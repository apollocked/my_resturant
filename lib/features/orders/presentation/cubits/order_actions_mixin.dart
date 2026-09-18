import 'package:my_resturant/features/orders/domain/entities/cart_item.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit_base.dart';

/// Order administration actions: status changes, item edits, refresh and bulk
/// delete. Every action emits an error message on failure and nothing else.
mixin OrderActionsMixin on OrderCubitBase {
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
}