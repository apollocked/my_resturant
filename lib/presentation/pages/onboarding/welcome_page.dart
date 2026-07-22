import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class WelcomePage extends StatelessWidget {
  final String Function(String) t;
  const WelcomePage({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final pad = R.padding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          _HeroLogo(),
          const SizedBox(height: 48),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFFFD4B0)],
            ).createShader(bounds),
            child: Text(
              t('onboarding_welcome_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
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
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 17,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _DescriptionCard(text: t('onboarding_welcome_desc')),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _HeroLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 10),
        ],
      ),
      child: Center(
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: ClipOval(
            child: Image.asset('assets/icons/my Restaurant.png', width: 110, height: 110, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String text;
  const _DescriptionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14.5, height: 1.6),
      ),
    );
  }
}
