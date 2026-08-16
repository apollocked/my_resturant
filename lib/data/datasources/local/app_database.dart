import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:my_resturant/data/datasources/local/seed_data.dart';
import 'package:my_resturant/data/datasources/local/tables.dart';

export 'app_database_order_queries.dart';
export 'app_database_recipe_queries.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Recipes, Categories, Orders, OrderItems, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
  );

  Future<void> _seed() async {
    for (final r in seedRecipes) {
      await into(recipes).insert(
        RecipesCompanion.insert(
          id: r.$1,
          name: r.$2,
          imageUrl: r.$3,
          price: r.$4,
          description: r.$5,
          category: r.$6,
        ),
      );
    }
    for (final c in seedCategories) {
      await into(
        categories,
      ).insert(CategoriesCompanion.insert(key: c.$1, name: c.$2, icon: c.$3));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    await Directory(dir.path).create(recursive: true);
    return NativeDatabase(File(p.join(dir.path, 'restaurant.db')));
  });
}
