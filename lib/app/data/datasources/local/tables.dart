import 'package:drift/drift.dart';

@DataClassName('RecipeRecord')
class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text()();
  RealColumn get price => real()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  BoolColumn get available => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryRecord')
class Categories extends Table {
  TextColumn get key => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('OrderRecord')
class Orders extends Table {
  TextColumn get id => text()();
  IntColumn get tableNumber => integer()();
  TextColumn get tableLabel => text().nullable()();
  TextColumn get status => text()();
  IntColumn get createdAt => integer()();
  TextColumn get notes => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OrderItemRecord')
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get recipeId => text()();
  IntColumn get quantity => integer()();
  TextColumn get notes => text()();
}

@DataClassName('SettingRecord')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
