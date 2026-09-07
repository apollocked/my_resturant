import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:my_resturant/core/constants/app_constants.dart';
import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDataRepoBase {
  SupabaseClient get client => Supabase.instance.client;
  bool get isAuthed => client.auth.currentSession != null;
  String? get userId => client.auth.currentUser?.id;

  Recipe mapRecipe(Map<String, dynamic> row) => Recipe(
    id: row['id'] as String? ?? '',
    name: row['name'] as String? ?? '',
    imageUrl: (row['image_url'] as String?) ?? '',
    price: (row['price'] as num?)?.toDouble() ?? 0,
    description: (row['description'] as String?) ?? '',
    category: (row['category'] as String?) ?? '',
    available: (row['available'] as bool?) ?? true,
  );

  Order mapOrder(Map<String, dynamic> row) {
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
      debugPrint(
        'SupabaseDataRepo.mapOrder: corrupt items_json, falling back to empty: $e',
      );
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
      createdAt: parseCreatedAt(row['created_at']),
      notes: row['notes'] as String? ?? '',
      trackingCode: row['tracking_code'] as String? ?? '',
    );
  }

  DateTime parseCreatedAt(dynamic v) {
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    if (v is String) {
      final epoch = int.tryParse(v);
      if (epoch != null) return DateTime.fromMillisecondsSinceEpoch(epoch);
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Map<String, String> mapCategory(Map<String, dynamic> row) => {
    'key': (row['key'] as String?) ?? '',
    'name': (row['name'] as String?) ?? '',
    'icon': (row['icon'] as String?) ?? '',
  };

  Future<String> uploadImage(String recipeId, Uint8List bytes) => safeCall(() async {
    final uid = userId;
    if (uid == null) throw Exception('Not logged in');
    if (bytes.length > AppConstants.maxImageSizeBytes) {
      throw Exception(
        'Image too large. Maximum size is ${AppConstants.maxImageSizeBytes ~/ (1024 * 1024)}MB',
      );
    }
    final path = '$uid/$recipeId.jpg';
    await client.storage
        .from('recipe_images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from('recipe_images').getPublicUrl(path);
  });

  Future<String> compressAndUpload(
    String uid,
    String recipeId,
    String localPath,
  ) => safeCall(() async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw Exception('Image file not found: $localPath');
    }
    final bytes = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 75,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Failed to compress image');
    }
    return uploadImage(recipeId, bytes);
  });
}
