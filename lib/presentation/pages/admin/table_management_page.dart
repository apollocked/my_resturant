import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/table_count_stepper.dart';
import 'package:my_resturant/presentation/widgets/admin/table_manage_skeleton.dart';
import 'package:my_resturant/shared/empty_state.dart';
import 'package:my_resturant/shared/table_name_row.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});
  @override
  State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  Widget _sectionTitle(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: R.fontXl(context),
        color: cs.onSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    return Scaffold(
      appBar: AppBar(title: Text(t('table_mgmt_title'))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(R.padding(context)),
          children: [
            if (state.isLoading)
              const TableManageSkeleton()
            else ...[
              _sectionTitle(t('table_count'), cs),
              const SizedBox(height: 10),
              TableCountStepper(
                count: state.tableCount,
                isDesktop: isDesktop,
                cs: cs,
                onDecrement: () {
                  if (state.tableCount > 1) {
                    context.read<OrderCubit>().setTableCount(
                      state.tableCount - 1,
                    );
                  }
                },
                onIncrement: () {
                  if (state.tableCount < 35) {
                    context.read<OrderCubit>().setTableCount(
                      state.tableCount + 1,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _sectionTitle(t('table_names'), cs),
              const SizedBox(height: 12),
              if (state.tableNumbers.isEmpty)
                EmptyState(
                  icon: Icons.table_restaurant,
                  title: t('no_tables'),
                  subtitle: t('no_tables_subtitle'),
                )
              else if (isDesktop || R.isTablet(context))
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: R.tableGridColumns(context),
                    childAspectRatio: 1.2,
                    crossAxisSpacing: R.gridSpacing(context),
                    mainAxisSpacing: R.gridSpacing(context),
                  ),
                  children: state.tableNumbers
                      .map(
                        (n) => TableNameRow(key: ValueKey(n), tableNumber: n),
                      )
                      .toList(),
                )
              else
                ...state.tableNumbers.map(
                  (n) => TableNameRow(key: ValueKey(n), tableNumber: n),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
