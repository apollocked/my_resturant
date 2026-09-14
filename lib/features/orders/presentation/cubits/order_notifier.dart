import 'dart:ui';

import 'package:my_resturant/core/notifications/order_notification_service.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/role.dart';

class OrderNotifier {
  final OrderNotificationService _service = OrderNotificationService();
  Role? _currentRole;
  Locale _currentLocale = const Locale('ku');
  List<Order> _previous = [];

  void init() {
    _service.init(_currentLocale);
  }

  void setRole(Role? role) => _currentRole = role;

  void setLocale(Locale locale) {
    _currentLocale = locale;
    _service.updateChannels(locale);
  }

  void seedOrders(List<Order> orders) => _previous = List.from(orders);

  void onOrdersChanged(List<Order> next) {
    if (_currentRole != null) {
      _service.checkOrderChanges(
        _previous,
        next,
        _currentRole!,
        _currentLocale,
      );
    }
    _previous = List.from(next);
  }
}
