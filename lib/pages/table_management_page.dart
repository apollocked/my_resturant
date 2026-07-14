import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/cubits/order_cubit.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});
  @override State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    return Scaffold(
      appBar: AppBar(title: const Text('بەڕێوەبردنی مێزەکان')),
      body: Directionality(textDirection: TextDirection.rtl, child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('ژمارەی مێزەکان', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Slider(value: state.tableCount.toDouble(), min: 1, max: 20, divisions: 19,
            label: '${state.tableCount}',
            onChanged: (v) => context.read<OrderCubit>().setTableCount(v.round()))),
          Text('${state.tableCount}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.primary)),
        ]),
        const SizedBox(height: 20),
        const Text('ناوەکانی مێزەکان', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        ...state.tableNumbers.map((n) => _TableRow(key: ValueKey(n), n: n)),
      ])),
    );
  }
}

class _TableRow extends StatefulWidget {
  final int n;
  const _TableRow({super.key, required this.n});
  @override State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  late TextEditingController _ctrl;
  bool _editing = false;

  @override void initState() {
    super.initState();
    _ctrl = TextEditingController(text: context.read<OrderCubit>().state.getTableName(widget.n));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<OrderCubit>().state.getTableName(widget.n);
    if (!_editing && _ctrl.text != name) _ctrl.text = name;
    return Card(child: ListTile(
      leading: const Icon(Icons.table_restaurant, color: AppTheme.primary),
      title: _editing
        ? TextField(controller: _ctrl, autofocus: true, decoration: const InputDecoration(isDense: true),
            onSubmitted: (v) { context.read<OrderCubit>().setTableName(widget.n, v); setState(() => _editing = false); })
        : Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: IconButton(
        icon: Icon(_editing ? Icons.check : Icons.edit, size: 18),
        onPressed: () {
          if (_editing) context.read<OrderCubit>().setTableName(widget.n, _ctrl.text);
          setState(() => _editing = !_editing);
        }),
    ));
  }
}
