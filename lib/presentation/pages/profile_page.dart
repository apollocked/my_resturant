import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/profile/action_buttons_row.dart';
import 'package:my_resturant/presentation/widgets/profile/settings_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
          Row(children: [const SettingsButton(), const Spacer()]),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),

            const SizedBox(height: 12),
            Center(
              child: Text(
                t('admin'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                t('restaurant_name'),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 10),
            ActionButtonsRow(
              onAddSection: () async {
                final ok = await context.push<bool>('/category-form');
                if (ok == true) context.read<OrderCubit>().refresh();
              },
              onAddFood: () async {
                final r = await context.push<Recipe>('/dish-form');
                if (r != null) {
                  context.read<OrderCubit>().addRecipe(r);
                }
              },
            ),

            const SizedBox(height: 24),
            _card(context, Icons.table_restaurant_outlined, t('table_management'), t('table_management_sub'), '/table-management'),
            _card(context, Icons.restaurant_menu, t('food_management'), t('food_management_sub'), '/food-management'),
            _card(context, Icons.toggle_on_outlined, t('available_foods'), t('available_foods_sub'), '/availability'),
            const SizedBox(height: 4),
            _card(context, Icons.history, t('order_history'), t('order_history_sub'), '/order-history'),
            _card(context, Icons.bar_chart, t('report'), t('report_sub'), '/report'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 18),
                    const SizedBox(width: 8),
                    Text(t('logout')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, IconData icon, String title, String sub, String route) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Text(sub, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
          trailing: Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
          onTap: () => context.push(route),
        ),
      ),
    );
  }
}
