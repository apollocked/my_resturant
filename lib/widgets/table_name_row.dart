import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/cubits/order_cubit.dart';

class TableNameRow extends StatefulWidget {
  final int tableNumber;
  const TableNameRow({super.key, required this.tableNumber});
  @override State<TableNameRow> createState() => _TableNameRowState();
}

class _TableNameRowState extends State<TableNameRow> {
  late TextEditingController _ctrl;
  bool _editing = false;

  @override void initState() { super.initState(); _ctrl = TextEditingController(text: context.read<OrderCubit>().state.getTableName(widget.tableNumber)); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<OrderCubit>().state.getTableName(widget.tableNumber);
    if (!_editing && _ctrl.text != name) _ctrl.text = name;
    return Card(child: ListTile(
      leading: const Icon(Icons.table_restaurant, color: AppTheme.primary),
      title: _editing
        ? TextField(controller: _ctrl, autofocus: true, decoration: const InputDecoration(isDense: true),
            onSubmitted: (v) { context.read<OrderCubit>().setTableName(widget.tableNumber, v); setState(() => _editing = false); })
        : Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: IconButton(icon: Icon(_editing ? Icons.check : Icons.edit, size: 18),
        onPressed: () { if (_editing) context.read<OrderCubit>().setTableName(widget.tableNumber, _ctrl.text); setState(() => _editing = !_editing); }),
    ));
  }
}
