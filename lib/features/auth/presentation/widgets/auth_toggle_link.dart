import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class AuthToggleLink extends StatelessWidget {
  const AuthToggleLink({
    super.key,
    required this.isSignUp,
    required this.t,
    required this.onToggle,
  });

  final bool isSignUp;
  final String Function(String key) t;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onToggle,
      child: Text(
        isSignUp ? t('already_have_account') : t('dont_have_account'),
        style: TextStyle(color: cs.primary, fontSize: R.fontSm(context)),
      ),
    );
  }
}
