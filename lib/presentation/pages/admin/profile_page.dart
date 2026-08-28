import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_account_actions.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_admin_panel.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_dialogs.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_header.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_outlined_action.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_role_switcher.dart';
import 'package:my_resturant/presentation/widgets/profile/settings_button.dart';

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
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: R.isTablet(context) ? 720 : double.infinity,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Column(
              key: ValueKey(role),
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(children: [SettingsButton(), Spacer()]),
                ProfileHeader(
                  roleName: t(role.name),
                  email: acctState.email,
                  t: t,
                  cs: cs,
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
                  ProfileOutlinedAction(
                    icon: Icons.lock_outline,
                    label: t('change_pins'),
                    sideWidth: 1.5,
                    onTap: () => context.push('/change-passcodes'),
                  ),
                  const SizedBox(height: 8),
                  if (acctState.email == 'hamabarznji1990@gmail.com')
                    ProfileOutlinedAction(
                      icon: Icons.vpn_key_outlined,
                      label: 'Promo Codes',
                      sideWidth: 1.5,
                      onTap: () => context.push('/promo-codes'),
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
                ProfileOutlinedAction(
                  icon: Icons.logout,
                  label: t('logout'),
                  color: AppColors.error,
                  onTap: () => ProfileDialogs.confirmLogout(
                    context,
                    accountCubit,
                    roleCubit,
                    t,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
