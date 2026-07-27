import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/profile/settings_button.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_avatar.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_account_actions.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_admin_panel.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_role_switcher.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_dialogs.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final role = context.watch<RoleCubit>().state.role;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final roleCubit = context.read<RoleCubit>();
    final accountCubit = context.read<AccountCubit>();
    final acctState = context.watch<AccountCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        R.padding(context),
        R.padding(context),
        R.padding(context),
        R.padding(context) + 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(children: [SettingsButton(), Spacer()]),
          const SizedBox(height: 8),
          const ProfileAvatar(),
          const SizedBox(height: 12),
          Center(
            child: Text(
              t(role.name),
              style: TextStyle(
                fontSize: R.fontXl(context),
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              t('restaurant_name'),
              style: TextStyle(
                fontSize: R.fontSm(context),
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Center(
            child: Text(
              acctState.email ?? '',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          ProfileAccountActions(
            onUpdateEmail: () =>
                ProfileDialogs.showUpdateEmail(context, accountCubit, t),
            onUpdatePassword: () =>
                ProfileDialogs.showUpdatePassword(context, accountCubit, t),
          ),
          if (role == Role.admin) ...[
            ProfileAdminPanel(t: t),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PressableScale(
                onTap: () => context.push('/change-passcodes'),
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: Text(t('change_pins')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    disabledForegroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (acctState.email == 'hamabarznji1990@gmail.com')
              SizedBox(
                width: double.infinity,
                child: PressableScale(
                  onTap: () => context.push('/promo-codes'),
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.vpn_key_outlined, size: 18),
                    label: const Text('Promo Codes'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      disabledForegroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          ProfileRoleSwitcher(
            currentRole: role,
            roleCubit: roleCubit,
            t: t,
            onSwitch: ProfileDialogs.switchRole,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: PressableScale(
              onTap: () => ProfileDialogs.confirmLogout(
                context,
                accountCubit,
                roleCubit,
                t,
              ),
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  disabledForegroundColor: AppColors.error,
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
