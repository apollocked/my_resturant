import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/profile/action_buttons_row.dart';
import 'package:my_resturant/presentation/widgets/profile/settings_button.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

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
    final isDesktop = R.isDesktop(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(R.padding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Row(children: [SettingsButton(), Spacer()]),
            const SizedBox(height: 8),
            _avatar(cs, context),
            const SizedBox(height: 12),
            Center(
              child: Text(
                t(role.name),
                style: TextStyle(fontSize: R.fontXl(context), fontWeight: FontWeight.w800, color: cs.onSurface),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(t('restaurant_name'), style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant)),
            ),
            Center(
              child: Text(acctState.email ?? '', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ),

            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                title: Text(t('update_email'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: R.fontMd(context))),
                trailing: const Icon(Icons.chevron_left, size: 18),
                onTap: () => _showUpdateEmail(context, accountCubit, t, cs),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                title: Text(t('update_password'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: R.fontMd(context))),
                trailing: const Icon(Icons.chevron_left, size: 18),
                onTap: () => _showUpdatePassword(context, accountCubit, t, cs),
              ),
            ),

            if (role == Role.admin) ...[
              const SizedBox(height: 10),
              ActionButtonsRow(
                onAddSection: () async {
                  final router = GoRouter.of(context);
                  final orderCubit = context.read<OrderCubit>();
                  final ok = await router.push<bool>('/category-form');
                  if (ok == true) orderCubit.refresh();
                },
                onAddFood: () async {
                  final router = GoRouter.of(context);
                  final orderCubit = context.read<OrderCubit>();
                  final r = await router.push<Recipe>('/dish-form');
                  if (r != null) orderCubit.addRecipe(r);
                },
              ),
              const SizedBox(height: 24),
              if (isDesktop)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: R.gridSpacing(context),
                  mainAxisSpacing: R.gridSpacing(context),
                  childAspectRatio: 1.8,
                  children: [
                    _card(context, Icons.table_restaurant_outlined, t('table_management'), t('table_management_sub'), '/table-management'),
                    _card(context, Icons.restaurant_menu, t('food_management'), t('food_management_sub'), '/food-management'),
                    _card(context, Icons.toggle_on_outlined, t('available_foods'), t('available_foods_sub'), '/availability'),
                    _card(context, Icons.history, t('order_history'), t('order_history_sub'), '/history'),
                    _card(context, Icons.bar_chart, t('report'), t('report_sub'), '/report'),
                  ],
                )
              else ...[
                _card(context, Icons.table_restaurant_outlined, t('table_management'), t('table_management_sub'), '/table-management'),
                _card(context, Icons.restaurant_menu, t('food_management'), t('food_management_sub'), '/food-management'),
                _card(context, Icons.toggle_on_outlined, t('available_foods'), t('available_foods_sub'), '/availability'),
                _card(context, Icons.history, t('order_history'), t('order_history_sub'), '/history'),
                _card(context, Icons.bar_chart, t('report'), t('report_sub'), '/report'),
              ],
            ],

            const SizedBox(height: 16),
            Text(t('switch_role'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            ...Role.values.map(
              (r) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _switchRow(context, r, r == role, roleCubit, t, cs)),
            ),

            if (role == Role.admin) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/change-passcodes'),
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: Text(t('change_pins')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _confirmLogout(context, accountCubit, roleCubit, t),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.logout, size: 18),
                  const SizedBox(width: 8),
                  Text(t('logout')),
                ]),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _avatar(ColorScheme cs, BuildContext context) {
    final avatarSize = R.avatarSize(context);
    return Center(
      child: Container(
        width: avatarSize, height: avatarSize,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Icon(Icons.person, size: avatarSize * 0.5, color: AppColors.primary),
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
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: R.fontMd(context))),
          subtitle: Text(sub, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
          trailing: Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
          onTap: () => context.push(route),
        ),
      ),
    );
  }

  Widget _switchRow(BuildContext context, Role r, bool isCurrent, RoleCubit cubit, String Function(String) t, ColorScheme cs) {
    return Card(
      child: ListTile(
        leading: Icon(_roleIcon(r), color: isCurrent ? AppColors.primary : cs.onSurfaceVariant),
        title: Text(t(r.name), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isCurrent ? AppColors.primary : cs.onSurface)),
        subtitle: isCurrent ? Text(t('current_role'), style: const TextStyle(fontSize: 11, color: AppColors.primary)) : null,
        trailing: isCurrent
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
                child: Text(t('active'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              )
            : null,
        onTap: isCurrent ? null : () => _switchTo(context, r, cubit, t),
      ),
    );
  }

  IconData _roleIcon(Role r) {
    switch (r) {
      case Role.waiter: return Icons.room_service_outlined;
      case Role.kitchen: return Icons.restaurant_outlined;
      case Role.admin: return Icons.admin_panel_settings_outlined;
    }
  }

  Future<void> _switchTo(BuildContext context, Role r, RoleCubit cubit, String Function(String) t) async {
    if (cubit.state.role == Role.admin) {
      await cubit.switchRole(r);
      return;
    }
    final ctl = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('enter_pin_for').replaceAll('{role}', t(r.name))),
        content: TextField(
          controller: ctl, obscureText: true, maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(border: const OutlineInputBorder(), hintText: t('pin_hint')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctl.text),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(t('verify')),
          ),
        ],
      ),
    );
    if (pin == null || pin.isEmpty) return;
    await cubit.switchRole(r, pin: pin);
    if (context.mounted && cubit.state.role != r) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('pin_invalid')), backgroundColor: AppColors.error));
    }
  }

  void _confirmLogout(BuildContext context, AccountCubit acct, RoleCubit role, String Function(String) t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('logout')),
        content: Text(t('logout_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              acct.logout();
              role.logout();
            },
            child: Text(t('logout'), style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  void _showUpdateEmail(BuildContext context, AccountCubit cubit, String Function(String) t, ColorScheme cs) {
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (ctl.text.isEmpty || !ctl.text.contains('@')) return;
              Navigator.pop(ctx);
              try {
                await cubit.updateEmail(ctl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${t('email_updated')}. ${t('email_confirmation_hint')}'),
                    backgroundColor: AppColors.success,
                  ));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('$e'),
                    backgroundColor: AppColors.error,
                  ));
                }
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void _showUpdatePassword(BuildContext context, AccountCubit cubit, String Function(String) t, ColorScheme cs) {
    final curCtl = TextEditingController();
    final newCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('update_password')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
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
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (curCtl.text.isEmpty || newCtl.text.length < 6) return;
              Navigator.pop(ctx);
              try {
                await cubit.updatePassword(curCtl.text, newCtl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(t('password_updated')),
                    backgroundColor: AppColors.success,
                  ));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('$e'),
                    backgroundColor: AppColors.error,
                  ));
                }
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }
}
