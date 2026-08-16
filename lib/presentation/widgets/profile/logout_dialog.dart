import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({
    super.key,
    required this.accountCubit,
    required this.roleCubit,
    required this.t,
  });

  final AccountCubit accountCubit;
  final RoleCubit roleCubit;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t('logout')),
      content: Text(t('logout_confirm')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t('cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () async {
            Navigator.pop(context);
            await roleCubit.logout();
            await accountCubit.logout();
            if (!context.mounted) return;
            context.go('/account-auth');
          },
          child: Text(
            t('logout'),
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}
