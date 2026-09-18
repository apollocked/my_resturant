import 'dart:ui';

import 'package:my_resturant/features/orders/data/order_notification_service.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';

class OrderNotifier {
  final OrderNotificationService _service = OrderNotificationService();
  Role? _currentRole;
  Locale _currentLocale = const Locale('ku');
  List<Order> _previous = [];
  Map<int, DateTime?> _requests = {};

  void init() {
    _service.init(_currentLocale);
  }

  void setRole(Role? role) => _currentRole = role;

  void setLocale(Locale locale) {
    _currentLocale = locale;
    _service.updateChannels(locale);
  }

  void seedOrders(List<Order> orders) => _previous = List.from(orders);

  /// Baseline for cleaning requests so pre-existing requests never fire a
  /// notification again after a restart or initial load.
  void seedCleaningRequests(Map<int, DateTime> requests) =>
      _requests = Map<int, DateTime?>.from(requests);

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

  /// Fires a "table needs cleaning" notification on kitchen devices when a
  /// waiter (re)flags a served table. Newer timestamps re-notify so repeated
  /// requests act as a nudge. Removals are ignored — clearing a table must
  /// never surface a cleaning notification.
  void onCleaningRequestsChanged(Map<int, DateTime> next) {
    final newly = next.entries
        .where((e) => e.value != _requests[e.key])
        .map((e) => e.key)
        .toList();
    _requests = Map<int, DateTime?>.from(next);
    if (_currentRole != Role.kitchen) return;
    for (final t in newly) {
      _service.showCleaningRequest(t, _currentLocale);
    }
  }
}
