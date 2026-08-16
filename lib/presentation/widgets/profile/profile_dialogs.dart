import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/widgets/profile/logout_dialog.dart';
import 'package:my_resturant/presentation/widgets/profile/pin_dialog.dart';
import 'package:my_resturant/presentation/widgets/profile/role_transition_overlay.dart';
import 'package:my_resturant/presentation/widgets/profile/update_email_dialog.dart';
import 'package:my_resturant/presentation/widgets/profile/update_password_dialog.dart';

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

    final fromRole = cubit.state.role;

    final ok = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.72),
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
    if (ok != true && cubit.state.role != r) {
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
      builder: (_) => LogoutDialog(accountCubit: acct, roleCubit: role, t: t),
    );
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
