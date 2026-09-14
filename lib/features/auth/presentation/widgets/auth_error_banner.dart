import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.error, required this.t});

  final String? error;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final err = error;
    if (err == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        t(err),
        style: TextStyle(
          color: AppColors.error,
          fontSize: R.fontSm(context),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
