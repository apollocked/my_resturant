import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/shared/table_name_row.dart';
import 'package:my_resturant/presentation/widgets/shared/shimmer_skeletons.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});
  @override State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  Widget _countBtn(IconData icon, ColorScheme cs, VoidCallback onTap, bool isDesktop) {
    final size = isDesktop ? 52.0 : 44.0;
    return PressableScale(
      onTap: onTap,
      child: Material(
        color: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isDesktop ? 16 : 12)),
        elevation: 0,
        child: Container(width: size, height: size, alignment: Alignment.center,
          child: Icon(icon, size: isDesktop ? 26 : 22, color: AppColors.primary)),
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
      body: SafeArea(child: Directionality(textDirection: TextDirection.rtl, child: ListView(padding: EdgeInsets.all(R.padding(context)), children: [
        if (state.isLoading) ...[
          const ShimmerBox(width: 120, height: 18, radius: 6),
          const SizedBox(height: 10),
          const ShimmerBox(width: double.infinity, height: 80, radius: 14),
          const SizedBox(height: 20),
          const ShimmerBox(width: 120, height: 18, radius: 6),
          const SizedBox(height: 12),
          ...List.generate(5, (_) => const Padding(padding: EdgeInsets.only(bottom: 8), child: ShimmerListTile())),
        ] else ...[
        Text(t('table_count'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: R.fontMd(context), color: cs.onSurface)),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: isDesktop ? 16 : 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _countBtn(Icons.remove, cs, () {
              if (state.tableCount > 1) context.read<OrderCubit>().setTableCount(state.tableCount - 1);
            }, isDesktop),
            Container(
              width: isDesktop ? 100 : 80, alignment: Alignment.center,
              child: Text('${state.tableCount}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: isDesktop ? 40 : R.isTablet(context) ? 32 : 28, color: cs.onSurface)),
            ),
            _countBtn(Icons.add, cs, () {
              if (state.tableCount < 35) context.read<OrderCubit>().setTableCount(state.tableCount + 1);
            }, isDesktop),
          ]),
        ),
        const SizedBox(height: 20),
        Text(t('table_names'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: R.fontMd(context), color: cs.onSurface)),
        const SizedBox(height: 12),
        if (state.tableNumbers.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(children: [
              Container(width: R.hp(context, 16), height: R.hp(context, 16),
                decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
                child: Icon(Icons.table_restaurant, size: isDesktop ? 48 : 36, color: cs.onSurfaceVariant)),
              const SizedBox(height: 16),
              Text(t('no_tables'), style: TextStyle(fontSize: R.fontLg(context), fontWeight: FontWeight.w600, color: cs.onSurface)),
            ]),
          ))
        else
          ...state.tableNumbers.map((n) => TableNameRow(key: ValueKey(n), tableNumber: n)),
        ],
      ]))),
    );
  }
}
