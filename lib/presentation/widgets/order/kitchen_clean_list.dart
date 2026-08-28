import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/shared/pressable_scale.dart';
import 'package:my_resturant/shared/empty_state.dart';

class KitchenCleanList extends StatelessWidget {
  final List<int> tableList;
  final OrderCubit cubit;
  final String Function(String) t;
  final ColorScheme cs;
  const KitchenCleanList({
    super.key,
    required this.tableList,
    required this.cubit,
    required this.t,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    if (tableList.isEmpty) {
      return EmptyState(
        icon: Icons.cleaning_services,
        title: t('no_cleared_tables'),
        subtitle: t('no_cleared_tables_subtitle'),
        color: AppColors.success,
      );
    }
    final isGrid = !R.isPhone(context);
    final tiles = tableList
        .map((n) => _CleanTile(n: n, t: t, cs: cs, cubit: cubit))
        .toList();
    return RefreshIndicator(
      onRefresh: () async => cubit.refresh(),
      child: isGrid
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                R.padding(context),
                8,
                R.padding(context),
                100,
              ),
              child: Wrap(
                spacing: R.gridSpacing(context),
                runSpacing: R.gridSpacing(context),
                children: [
                  for (final tile in tiles)
                    SizedBox(
                      width: R.orderCardWidth(context, maxExtent: 360),
                      child: tile,
                    ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                R.padding(context),
                8,
                R.padding(context),
                100,
              ),
              itemCount: tableList.length,
              itemBuilder: (context, index) => tiles[index],
            ),
    );
  }
}

class _CleanTile extends StatelessWidget {
  final int n;
  final String Function(String) t;
  final ColorScheme cs;
  final OrderCubit cubit;
  const _CleanTile({
    required this.n,
    required this.t,
    required this.cs,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final tableName = cubit.state.getTableName(n);
    final title = '${t('table')} $n'
        '${tableName != '${t('table')} $n' ? ' \u2014 $tableName' : ''}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.cleaning_services,
            color: AppColors.success,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: R.fontMd(context),
          ),
        ),
        subtitle: Text(
          t('clear_table'),
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: R.fontSm(context)),
        ),
        trailing: PressableScale(
          onTap: () => cubit.clearTable(n),
          child: FilledButton.icon(
            icon: const Icon(Icons.check, size: 18),
            label: Text(
              t('clear_table'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              disabledBackgroundColor: AppColors.success,
              disabledForegroundColor: cs.onPrimary,
              foregroundColor: cs.onPrimary,
            ),
            onPressed: null,
          ),
        ),
      ),
    );
  }
}
