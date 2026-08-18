import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/order_cubit_base.dart';

mixin OrderCrudMixin on OrderCubitBase {
  Future<void> addRecipe(Recipe recipe) async {
    try {
      await repo.addRecipe(recipe);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await repo.removeRecipe(id);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> updateRecipe(
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
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> toggleAvailability(String id) async {
    try {
      await repo.toggleRecipe(id);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> addCategory(String key, String name, String icon) async {
    try {
      await repo.addCategory(key, name, icon);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }

  Future<void> removeCategory(String key) async {
    try {
      await repo.removeCategory(key);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: errorKey(e)));
    }
  }
}
