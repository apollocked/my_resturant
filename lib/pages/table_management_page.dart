import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/widgets/table_name_row.dart';

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
        ...state.tableNumbers.map((n) => TableNameRow(key: ValueKey(n), tableNumber: n)),
      ])),
    );
  }
}
