import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class ProfileDialogs {
  static Future<void> switchRole(
    BuildContext context,
    Role r,
    RoleCubit cubit,
    String Function(String) t,
  ) async {
    if (cubit.state.role == Role.admin) {
      await cubit.switchRole(r);
      return;
    }
    final ctl = TextEditingController();
    String? pin;
    try {
      pin = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t('enter_pin_for').replaceAll('{role}', t(r.name))),
          content: TextField(
            controller: ctl,
            obscureText: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: t('pin_hint'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctl.text),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(t('verify')),
            ),
          ],
        ),
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () => ctl.dispose());
    }
    if (pin == null || pin.isEmpty) return;
    await cubit.switchRole(r, pin: pin);
    if (context.mounted && cubit.state.role != r) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('pin_invalid')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  static void confirmLogout(
    BuildContext context,
    AccountCubit acct,
    RoleCubit role,
    String Function(String) t,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('logout')),
        content: Text(t('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await acct.logout();
              await role.logout();
              if (!context.mounted) return;
              context.go('/account-auth');
            },
            child: Text(
              t('logout'),
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  static void showUpdateEmail(
    BuildContext context,
    AccountCubit cubit,
    String Function(String) t,
  ) {
    final ctl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('update_email')),
        content: TextField(
          controller: ctl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: t('new_email'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (ctl.text.isEmpty || !ctl.text.contains('@')) return;
              Navigator.pop(ctx);
              try {
                await cubit.updateEmail(ctl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${t('email_updated')}. ${t('email_confirmation_hint')}',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    ).then((_) => ctl.dispose());
  }

  static void showUpdatePassword(
    BuildContext context,
    AccountCubit cubit,
    String Function(String) t,
  ) {
    final curCtl = TextEditingController();
    final newCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('update_password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: curCtl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: t('current_password'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: t('new_password'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (curCtl.text.isEmpty || newCtl.text.length < 6) return;
              Navigator.pop(ctx);
              try {
                await cubit.updatePassword(curCtl.text, newCtl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t('password_updated')),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    ).then((_) {
      curCtl.dispose();
      newCtl.dispose();
    });
  }
}
