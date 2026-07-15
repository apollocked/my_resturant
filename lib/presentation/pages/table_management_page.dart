import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/shared/table_name_row.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});
  @override State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  Widget _countBtn(IconData icon, ColorScheme cs, VoidCallback onTap) {
    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(width: 44, height: 44, alignment: Alignment.center,
          child: Icon(icon, size: 22, color: AppColors.primary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t('table_mgmt_title'))),
      body: SafeArea(child: Directionality(textDirection: TextDirection.rtl, child: ListView(padding: EdgeInsets.all(R.padding(context)), children: [
        Text(t('table_count'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: R.fontMd(context), color: cs.onSurface)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _countBtn(Icons.remove, cs, () {
              if (state.tableCount > 1) context.read<OrderCubit>().setTableCount(state.tableCount - 1);
            }),
            Container(
              width: 80, alignment: Alignment.center,
              child: Text('${state.tableCount}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: R.isTablet(context) ? 32 : 28, color: cs.onSurface)),
            ),
            _countBtn(Icons.add, cs, () {
              if (state.tableCount < 35) context.read<OrderCubit>().setTableCount(state.tableCount + 1);
            }),
          ]),
        ),
        const SizedBox(height: 20),
        Text(t('table_names'), style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 12),
        ...state.tableNumbers.map((n) => TableNameRow(key: ValueKey(n), tableNumber: n)),
      ]))),
    );
  }
}
