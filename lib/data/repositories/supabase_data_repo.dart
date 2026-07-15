import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';

class SupabaseDataRepository implements DataRepository {
  SupabaseClient get _client => Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  // ── Recipes ───────────────────────────────────────────────

  Recipe _mapRecipe(Map<String, dynamic> row) => Recipe(
    id: row['id'] as String,
    name: row['name'] as String,
    imageUrl: row['image_url'] as String,
    price: (row['price'] as num).toDouble(),
    description: row['description'] as String,
    category: row['category'] as String,
    available: row['available'] as bool,
  );

  @override
  Future<List<Recipe>> loadRecipes() async {
    final data = await _client.from('recipes').select();
    return data.map(_mapRecipe).toList();
  }

  @override
  Future<void> addRecipe(Recipe r) async {
    await _client.from('recipes').insert({
      'id': r.id,
      'name': r.name,
      'image_url': r.imageUrl,
      'price': r.price,
      'description': r.description,
      'category': r.category,
      'available': r.available,
      'restaurant_id': _userId,
    });
  }

  @override
  Future<void> editRecipe(
    String id, {
    String? name,
    double? price,
    String? category,
    String? description,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (price != null) updates['price'] = price;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (updates.isNotEmpty) {
      await _client.from('recipes').update(updates).eq('id', id);
    }
  }

  Future<String> uploadImage(String recipeId, Uint8List bytes) async {
    final path = 'recipes/$recipeId.jpg';
    await _client.storage
        .from('recipe_images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('recipe_images').getPublicUrl(path);
  }

  @override
  Future<void> removeRecipe(String id) async {
    await _client.from('recipes').delete().eq('id', id);
  }

  @override
  Future<void> toggleRecipe(String id) async {
    final data = await _client
        .from('recipes')
        .select('available')
        .eq('id', id)
        .single();
    await _client
        .from('recipes')
        .update({'available': !(data['available'] as bool)})
        .eq('id', id);
  }

  @override
  Stream<List<Recipe>> watchRecipes() {
    return _client
        .from('recipes')
        .stream(primaryKey: ['id'])
        .map((data) => data.map(_mapRecipe).toList());
  }

  // ── Orders ────────────────────────────────────────────────

  Order _mapOrder(Map<String, dynamic> row) {
    final items = (jsonDecode(row['items_json'] as String) as List).map((item) {
      return CartItem(
        recipe: Recipe(
          id: item['recipe_id'],
          name: item['recipe_name'],
          imageUrl: item['recipe_image_url'] ?? '',
          price: (item['recipe_price'] as num).toDouble(),
          description: '',
          category: '',
          available: true,
        ),
        quantity: item['quantity'] as int,
        notes: item['notes'] as String? ?? '',
      );
    }).toList();

    return Order(
      id: row['id'] as String,
      tableNumber: row['table_number'] as int,
      tableName: row['table_label'] as String?,
      items: items,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      notes: row['notes'] as String? ?? '',
    );
  }

  @override
  Future<List<Order>> loadOrders() async {
    final data = await _client
        .from('orders')
        .select()
        .order('created_at', ascending: false);
    return data.map(_mapOrder).toList();
  }

  @override
  Future<void> saveOrder(Order order) async {
    final itemsJson = jsonEncode(
      order.items
          .map(
            (item) => {
              'recipe_id': item.recipe.id,
              'recipe_name': item.recipe.name,
              'recipe_price': item.recipe.price,
              'recipe_image_url': item.recipe.imageUrl,
              'quantity': item.quantity,
              'notes': item.notes,
            },
          )
          .toList(),
    );

    await _client.from('orders').insert({
      'id': order.id,
      'table_number': order.tableNumber,
      'table_label': order.tableName,
      'status': order.status.name,
      'created_at': order.createdAt.millisecondsSinceEpoch,
      'notes': order.notes,
      'items_json': itemsJson,
      'restaurant_id': _userId,
    });
  }

  @override
  Future<void> changeOrderStatus(String id, OrderStatus status) async {
    await _client.from('orders').update({'status': status.name}).eq('id', id);
  }

  @override
  Stream<List<Order>> watchOrders() {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .map((data) => data.map(_mapOrder).toList());
  }

  // ── Settings ──────────────────────────────────────────────

  @override
  Future<Map<String, String>> loadSettings() async {
    final data = await _client.from('app_settings').select();
    return {
      for (final row in data) row['key'] as String: row['value'] as String,
    };
  }

  @override
  Future<void> saveSetting(String key, String value) async {
    await _client.from('app_settings').upsert({
      'key': key,
      'value': value,
      'restaurant_id': _userId,
    }, onConflict: 'key, restaurant_id');
  }

  @override
  Stream<Map<String, String>> watchSettings() {
    return _client
        .from('app_settings')
        .stream(primaryKey: ['key'])
        .map(
          (data) => {
            for (final row in data)
              row['key'] as String: row['value'] as String,
          },
        );
  }
}
