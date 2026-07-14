import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/cubits/settings_cubit.dart';
import 'package:my_resturant/l10n/tr.dart';
import 'package:my_resturant/widgets/app_image.dart';

class AvailabilityPage extends StatelessWidget {
  const AvailabilityPage({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<OrderCubit>();
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final recipes = cubit.state.recipes;
    return Scaffold(
      appBar: AppBar(title: Text(t('availability_title'))),
      body: recipes.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 100, height: 100, decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
              child: const Icon(Icons.restaurant_menu, size: 44, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            Text(t('no_food_found'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ]))
        : Directionality(textDirection: TextDirection.rtl, child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final r = recipes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(r.imageUrl, width: 48, height: 48),
                ),
                title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                subtitle: Text('${r.price.toInt()} ${t('currency_suffix')}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                trailing: Switch(
                  value: r.available,
                  onChanged: (_) => cubit.toggleAvailability(r.id),
                  activeTrackColor: AppTheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
