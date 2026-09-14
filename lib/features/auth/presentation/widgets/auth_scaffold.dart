import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.maxWidth = 420,
    this.trailing,
  });

  final Widget child;
  final double maxWidth;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF141019), Color(0xFF0D0E12)]
                : const [Color(0xFFEFEBFF), Color(0xFFF5F5FA)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _glow(
                AppColors.primary.withValues(alpha: dark ? 0.28 : 0.18),
                240,
              ),
            ),
            Positioned(
              bottom: -110,
              left: -80,
              child: _glow(
                const Color(0xFFFFA17A).withValues(alpha: dark ? 0.20 : 0.14),
                260,
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                30,
                                24,
                                26,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: dark ? 0.06 : 0.62,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withValues(
                                    alpha: dark ? 0.12 : 0.5,
                                  ),
                                ),
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (trailing != null)
                    Positioned(top: 8, left: 8, child: trailing!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
