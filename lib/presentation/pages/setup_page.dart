import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';

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
  final bool _obscure = true;
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
                padding: const EdgeInsets.all(32),
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
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t('setup_subtitle'),
                        style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _passField(
                        _waiterCtl,
                        t('waiter'),
                        Icons.room_service_outlined,
                        t,
                        cs,
                      ),
                      const SizedBox(height: 14),
                      _passField(
                        _kitchenCtl,
                        t('kitchen'),
                        Icons.restaurant_outlined,
                        t,
                        cs,
                      ),
                      const SizedBox(height: 14),
                      _passField(
                        _adminCtl,
                        t('admin'),
                        Icons.admin_panel_settings_outlined,
                        t,
                        cs,
                      ),
                      const SizedBox(height: 28),
                      if (context.watch<RoleCubit>().state.errorMessage case final err?)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(err, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
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
    String Function(String) t,
    ColorScheme cs,
  ) {
    return TextFormField(
      controller: ctl,
      obscureText: _obscure,
      maxLength: 6,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Icon(icon, size: 20),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    context.read<RoleCubit>().clearError();
    try {
      await context.read<RoleCubit>().configure(
        _waiterCtl.text,
        _kitchenCtl.text,
        _adminCtl.text,
      );
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
      context.go('/menu');
    }
  }
}
