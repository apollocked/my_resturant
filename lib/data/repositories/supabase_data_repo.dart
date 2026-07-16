import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_resturant/core/constants/app_constants.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';

class SupabaseDataRepository implements DataRepository {
  SupabaseClient get _client => Supabase.instance.client;

  bool get _isAuthed => _client.auth.currentSession != null;
  String? get _userId => _client.auth.currentUser?.id;

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
    if (!_isAuthed) return [];
    final data = await _client.from('recipes').select();
    return data.map(_mapRecipe).toList();
  }

  @override
  Future<void> addRecipe(Recipe r) async {
    final uid = _userId;
    if (uid == null) return;
    final count = await _client
        .from('recipes')
        .select('id')
        .eq('restaurant_id', uid)
        .count();
    if (count.count >= AppConstants.maxRecipesPerRestaurant) {
      throw Exception('Maximum ${AppConstants.maxRecipesPerRestaurant} recipes reached');
    }
    String imageUrl = r.imageUrl;
    if (!imageUrl.startsWith('http')) {
      imageUrl = await _compressAndUpload(uid, r.id, imageUrl);
    }
    await _client.from('recipes').insert({
      'id': r.id,
      'name': r.name,
      'image_url': imageUrl,
      'price': r.price,
      'description': r.description,
      'category': r.category,
      'available': r.available,
      'restaurant_id': uid,
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
    if (!_isAuthed) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (price != null) updates['price'] = price;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (updates.isNotEmpty) {
      await _client.from('recipes').update(updates).eq('id', id);
    }
  }

  @override
  Future<String> uploadImage(String recipeId, Uint8List bytes) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not logged in');
    if (bytes.length > AppConstants.maxImageSizeBytes) {
      throw Exception('Image too large. Maximum size is ${AppConstants.maxImageSizeBytes ~/ (1024 * 1024)}MB');
    }
    final path = '$uid/$recipeId.jpg';
    await _client.storage
        .from('recipe_images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('recipe_images').getPublicUrl(path);
  }

  Future<String> _compressAndUpload(String uid, String recipeId, String localPath) async {
    final file = File(localPath);
    if (!await file.exists()) return localPath;
    final bytes = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 75,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );
    if (bytes == null || bytes.isEmpty) return localPath;
    return uploadImage(recipeId, bytes);
  }

  @override
  Future<void> removeRecipe(String id) async {
    if (!_isAuthed) return;
    await _client.from('recipes').delete().eq('id', id);
  }

  @override
  Future<void> toggleRecipe(String id) async {
    if (!_isAuthed) return;
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
    if (!_isAuthed) return const Stream.empty();
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
      trackingCode: row['tracking_code'] as String? ?? '',
    );
  }

  @override
  Future<List<Order>> loadOrders() async {
    if (!_isAuthed) return [];
    final data = await _client
        .from('orders')
        .select()
        .order('created_at', ascending: false);
    return data.map(_mapOrder).toList();
  }

  @override
  Future<void> saveOrder(Order order) async {
    final uid = _userId;
    if (uid == null) return;
    final count = await _client
        .from('orders')
        .select('id')
        .eq('restaurant_id', uid)
        .count();
    if (count.count >= AppConstants.maxOrdersPerRestaurant) {
      throw Exception('Maximum ${AppConstants.maxOrdersPerRestaurant} orders reached. Please archive old orders.');
    }
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

    final trackingCode = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    await _client.from('orders').insert({
      'id': order.id,
      'table_number': order.tableNumber,
      'table_label': order.tableName,
      'status': order.status.name,
      'created_at': order.createdAt.millisecondsSinceEpoch,
      'notes': order.notes,
      'items_json': itemsJson,
      'tracking_code': trackingCode,
      'restaurant_id': uid,
    });
  }

  @override
  Future<void> changeOrderStatus(String id, OrderStatus status) async {
    if (!_isAuthed) return;
    await _client.from('orders').update({'status': status.name}).eq('id', id);
  }

  @override
  Future<void> deleteAllOrders() async {
    final uid = _userId;
    if (uid == null) return;
    await _client.from('orders').delete().eq('restaurant_id', uid);
  }

  @override
  Stream<List<Order>> watchOrders() {
    if (!_isAuthed) return const Stream.empty();
    final uid = _userId;
    if (uid == null) return const Stream.empty();
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('restaurant_id', uid)
        .map((data) => data.map(_mapOrder).toList());
  }

  // ── Settings ──────────────────────────────────────────────

  @override
  Future<Map<String, String>> loadSettings() async {
    if (!_isAuthed) return {};
    final data = await _client.from('app_settings').select();
    return {
      for (final row in data) row['key'] as String: row['value'] as String,
    };
  }

  @override
  Future<void> saveSetting(String key, String value) async {
    final uid = _userId;
    if (uid == null) return;
    await _client.from('app_settings').upsert({
      'key': key,
      'value': value,
      'restaurant_id': uid,
    }, onConflict: 'key, restaurant_id');
  }

  @override
  Stream<Map<String, String>> watchSettings() {
    if (!_isAuthed) return const Stream.empty();
    return _client
        .from('app_settings')
        .stream(primaryKey: ['key', 'restaurant_id'])
        .map(
          (data) => {
            for (final row in data)
              row['key'] as String: row['value'] as String,
          },
        );
  }
}
