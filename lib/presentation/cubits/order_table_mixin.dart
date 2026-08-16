import 'package:my_resturant/presentation/cubits/order_cubit_base.dart';

mixin OrderTableMixin on OrderCubitBase {
  void setTableCount(int v) {
    final names = Map<int, String>.from(state.tableNames);
    names.removeWhere((k, _) => k > v);
    emit(state.copyWith(tableCount: v.clamp(1, 35), tableNames: names));
    repo.saveSetting('tableCount', v.clamp(1, 35).toString());
  }

  void setTableName(int n, String name) {
    final names = Map<int, String>.from(state.tableNames);
    if (name.trim().isEmpty) {
      names.remove(n);
    } else {
      names[n] = name.trim();
    }
    emit(state.copyWith(tableNames: names));
    repo.saveSetting('tableName_$n', name.trim());
  }

  void clearTable(int tableNumber) {
    final cleared = Set<int>.from(state.clearedTables)..add(tableNumber);
    repo.saveSetting('cleared_$tableNumber', 'true');
    emit(state.copyWith(clearedTables: cleared));
  }

  void unclearTable(int tableNumber) {
    final cleared = Set<int>.from(state.clearedTables)..remove(tableNumber);
    repo.saveSetting('cleared_$tableNumber', 'false');
    emit(state.copyWith(clearedTables: cleared));
  }
}
