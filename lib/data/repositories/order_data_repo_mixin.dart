import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:my_resturant/core/constants/app_constants.dart';
import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/data/repositories/supabase_repo_base.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

mixin OrderDataRepoMixin on SupabaseDataRepoBase {
  Future<List<Order>> loadOrders() => safeCall(() async {
    if (!isAuthed) return [];
    final uid = userId;
    if (uid == null) return [];
    final data = await client
        .from('orders')
        .select()
        .eq('restaurant_id', uid)
        .order('created_at', ascending: false);
    return data.map(mapOrder).toList();
  });

  Future<void> saveOrder(Order order) => safeCall(() async {
    final uid = userId;
    if (uid == null) return;
    final count = await client
        .from('orders')
        .select('id')
        .eq('restaurant_id', uid)
        .count();
    if (count.count >= AppConstants.maxOrdersPerRestaurant) {
      throw Exception(
        'Maximum ${AppConstants.maxOrdersPerRestaurant} orders reached. Please archive old orders.',
      );
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
    final trackingCode =
        'ORD-${DateTime.now().millisecondsSinceEpoch}-${Random.secure().nextInt(10000)}';
    await client.from('orders').insert({
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
  });

  Future<void> changeOrderStatus(String id, OrderStatus status) =>
      safeCall(() async {
        final uid = userId;
        if (!isAuthed || uid == null) return;
        await client
            .from('orders')
            .update({'status': status.name})
            .eq('id', id)
            .eq('restaurant_id', uid);
      });

  Future<void> appendItemsToOrder(String orderId, List<CartItem> items) =>
      safeCall(() async {
        final uid = userId;
        if (!isAuthed || uid == null || items.isEmpty) return;
        await client.rpc(
          'append_order_items',
          params: {
            'p_order_id': orderId,
            'p_items': items.map((item) {
              return {
                'recipe_id': item.recipe.id,
                'recipe_name': item.recipe.name,
                'recipe_price': item.recipe.price,
                'recipe_image_url': item.recipe.imageUrl,
                'quantity': item.quantity,
                'notes': item.notes,
              };
            }).toList(),
          },
        );
      });

  Future<void> deleteAllOrders() => safeCall(() async {
    final uid = userId;
    if (uid == null) return;
    await client.from('orders').delete().eq('restaurant_id', uid);
  });

  Stream<List<Order>> watchOrders() {
    if (!isAuthed) return const Stream.empty();
    final uid = userId;
    if (uid == null) return const Stream.empty();
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('restaurant_id', uid)
        .map((data) => data.map(mapOrder).toList());
  }
}
