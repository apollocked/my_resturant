import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/menu/table_picker_header.dart';
import 'package:my_resturant/presentation/widgets/menu/table_picker_tile.dart';

class TablePicker extends StatelessWidget {
  const TablePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<OrderCubit>().state;
    final cs = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final isDesktop = R.isDesktop(context);
    final avatarSize = isDesktop
        ? 140.0
        : R.isTablet(context)
        ? 120.0
        : 100.0;
    final iconSize = isDesktop
        ? 72.0
        : R.isTablet(context)
        ? 60.0
        : 48.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(R.padding(context)),
          child: Column(
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TablePickerHeader(
                        cs: cs,
                        isDesktop: isDesktop,
                        avatarSize: avatarSize,
                        iconSize: iconSize,
                        t: t,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: R.tableGridColumns(context),
                          crossAxisSpacing: R.gridSpacing(context),
                          mainAxisSpacing: R.gridSpacing(context),
                          childAspectRatio: 1,
                        ),
                        itemCount: s.tableCount,
                        itemBuilder: (context, i) {
                          final n = i + 1;
                          return TablePickerTile(
                            n: n,
                            locked: s.reservedTables.contains(n),
                            cs: cs,
                            isDesktop: isDesktop,
                            t: t,
                            onTap: () =>
                                context.read<OrderCubit>().setSelectedTable(n),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
