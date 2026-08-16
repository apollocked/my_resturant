import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit_base.dart';

mixin OrderCrudMixin on OrderCubitBase {
  Future<void> addRecipe(Recipe recipe) async => repo.addRecipe(recipe);

  Future<void> deleteRecipe(String id) async => repo.removeRecipe(id);

  Future<void> updateRecipe(
    String id, {
    String? name,
    double? price,
    String? category,
    String? description,
    String? imageUrl,
  }) async => repo.editRecipe(
    id,
    name: name,
    price: price,
    category: category,
    description: description,
    imageUrl: imageUrl,
  );

  Future<void> toggleAvailability(String id) async => repo.toggleRecipe(id);

  Future<void> addCategory(String key, String name, String icon) async {
    await repo.addCategory(key, name, icon);
  }

  Future<void> removeCategory(String key) async {
    await repo.removeCategory(key);
  }
}
