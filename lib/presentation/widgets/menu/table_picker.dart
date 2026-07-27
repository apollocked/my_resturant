import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class TablePicker extends StatelessWidget {
  const TablePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<OrderCubit>().state;
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final avatarSize = screen == ScreenSize.desktop ? 140.0 : screen == ScreenSize.tablet ? 120.0 : 100.0;
    final iconSize = screen == ScreenSize.desktop ? 72.0 : screen == ScreenSize.tablet ? 60.0 : 48.0;
    final tableFontSize = screen == ScreenSize.desktop ? 32.0 : screen == ScreenSize.tablet ? 28.0 : 24.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(R.padding(context)),
          child: Column(children: [
            Flexible(
              child: SingleChildScrollView(child: Column(children: [
                SizedBox(height: R.hp(context, screen == ScreenSize.desktop ? 4 : 2)),
                Container(width: avatarSize, height: avatarSize,
                  decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                  child: Icon(Icons.table_restaurant, size: iconSize, color: AppColors.primary)),
                SizedBox(height: screen == ScreenSize.desktop ? R.hp(context, 5) : R.hp(context, 3)),
                Text('select_table', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: screen == ScreenSize.desktop ? R.fontXxl(context) : R.fontXl(context), fontWeight: FontWeight.w800, color: cs.onSurface)),
                SizedBox(height: screen == ScreenSize.desktop ? R.hp(context, 4) : R.hp(context, 3)),
                GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: R.tableGridColumns(context), crossAxisSpacing: R.gridSpacing(context), mainAxisSpacing: R.gridSpacing(context), childAspectRatio: 1),
                  itemCount: s.tableCount,
                  itemBuilder: (context, i) {
                    final n = i + 1;
                    final locked = s.reservedTables.contains(n);
                    return Material(
                      color: locked ? cs.outline : AppColors.primary,
                      borderRadius: BorderRadius.circular(screen == ScreenSize.desktop ? 18 : 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(screen == ScreenSize.desktop ? 18 : 14),
                        onTap: locked ? null : () => context.read<OrderCubit>().setSelectedTable(n),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          if (locked) ...[
                            Icon(Icons.lock, color: cs.surface, size: screen == ScreenSize.desktop ? 28 : 20),
                            const SizedBox(height: 2),
                            Text('Table $n', style: TextStyle(color: cs.surface, fontSize: screen == ScreenSize.desktop ? 16 : 13, fontWeight: FontWeight.w600)),
                          ] else ...[
                            Text('$n', style: TextStyle(color: cs.surface, fontSize: tableFontSize, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text('Table', style: TextStyle(color: cs.surface.withValues(alpha: 0.7), fontSize: screen == ScreenSize.desktop ? 14 : 11)),
                          ],
                        ]),
                      ),
                    );
                  },
                ),
              ])),
            ),
          ]),
        ),
      ),
    );
  }
}
