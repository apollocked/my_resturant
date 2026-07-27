import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class KitchenCleanList extends StatelessWidget {
  final List<int> tableList;
  final OrderCubit cubit;
  final String Function(String) t;
  final ColorScheme cs;
  const KitchenCleanList({super.key, required this.tableList, required this.cubit, required this.t, required this.cs});

  @override
  Widget build(BuildContext context) {
    final orderState = cubit.state;
    if (tableList.isEmpty) {
      final isDesktop = R.isDesktop(context);
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: R.hp(context, isDesktop ? 18 : 22), height: R.hp(context, isDesktop ? 18 : 22),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
          child: Icon(Icons.cleaning_services, size: isDesktop ? 64 : R.isTablet(context) ? 52 : 44, color: cs.onSurfaceVariant)),
        const SizedBox(height: 20),
        Text(t('no_cleared_tables'), style: TextStyle(fontSize: R.fontLg(context), fontWeight: FontWeight.w600, color: cs.onSurface)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: () async => cubit.refresh(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(R.padding(context), 8, R.padding(context), 100),
        itemCount: tableList.length,
        itemBuilder: (context, index) {
          final n = tableList[index];
          final tableName = orderState.getTableName(n);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.cleaning_services, color: Colors.green, size: 22),
              ),
              title: Text('${t('table')} $n${tableName != '${t('table')} $n' ? ' — $tableName' : ''}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              subtitle: Text(t('clear_table'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
              trailing: PressableScale(
                onTap: () => cubit.clearTable(n),
                child: FilledButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(t('clear_table'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green, disabledBackgroundColor: Colors.green, disabledForegroundColor: Colors.white, foregroundColor: Colors.white),
                  onPressed: null,
                )),
            ),
          );
        },
      ),
    );
  }
}
