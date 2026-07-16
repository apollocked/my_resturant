import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class AccountAuthPage extends StatefulWidget {
  const AccountAuthPage({super.key});
  @override
  State<AccountAuthPage> createState() => _AccountAuthPageState();
}

class _AccountAuthPageState extends State<AccountAuthPage> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    _confirmCtl.dispose();
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
                        width: R.avatarSize(context),
                        height: R.avatarSize(context),
                        decoration: const BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isSignUp ? Icons.person_add_outlined : Icons.restaurant,
                          size: R.avatarSize(context) * 0.5,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSignUp ? t('create_account_title') : t('restaurant_name'),
                        style: TextStyle(
                          fontSize: R.fontXl(context),
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isSignUp ? t('create_account_subtitle') : t('account_login_subtitle'),
                        style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailCtl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          labelText: t('email'),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (v) => v == null || !v.contains('@') ? t('email_invalid') : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passCtl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          labelText: t('password'),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6 ? t('password_too_short') : null,
                      ),
                      if (_isSignUp) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmCtl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                            labelText: t('confirm_password'),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (v) => v != _passCtl.text ? t('passwords_mismatch') : null,
                        ),
                      ],
                      const SizedBox(height: 24),
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
                                  _isSignUp ? t('create_account_btn') : t('login'),
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: R.fontMd(context)),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (context.watch<AccountCubit>().state.errorMessage case final err?)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(t(err), style: TextStyle(color: AppColors.error, fontSize: R.fontSm(context))),
                        ),
                      TextButton(
                        onPressed: () {
                          context.read<AccountCubit>().clearError();
                          setState(() {
                            _isSignUp = !_isSignUp;
                            _formKey.currentState?.reset();
                          });
                        },
                        child: Text(
                          _isSignUp ? t('already_have_account') : t('dont_have_account'),
                          style: TextStyle(color: cs.primary, fontSize: R.fontSm(context)),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    context.read<AccountCubit>().clearError();
    try {
      final cubit = context.read<AccountCubit>();
      if (_isSignUp) {
        await cubit.createAccount(_emailCtl.text, _passCtl.text);
      } else {
        final ok = await cubit.login(_emailCtl.text, _passCtl.text);
        if (!ok) {
          if (mounted) {
            setState(() => _loading = false);
            final err = context.read<AccountCubit>().state.errorMessage;
            if (err != null) {
              final loc = context.read<SettingsCubit>().state.locale;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Tr.get(err, loc)), backgroundColor: AppColors.error),
              );
            }
          }
          return;
        }
      }
      if (mounted) {
        await context.read<RoleCubit>().load();
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
      context.go('/role-login');
    }
  }
}
