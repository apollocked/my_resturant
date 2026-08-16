import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_text_field.dart';

class AuthFields extends StatelessWidget {
  const AuthFields({
    super.key,
    required this.emailCtl,
    required this.passCtl,
    required this.confirmCtl,
    required this.isSignUp,
    required this.obscure,
    required this.onToggleObscure,
    required this.t,
  });

  final TextEditingController emailCtl;
  final TextEditingController passCtl;
  final TextEditingController confirmCtl;
  final bool isSignUp;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final email = AuthTextField(
      controller: emailCtl,
      icon: Icons.email_outlined,
      label: t('email'),
      keyboardType: TextInputType.emailAddress,
      validator: (v) =>
          v == null || !v.contains('@') ? t('email_invalid') : null,
    );
    final password = AuthTextField(
      controller: passCtl,
      icon: Icons.lock_outlined,
      label: t('password'),
      obscure: true,
      obscureText: obscure,
      onToggleObscure: onToggleObscure,
      validator: (v) =>
          v == null || v.length < 6 ? t('password_too_short') : null,
    );
    final confirm = AuthTextField(
      controller: confirmCtl,
      icon: Icons.lock_outlined,
      label: t('confirm_password'),
      obscure: true,
      obscureText: obscure,
      validator: (v) => v != passCtl.text ? t('passwords_mismatch') : null,
    );
    return Column(
      children: [
        email,
        SizedBox(height: R.gridSpacing(context)),
        password,
        if (isSignUp) ...[SizedBox(height: R.gridSpacing(context)), confirm],
      ],
    );
  }
}
