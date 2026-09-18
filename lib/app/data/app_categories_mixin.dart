import 'package:my_resturant/app/data/app_repository.dart';
import 'package:my_resturant/app/data/datasources/local/app_database.dart';

mixin AppCategoriesRepoMixin on AppRepositoryBase {
  Future<List<Map<String, String>>> loadCategories() => db.getAllCategoryMaps();

  Future<void> addCategory(String key, String name, String icon) =>
      db.insertCategory(key, name, icon);

  Future<void> removeCategory(String key) async {
    await db.deleteCategoryByKey(key);
    streams.categories.add(await loadCategories());
  }

  Stream<List<Map<String, String>>> watchCategories() =>
      streams.categories.stream;
}