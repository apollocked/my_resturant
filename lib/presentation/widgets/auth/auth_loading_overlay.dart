import 'package:flutter/material.dart';

class AuthLoadingOverlay extends StatelessWidget {
  const AuthLoadingOverlay({super.key, required this.scrim});

  final Color scrim;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scrim.withValues(alpha: 0.26),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
