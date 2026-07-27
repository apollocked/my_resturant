import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class ProfileAdminPanel extends StatelessWidget {
  final String Function(String) t;
  const ProfileAdminPanel({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final isDesktop = R.isDesktop(context);
    final cards = _buildCards(context);

    return Column(
      children: [
        const SizedBox(height: 10),
        ActionButtonsRowPlaceholder(t: t),
        const SizedBox(height: 24),
        if (isDesktop)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: R.gridSpacing(context),
            mainAxisSpacing: R.gridSpacing(context),
            childAspectRatio: 1.8,
            children: cards,
          )
        else
          ...cards,
      ],
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    return [
      _card(
        context,
        Icons.table_restaurant_outlined,
        t('table_management'),
        t('table_management_sub'),
        '/table-management',
      ),
      _card(
        context,
        Icons.restaurant_menu,
        t('food_management'),
        t('food_management_sub'),
        '/food-management',
      ),
      _card(
        context,
        Icons.toggle_on_outlined,
        t('available_foods'),
        t('available_foods_sub'),
        '/availability',
      ),
      _card(
        context,
        Icons.history,
        t('order_history'),
        t('order_history_sub'),
        '/history',
      ),
      _card(context, Icons.bar_chart, t('report'), t('report_sub'), '/report'),
    ];
  }

  Widget _card(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    String route,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        onTap: () => context.push(route),
        child: Card(
          child: ListTile(
            leading: Icon(icon, color: AppColors.primary),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: R.fontMd(context),
              ),
            ),
            subtitle: Text(
              sub,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
            trailing: Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class ActionButtonsRowPlaceholder extends StatelessWidget {
  final String Function(String) t;
  const ActionButtonsRowPlaceholder({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _btn(
            context,
            Icons.table_restaurant_outlined,
            t('add_table'),
            '/table-management',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _btn(
            context,
            Icons.restaurant_menu,
            t('add_food'),
            '/dish-form',
          ),
        ),
      ],
    );
  }

  Widget _btn(BuildContext context, IconData icon, String label, String route) {
    return PressableScale(
      onTap: () async {
        final router = GoRouter.of(context);
        final orderCubit = context.read<OrderCubit>();
        if (route == '/dish-form') {
          final r = await router.push<Recipe>('/dish-form');
          if (r != null) orderCubit.addRecipe(r);
        } else {
          final ok = await router.push<bool>(route);
          if (ok == true) orderCubit.refresh();
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
