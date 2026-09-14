import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: R.fontSm(context),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
