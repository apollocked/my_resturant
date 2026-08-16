import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_error_banner.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_fields.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_google_button.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_header.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_loading_overlay.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_or_divider.dart';
import 'package:my_resturant/presentation/widgets/auth/auth_primary_button.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(R.padding(context)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AuthHeader(isSignUp: isSignUp, t: t),
                        SizedBox(height: R.gridSpacing(context)),
                        AuthFields(
                          emailCtl: emailCtl,
                          passCtl: passCtl,
                          confirmCtl: confirmCtl,
                          isSignUp: isSignUp,
                          obscure: obscure,
                          onToggleObscure: onToggleObscure,
                          t: t,
                        ),
                        SizedBox(height: R.gridSpacing(context)),
                        AuthPrimaryButton(
                          loading: loading,
                          onTap: onSubmit,
                          label: isSignUp
                              ? t('create_account_btn')
                              : t('login'),
                        ),
                        SizedBox(height: R.gridSpacing(context)),
                        AuthOrDivider(label: t('or')),
                        SizedBox(height: R.gridSpacing(context)),
                        AuthGoogleButton(
                          loading: loading,
                          onTap: onGoogleSignIn,
                          label: t('google_sign_in'),
                        ),
                        SizedBox(height: R.gridSpacing(context)),
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
              ),
            ),
          ),
          if (loading) AuthLoadingOverlay(scrim: scrim),
        ],
      ),
    );
  }
}
