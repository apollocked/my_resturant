import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class ProfileRoleSwitcher extends StatelessWidget {
  final Role currentRole;
  final RoleCubit roleCubit;
  final String Function(String) t;
  final void Function(BuildContext, Role, RoleCubit, String Function(String))
  onSwitch;
  const ProfileRoleSwitcher({
    super.key,
    required this.currentRole,
    required this.roleCubit,
    required this.t,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          t('switch_role'),
          style: TextStyle(
            fontSize: R.fontSm(context),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...Role.values.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RoleRow(
              role: r,
              isCurrent: r == currentRole,
              t: t,
              onTap: () => onSwitch(context, r, roleCubit, t),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleRow extends StatelessWidget {
  final Role role;
  final bool isCurrent;
  final String Function(String) t;
  final VoidCallback? onTap;
  const _RoleRow({
    required this.role,
    required this.isCurrent,
    required this.t,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PressableScale(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Card(
        child: ListTile(
          leading: Icon(
            role.icon,
            color: isCurrent ? AppColors.primary : cs.onSurfaceVariant,
          ),
          title: Text(
            t(role.name),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: R.fontMd(context),
              color: isCurrent ? AppColors.primary : cs.onSurface,
            ),
          ),
          subtitle: isCurrent
              ? Text(
                  t('current_role'),
                  style: TextStyle(
                    fontSize: R.fontSm(context),
                    color: AppColors.primary,
                  ),
                )
              : null,
          trailing: isCurrent
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    t('active'),
                    style: TextStyle(
                      fontSize: R.fontSm(context),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
