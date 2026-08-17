import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/pages/onboarding/onb_colors.dart';

class WelcomePage extends StatelessWidget {
  final String Function(String) t;
  const WelcomePage({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = R.padding(context);
    final ob = OnbColors.of(context);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  _HeroLogo(ob: ob),
                  const SizedBox(height: 48),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: ob.isDark
                          ? [cs.onPrimary, const Color(0xFFFFD4B0)]
                          : [ob.textPrimary, ob.textPrimary],
                    ).createShader(bounds),
                    child: Text(
                      t('onboarding_welcome_title'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: R.fontXxl(context),
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    t('onboarding_welcome_sub'),
                    style: TextStyle(
                      color: ob.textSecondary,
                      fontSize: R.fontLg(context),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _DescriptionCard(text: t('onboarding_welcome_desc'), ob: ob),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroLogo extends StatelessWidget {
  final OnbColors ob;
  const _HeroLogo({required this.ob});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final outer = R.avatarSize(context);
    final inner = outer * 0.78;
    return Container(
      width: outer,
      height: outer,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ob.iconCircleBg,
        border: Border.all(color: ob.iconCircleBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: inner,
          height: inner,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icons/my Restaurant.png',
              width: inner,
              height: inner,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String text;
  final OnbColors ob;
  const _DescriptionCard({required this.text, required this.ob});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: ob.glassBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: ob.glassBorder),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: ob.textSecondary, fontSize: R.fontMd(context), height: 1.6),
      ),
    );
  }
}
