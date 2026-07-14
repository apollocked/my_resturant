import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/table_name_row.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});
  @override State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    return Scaffold(
      appBar: AppBar(title: Text(t('table_mgmt_title'))),
      body: Directionality(textDirection: TextDirection.rtl, child: ListView(padding: const EdgeInsets.all(20), children: [
        Text(t('table_count'), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Slider(value: state.tableCount.toDouble(), min: 1, max: 20, divisions: 19,
            label: '${state.tableCount}',
            onChanged: (v) => context.read<OrderCubit>().setTableCount(v.round()))),
          Text('${state.tableCount}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary)),
        ]),
        const SizedBox(height: 20),
        Text(t('table_names'), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...state.tableNumbers.map((n) => TableNameRow(key: ValueKey(n), tableNumber: n)),
      ])),
    );
  }
}
