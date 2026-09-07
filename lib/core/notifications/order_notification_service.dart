import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/role.dart';

class OrderNotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init(Locale locale) async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    await _createChannels(locale);
    _initialized = true;
  }

  Future<void> updateChannels(Locale locale) async {
    if (!_initialized) return;
    await _createChannels(locale);
  }

  Future<void> _createChannels(Locale locale) async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      AndroidNotificationChannel('kitchen_channel',
        _t('notif_channel_kitchen_name', locale),
        description: _t('notif_channel_kitchen_desc', locale),
        importance: Importance.high),
    );
    await android?.createNotificationChannel(
      AndroidNotificationChannel('waiter_channel',
        _t('notif_channel_waiter_name', locale),
        description: _t('notif_channel_waiter_desc', locale),
        importance: Importance.high),
    );
  }

  Future<bool?> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return android?.requestNotificationsPermission();
  }

  Future<bool> areNotificationsEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? true;
  }

  void checkOrderChanges(List<Order> previous, List<Order> current, Role currentRole, Locale locale) {
    if (!_initialized) return;
    final prevMap = {for (final o in previous) o.id: o};
    for (final order in current) {
      final prev = prevMap[order.id];
      if (prev == null) {
        if (order.status == OrderStatus.pending && currentRole == Role.kitchen) {
          _showKitchenNotification(order, locale);
        }
        continue;
      }
      if (prev.status != order.status) {
        if (order.status == OrderStatus.served && currentRole == Role.waiter) {
          _showWaiterNotification(order, locale);
        }
        if (order.status == OrderStatus.pending && currentRole == Role.kitchen) {
          _showKitchenNotification(order, locale);
        }
      }
    }
  }

  String _t(String key, Locale locale, [Map<String, String>? params]) {
    var value = Tr.get(key, locale);
    if (params != null) {
      for (final e in params.entries) {
        value = value.replaceAll('{${e.key}}', e.value);
      }
    }
    return value;
  }

  void _showKitchenNotification(Order order, Locale locale) {
    final title = _t('notif_new_order', locale, {'table': '${order.tableNumber}'});
    final body = _t('notif_items_count', locale, {
      'count': '${order.items.length}',
      'price': order.totalPrice.toStringAsFixed(0),
    });
    _plugin.show(
      order.id.hashCode,
      title,
      body,
      NotificationDetails(android: AndroidNotificationDetails(
        'kitchen_channel', _t('notif_channel_kitchen_name', locale),
        channelDescription: _t('notif_channel_kitchen_desc', locale),
        importance: Importance.high, priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      )),
    );
  }

  void _showWaiterNotification(Order order, Locale locale) {
    final title = _t('notif_table_ready', locale, {'table': '${order.tableNumber}'});
    final body = _t('notif_order_served', locale);
    _plugin.show(
      order.id.hashCode,
      title,
      body,
      NotificationDetails(android: AndroidNotificationDetails(
        'waiter_channel', _t('notif_channel_waiter_name', locale),
        channelDescription: _t('notif_channel_waiter_desc', locale),
        importance: Importance.high, priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      )),
    );
  }
}
