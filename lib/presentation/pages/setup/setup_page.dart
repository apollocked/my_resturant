import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_loading_overlay.dart';
import 'package:my_resturant/presentation/widgets/setup/passcodes_saved_dialog.dart';
import 'package:my_resturant/presentation/widgets/setup/setup_header.dart';
import 'package:my_resturant/presentation/widgets/setup/setup_passcode_field.dart';
import 'package:my_resturant/shared/loading_action_button.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _waiterCtl = TextEditingController();
  final _kitchenCtl = TextEditingController();
  final _adminCtl = TextEditingController();
  bool _obscureWaiter = true;
  bool _obscureKitchen = true;
  bool _obscureAdmin = true;
  bool _loading = false;

  @override
  void dispose() {
    _waiterCtl.dispose();
    _kitchenCtl.dispose();
    _adminCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final cs = Theme.of(context).colorScheme;
    String t(String key) => Tr.get(key, settings.locale);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(R.padding(context)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SetupHeader(t: t),
                        const SizedBox(height: 32),
                        SetupPasscodeField(
                          controller: _waiterCtl,
                          label: t('waiter'),
                          icon: Icons.room_service_outlined,
                          obscure: _obscureWaiter,
                          onToggleObscure: () =>
                              setState(() => _obscureWaiter = !_obscureWaiter),
                          t: t,
                        ),
                        const SizedBox(height: 14),
                        SetupPasscodeField(
                          controller: _kitchenCtl,
                          label: t('kitchen'),
                          icon: Icons.restaurant_outlined,
                          obscure: _obscureKitchen,
                          onToggleObscure: () => setState(
                            () => _obscureKitchen = !_obscureKitchen,
                          ),
                          t: t,
                        ),
                        const SizedBox(height: 14),
                        SetupPasscodeField(
                          controller: _adminCtl,
                          label: t('admin'),
                          icon: Icons.admin_panel_settings_outlined,
                          obscure: _obscureAdmin,
                          onToggleObscure: () =>
                              setState(() => _obscureAdmin = !_obscureAdmin),
                          t: t,
                        ),
                        const SizedBox(height: 28),
                        if (context.watch<RoleCubit>().state.errorMessage
                            case final err?)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              err,
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: R.fontSm(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        LoadingActionButton(
                          loading: _loading,
                          t: t,
                          labelKey: 'setup_btn',
                          onTap: _submit,
                        ),
                      ],
                    ),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    context.read<RoleCubit>().clearError();
    bool ok = false;
    try {
      await context.read<RoleCubit>().configure(
        _waiterCtl.text,
        _kitchenCtl.text,
        _adminCtl.text,
      );
      ok = true;
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        await showPasscodesSavedDialog(context, {
          'waiter': _waiterCtl.text,
          'kitchen': _kitchenCtl.text,
          'admin': _adminCtl.text,
        });
        if (mounted) context.go('/role-login');
      }
    }
  }
}
