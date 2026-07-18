import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/role.dart';

class OrderNotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel('kitchen_channel', 'Kitchen Notifications',
        description: 'New orders for kitchen', importance: Importance.high),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel('waiter_channel', 'Waiter Notifications',
        description: 'Served orders for waiter', importance: Importance.high),
    );
    _initialized = true;
  }

  Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  void checkOrderChanges(List<Order> previous, List<Order> current, Role currentRole) {
    if (!_initialized) return;
    final prevMap = {for (final o in previous) o.id: o};
    for (final order in current) {
      final prev = prevMap[order.id];
      if (prev == null) {
        if (order.status == OrderStatus.pending && currentRole == Role.kitchen) {
          _showKitchenNotification(order);
        }
        continue;
      }
      if (prev.status != order.status) {
        if (order.status == OrderStatus.served && currentRole == Role.waiter) {
          _showWaiterNotification(order);
        }
        if (order.status == OrderStatus.pending && currentRole == Role.kitchen) {
          _showKitchenNotification(order);
        }
      }
    }
  }

  void _showKitchenNotification(Order order) {
    _plugin.show(
      order.tableNumber,
      'New Order — Table ${order.tableNumber}',
      '${order.items.length} item${order.items.length > 1 ? 's' : ''} • ${order.totalPrice.toStringAsFixed(0)} IQD',
      const NotificationDetails(android: AndroidNotificationDetails(
        'kitchen_channel', 'Kitchen Notifications',
        channelDescription: 'New orders for kitchen',
        importance: Importance.high, priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      )),
    );
  }

  void _showWaiterNotification(Order order) {
    _plugin.show(
      order.tableNumber + 1000,
      'Table ${order.tableNumber} Ready',
      'Order served — ready to deliver',
      const NotificationDetails(android: AndroidNotificationDetails(
        'waiter_channel', 'Waiter Notifications',
        channelDescription: 'Served orders for waiter',
        importance: Importance.high, priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      )),
    );
  }
}
