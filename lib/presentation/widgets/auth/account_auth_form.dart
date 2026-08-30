import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_error_banner.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_fields.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_google_button.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_header.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_loading_overlay.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_or_divider.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_primary_button.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_scaffold.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_toggle_link.dart';

class AccountAuthForm extends StatelessWidget {
  const AccountAuthForm({
    super.key,
    required this.formKey,
    required this.emailCtl,
    required this.passCtl,
    required this.confirmCtl,
    required this.isSignUp,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onGoogleSignIn,
    required this.onToggleMode,
    required this.error,
    required this.scrim,
    required this.t,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtl;
  final TextEditingController passCtl;
  final TextEditingController confirmCtl;
  final bool isSignUp;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onToggleMode;
  final String? error;
  final Color scrim;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AuthScaffold(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthHeader(isSignUp: isSignUp, t: t),
                const SizedBox(height: 26),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black.withValues(alpha: 0.06),
                ),
                const SizedBox(height: 22),
                AuthFields(
                  emailCtl: emailCtl,
                  passCtl: passCtl,
                  confirmCtl: confirmCtl,
                  isSignUp: isSignUp,
                  obscure: obscure,
                  onToggleObscure: onToggleObscure,
                  t: t,
                ),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                  loading: loading,
                  onTap: onSubmit,
                  label: isSignUp
                      ? t('create_account_btn')
                      : t('login'),
                ),
                const SizedBox(height: 18),
                AuthOrDivider(label: t('or')),
                const SizedBox(height: 18),
                AuthGoogleButton(
                  loading: loading,
                  onTap: onGoogleSignIn,
                  label: t('google_sign_in'),
                ),
                const SizedBox(height: 8),
                AuthErrorBanner(error: error, t: t),
                AuthToggleLink(
                  isSignUp: isSignUp,
                  t: t,
                  onToggle: onToggleMode,
                ),
              ],
            ),
          ),
        ),
        if (loading) AuthLoadingOverlay(scrim: scrim),
      ],
    );
  }
}
