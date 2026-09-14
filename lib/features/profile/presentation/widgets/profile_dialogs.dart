import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/app/router/app_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';
import 'package:my_resturant/features/auth/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/features/permissions/presentation/permission_prompts.dart';
import 'package:my_resturant/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:my_resturant/features/profile/presentation/widgets/pin_dialog.dart';
import 'package:my_resturant/features/profile/presentation/widgets/role_transition_overlay.dart';
import 'package:my_resturant/features/profile/presentation/widgets/update_email_dialog.dart';
import 'package:my_resturant/features/profile/presentation/widgets/update_password_dialog.dart';

class ProfileDialogs {
  static Future<void> switchRole(
    BuildContext context,
    Role r,
    RoleCubit cubit,
    String Function(String) t,
  ) async {
    if (cubit.state.role == r) return;

    String? pin;
    if (cubit.state.role != Role.admin) {
      pin = await showDialog<String>(
        context: context,
        builder: (_) => PinDialog(
          role: r,
          title: t('enter_pin_for').replaceAll('{role}', t(r.name)),
          subtitle: t('pin_hint'),
          cancelLabel: t('cancel'),
          verifyLabel: t('verify'),
        ),
      );
      if (pin == null) return;
    }
    if (!context.mounted) return;

    final cs = Theme.of(context).colorScheme;
    final fromRole = cubit.state.role;

    final ok = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: cs.scrim.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, _, _) => RoleTransitionOverlay(
        fromRole: fromRole,
        toRole: r,
        toLabel: t(r.name),
        t: t,
        task: () => cubit.switchRole(r, pin: pin),
      ),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.88,
            end: 1,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

    if (!context.mounted) return;
    if (ok == true || cubit.state.role == r) {
      if (r == Role.kitchen || r == Role.waiter) {
        promptNotificationIfNeeded(context);
      }
      final home = homeForRole(cubit.state.role);
      if (home != '/profile' && context.mounted) {
        context.go(home);
      }
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t(cubit.state.errorMessage ?? 'pin_invalid')),
        backgroundColor: AppColors.error,
      ),
    );
  }

  static Future<void> confirmLogout(
    BuildContext context,
    AccountCubit acct,
    RoleCubit role,
    String Function(String) t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => LogoutDialog(t: t),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await acct.logout();
    await role.logout();
    if (!context.mounted) return;
    context.go('/account-auth');
  }

  static void showUpdateEmail(
    BuildContext context,
    AccountCubit cubit,
    String Function(String) t,
  ) {
    showDialog(
      context: context,
      builder: (_) => UpdateEmailDialog(cubit: cubit, t: t),
    );
  }

  static void showUpdatePassword(
    BuildContext context,
    AccountCubit cubit,
    String Function(String) t,
  ) {
    showDialog(
      context: context,
      builder: (_) => UpdatePasswordDialog(cubit: cubit, t: t),
    );
  }
}
