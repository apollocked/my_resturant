import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t('setup_title'),
                        style: TextStyle(
                          fontSize: R.fontXl(context),
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t('setup_subtitle'),
                        style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _passField(
                        _waiterCtl,
                        t('waiter'),
                        Icons.room_service_outlined,
                        _obscureWaiter,
                        () => setState(() => _obscureWaiter = !_obscureWaiter),
                        t,
                        cs,
                      ),
                      const SizedBox(height: 14),
                      _passField(
                        _kitchenCtl,
                        t('kitchen'),
                        Icons.restaurant_outlined,
                        _obscureKitchen,
                        () => setState(() => _obscureKitchen = !_obscureKitchen),
                        t,
                        cs,
                      ),
                      const SizedBox(height: 14),
                      _passField(
                        _adminCtl,
                        t('admin'),
                        Icons.admin_panel_settings_outlined,
                        _obscureAdmin,
                        () => setState(() => _obscureAdmin = !_obscureAdmin),
                        t,
                        cs,
                      ),
                      const SizedBox(height: 28),
                      if (context.watch<RoleCubit>().state.errorMessage case final err?)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(err, style: TextStyle(color: AppColors.error, fontSize: R.fontSm(context))),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: PressableScale(
                          onTap: _loading ? null : _submit,
                          child: FilledButton(
                            onPressed: null,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _loading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                                  )
                                : Text(
                                    t('setup_btn'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: R.fontMd(context),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: cs.scrim.withValues(alpha: 0.26),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _passField(
    TextEditingController ctl,
    String label,
    IconData icon,
    bool obscure,
    VoidCallback toggleObscure,
    String Function(String) t,
    ColorScheme cs,
  ) {
    return TextFormField(
      controller: ctl,
      obscureText: obscure,
      maxLength: 6,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          onPressed: toggleObscure,
        ),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      validator: (v) => v == null || v.isEmpty
          ? t('pin_required')
          : v.length < 4
          ? t('pin_too_short')
          : null,
    );
  }

  Future<void> _showPasscodesDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Passcodes Saved'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Save these passcodes securely. You will need them to log in.'),
            const SizedBox(height: 16),
            _passcodeRow(Icons.room_service_outlined, 'Waiter', _waiterCtl.text),
            const SizedBox(height: 8),
            _passcodeRow(Icons.restaurant_outlined, 'Kitchen', _kitchenCtl.text),
            const SizedBox(height: 8),
            _passcodeRow(Icons.admin_panel_settings_outlined, 'Admin', _adminCtl.text),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _passcodeRow(IconData icon, String label, String code) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3)),
      ],
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
        await _showPasscodesDialog(context);
        if (mounted) context.go('/role-login');
      }
    }
  }
}
