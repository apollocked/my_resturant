import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:my_resturant/app/domain/data_repository.dart';
import 'package:my_resturant/app/data/app_categories_mixin.dart';
import 'package:my_resturant/app/data/app_orders_mixin.dart';
import 'package:my_resturant/app/data/app_recipes_mixin.dart';
import 'package:my_resturant/app/data/app_settings_mixin.dart';
import 'package:my_resturant/app/data/app_stream_box.dart';
import 'package:my_resturant/app/data/datasources/local/app_database.dart';

final AppDatabase db = AppDatabase();

/// Shared [AppStreamBox] owner the repository mixins announce writes through.
abstract class AppRepositoryBase {
  final AppStreamBox streams = AppStreamBox();
}

class AppRepository extends AppRepositoryBase
    with
        AppRecipesRepoMixin,
        AppCategoriesRepoMixin,
        AppOrdersRepoMixin,
        AppSettingsRepoMixin
    implements DataRepository {
  void close() => streams.dispose();

  @override
  Future<String> uploadImage(String recipeId, Uint8List bytes) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'uploads', 'recipes'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File(p.join(dir.path, '$recipeId.jpg'));
    await file.writeAsBytes(bytes);
    return file.path;
  }
}