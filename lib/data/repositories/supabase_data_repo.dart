import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
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
    id: row['id'] as String? ?? '',
    name: row['name'] as String? ?? '',
    imageUrl: (row['image_url'] as String?) ?? '',
    price: (row['price'] as num?)?.toDouble() ?? 0,
    description: (row['description'] as String?) ?? '',
    category: (row['category'] as String?) ?? '',
    available: (row['available'] as bool?) ?? true,
  );

  @override
  Future<List<Recipe>> loadRecipes() async {
    if (!_isAuthed) return [];
    final uid = _userId;
    if (uid == null) return [];
    final data = await _client
        .from('recipes')
        .select()
        .eq('restaurant_id', uid);
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
    final uid = _userId;
    if (!_isAuthed || uid == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (price != null) updates['price'] = price;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (updates.isNotEmpty) {
      await _client.from('recipes').update(updates).eq('id', id).eq('restaurant_id', uid);
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
    final uid = _userId;
    if (!_isAuthed || uid == null) return;
    await _client.from('recipes').delete().eq('id', id).eq('restaurant_id', uid);
  }

  @override
  Future<void> toggleRecipe(String id) async {
    final uid = _userId;
    if (!_isAuthed || uid == null) return;
    try {
      final data = await _client
          .from('recipes')
          .select('available')
          .eq('id', id)
          .eq('restaurant_id', uid)
          .maybeSingle();
      if (data == null) return;
      await _client
          .from('recipes')
          .update({'available': !(data['available'] as bool? ?? false)})
          .eq('id', id)
          .eq('restaurant_id', uid);
    } catch (e) {
      debugPrint('SupabaseDataRepo.toggleRecipe error: $e');
    }
  }

  @override
  Stream<List<Recipe>> watchRecipes() {
    if (!_isAuthed) return const Stream.empty();
    final uid = _userId;
    if (uid == null) return const Stream.empty();
    return _client
        .from('recipes')
        .stream(primaryKey: ['id'])
        .eq('restaurant_id', uid)
        .map((data) => data.map(_mapRecipe).toList());
  }

  // ── Orders ────────────────────────────────────────────────

  Order _mapOrder(Map<String, dynamic> row) {
    List<CartItem> items = [];
    try {
      final rawJson = row['items_json'];
      final List<dynamic> raw;
      if (rawJson is List) {
        raw = rawJson;
      } else if (rawJson is String) {
        raw = jsonDecode(rawJson.isEmpty ? '[]' : rawJson) as List;
      } else {
        raw = const [];
      }
      items = raw.map((item) {
        return CartItem(
          recipe: Recipe(
            id: item['recipe_id'] as String? ?? '',
            name: item['recipe_name'] as String? ?? '',
            imageUrl: item['recipe_image_url'] as String? ?? '',
            price: (item['recipe_price'] as num?)?.toDouble() ?? 0,
            description: '',
            category: '',
            available: true,
          ),
          quantity: (item['quantity'] as num?)?.toInt() ?? 1,
          notes: item['notes'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('SupabaseDataRepo._mapOrder: corrupt items_json, falling back to empty: $e');
    }

    return Order(
      id: row['id'] as String? ?? '',
      tableNumber: (row['table_number'] as num?)?.toInt() ?? 0,
      tableName: row['table_label'] as String?,
      items: items,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: _parseCreatedAt(row['created_at']),
      notes: row['notes'] as String? ?? '',
      trackingCode: row['tracking_code'] as String? ?? '',
    );
  }

  DateTime _parseCreatedAt(dynamic v) {
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    if (v is String) {
      final epoch = int.tryParse(v);
      if (epoch != null) return DateTime.fromMillisecondsSinceEpoch(epoch);
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Future<List<Order>> loadOrders() async {
    if (!_isAuthed) return [];
    final uid = _userId;
    if (uid == null) return [];
    final data = await _client
        .from('orders')
        .select()
        .eq('restaurant_id', uid)
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

    final trackingCode = 'ORD-${DateTime.now().millisecondsSinceEpoch}-${Random.secure().nextInt(10000)}';

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
    final uid = _userId;
    if (!_isAuthed || uid == null) return;
    await _client.from('orders').update({'status': status.name}).eq('id', id).eq('restaurant_id', uid);
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
    final uid = _userId;
    if (uid == null) return {};
    final data = await _client
        .from('app_settings')
        .select()
        .eq('restaurant_id', uid);
    return {
      for (final row in data)
        (row['key'] as String? ?? ''): (row['value'] as String? ?? ''),
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
    final uid = _userId;
    if (uid == null) return const Stream.empty();
    return _client
        .from('app_settings')
        .stream(primaryKey: ['key', 'restaurant_id'])
        .eq('restaurant_id', uid)
        .map(
          (data) => {
            for (final row in data)
              (row['key'] as String? ?? ''): (row['value'] as String? ?? ''),
          },
        );
  }

  // ── Categories ────────────────────────────────────────────

  Map<String, String> _mapCategory(Map<String, dynamic> row) => {
    'key': (row['key'] as String?) ?? '',
    'name': (row['name'] as String?) ?? '',
    'icon': (row['icon'] as String?) ?? '',
  };

  @override
  Future<List<Map<String, String>>> loadCategories() async {
    if (!_isAuthed) return [];
    final uid = _userId;
    if (uid == null) return [];
    final data = await _client
        .from('categories')
        .select()
        .eq('restaurant_id', uid);
    return data.map(_mapCategory).toList();
  }

  @override
  Future<void> addCategory(String key, String name, String icon) async {
    final uid = _userId;
    if (uid == null) return;
    if (key.isEmpty || key.length > 32) {
      throw Exception('Invalid category key');
    }
    final count = await _client
        .from('categories')
        .select('key')
        .eq('restaurant_id', uid)
        .count();
    if (count.count >= AppConstants.maxCategoriesPerRestaurant) {
      throw Exception('Maximum ${AppConstants.maxCategoriesPerRestaurant} categories reached');
    }
    await _client.from('categories').upsert({
      'key': key,
      'name': name,
      'icon': icon,
      'restaurant_id': uid,
    }, onConflict: 'key, restaurant_id');
  }

  @override
  Future<void> removeCategory(String key) async {
    final uid = _userId;
    if (uid == null) return;
    await _client.from('categories').delete()
        .eq('key', key)
        .eq('restaurant_id', uid);
  }

  @override
  Stream<List<Map<String, String>>> watchCategories() {
    if (!_isAuthed) return const Stream.empty();
    final uid = _userId;
    if (uid == null) return const Stream.empty();
    return _client
        .from('categories')
        .stream(primaryKey: ['key', 'restaurant_id'])
        .eq('restaurant_id', uid)
        .map((data) => data.map(_mapCategory).toList());
  }
}
