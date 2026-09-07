import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class AdminActionButton extends StatelessWidget {
  const AdminActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    required this.t,
  });

  final IconData icon;
  final String label;
  final String route;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => _push(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: R.fontSm(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _push(BuildContext context) async {
    final router = GoRouter.of(context);
    final orderCubit = context.read<OrderCubit>();
    if (route == '/dish-form') {
      final r = await router.push<Recipe>('/dish-form');
      if (r != null) {
        final ok = await orderCubit.addRecipe(r);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? t('dish_added') : t('error_occurred')),
            backgroundColor: ok ? null : AppColors.error,
          ),
        );
      }
    } else {
      final ok = await router.push<bool>(route);
      if (ok == true) orderCubit.refresh();
    }
  }
}
