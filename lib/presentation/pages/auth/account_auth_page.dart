import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/auth/account_auth_form.dart';

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
    final isSignUp = _isSignUp;

    return AccountAuthForm(
      formKey: _formKey,
      emailCtl: _emailCtl,
      passCtl: _passCtl,
      confirmCtl: _confirmCtl,
      isSignUp: isSignUp,
      obscure: _obscure,
      loading: _loading,
      onToggleObscure: () => setState(() => _obscure = !_obscure),
      onSubmit: _submit,
      onGoogleSignIn: _googleSignIn,
      onToggleMode: _toggleMode,
      error: context.watch<AccountCubit>().state.errorMessage,
      scrim: cs.scrim,
      t: t,
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
            if (err != null) _showSnackError(err);
          }
          return;
        }
      }
      if (mounted) await context.read<RoleCubit>().load();
    } catch (_) {}
    if (mounted) _finish();
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    context.read<AccountCubit>().clearError();
    try {
      await context.read<AccountCubit>().signInWithGoogle();
      if (mounted) await context.read<RoleCubit>().load();
    } catch (_) {}
    if (mounted) _finish();
  }

  void _toggleMode() {
    context.read<AccountCubit>().clearError();
    setState(() {
      _isSignUp = !_isSignUp;
      _formKey.currentState?.reset();
    });
  }

  void _finish() {
    setState(() => _loading = false);
    if (context.read<AccountCubit>().state.isLoggedIn) {
      context.go('/role-login');
    }
  }

  void _showSnackError(String err) {
    final loc = context.read<SettingsCubit>().state.locale;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Tr.get(err, loc)),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
