import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_loading_overlay.dart';
import 'package:my_resturant/presentation/widgets/auth/pin_field.dart';
import 'package:my_resturant/presentation/widgets/auth/role_card.dart';
import 'package:my_resturant/presentation/widgets/auth/role_login_button.dart';
import 'package:my_resturant/presentation/widgets/auth/role_login_header.dart';
import 'package:my_resturant/presentation/widgets/profile/settings_dialog.dart';

class RoleLoginPage extends StatefulWidget {
  const RoleLoginPage({super.key});
  @override
  State<RoleLoginPage> createState() => _RoleLoginPageState();
}

class _RoleLoginPageState extends State<RoleLoginPage> {
  Role _selected = Role.waiter;
  final _pinCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pinCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final cs = Theme.of(context).colorScheme;
    String t(String key) => Tr.get(key, settings.locale);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (_) => const SettingsDialog(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.settings, size: 22, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(R.padding(context)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoleLoginHeader(t: t),
                      const SizedBox(height: 28),
                      Text(
                        t('choose_role'),
                        style: TextStyle(
                          fontSize: R.fontMd(context),
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: Role.values
                            .map(
                              (r) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: RoleCard(
                                    role: r,
                                    selected: _selected == r,
                                    t: t,
                                    onTap: () => setState(() => _selected = r),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                      PinField(controller: _pinCtl, t: t),
                      const SizedBox(height: 20),
                      if (_error case final err?)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            err,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: R.fontSm(context),
                            ),
                          ),
                        ),
                      RoleLoginButton(loading: _loading, t: t, onTap: _login),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_loading) AuthLoadingOverlay(scrim: cs.scrim),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_pinCtl.text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await context.read<RoleCubit>().loginAsync(
      _selected,
      _pinCtl.text,
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _loading = false);
      context.go('/menu');
    } else {
      setState(() {
        _loading = false;
        _error = Tr.get(
          'pin_invalid',
          context.read<SettingsCubit>().state.locale,
        );
      });
      _pinCtl.clear();
    }
  }
}
