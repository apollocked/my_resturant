import 'package:my_resturant/models/cart_item.dart';
import 'package:my_resturant/models/order_model.dart';

class OrderState {
  final List<CartItem> cart;
  final List<Order> orders;
  final int selectedTable;
  final int tableCount;
  final Map<int, String> tableNames;

  const OrderState({
    this.cart = const [],
    this.orders = const [],
    this.selectedTable = 0,
    this.tableCount = 10,
    this.tableNames = const {},
  });

  int get cartCount => cart.fold(0, (s, i) => s + i.quantity);
  double get cartTotal => cart.fold(0.0, (s, i) => s + i.totalPrice);
  int get totalOrders => orders.length;
  double get totalRevenue => orders.fold(0.0, (s, o) => s + o.totalPrice);
  List<int> get tableNumbers => List.generate(tableCount, (i) => i + 1);
  Set<int> get reservedTables => orders.where((o) => o.status != OrderStatus.served).map((o) => o.tableNumber).toSet();

  String getTableName(int n) => tableNames[n] ?? 'مێز $n';
  int getQuantity(String id) => cart.where((c) => c.recipe.id == id).firstOrNull?.quantity ?? 0;
  String getNotes(String id) => cart.where((c) => c.recipe.id == id).firstOrNull?.notes ?? '';

  Map<String, int> get dishOrderCounts {
    final c = <String, int>{};
    for (final o in orders) {
      for (final i in o.items) {
        c[i.recipe.name] = (c[i.recipe.name] ?? 0) + i.quantity;
      }
    }
    final entries = c.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }

  String? get mostOrderedDish => dishOrderCounts.entries.firstOrNull?.key;
  int get mostOrderedDishCount => dishOrderCounts.entries.firstOrNull?.value ?? 0;

  List<Order> ordersByDate(DateTime d) => orders.where((o) =>
    o.createdAt.year == d.year && o.createdAt.month == d.month && o.createdAt.day == d.day).toList();

  OrderState copyWith({List<CartItem>? cart, List<Order>? orders, int? selectedTable, int? tableCount, Map<int, String>? tableNames}) =>
    OrderState(cart: cart ?? this.cart, orders: orders ?? this.orders,
      selectedTable: selectedTable ?? this.selectedTable, tableCount: tableCount ?? this.tableCount,
      tableNames: tableNames ?? this.tableNames);
}
