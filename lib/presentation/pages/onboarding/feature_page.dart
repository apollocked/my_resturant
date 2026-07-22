import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/pages/onboarding/onb_colors.dart';
import 'package:my_resturant/presentation/pages/onboarding/onboarding_data.dart';
import 'package:my_resturant/presentation/widgets/onboarding/glowing_icon.dart';
import 'package:my_resturant/presentation/widgets/onboarding/glass_feature_tile.dart';

class FeaturePage extends StatelessWidget {
  final OnbPage data;
  final String Function(String) t;
  const FeaturePage({super.key, required this.data, required this.t});

  @override
  Widget build(BuildContext context) {
    final pad = R.padding(context);
    final ob = OnbColors.of(context);
    final features = data.featureKeys.map((k) => t(k)).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  GlowingIcon(icon: data.icon, color: data.gradient[0], ob: ob),
                  const SizedBox(height: 36),
                  Text(t(data.titleKey), style: TextStyle(fontSize: R.fontXl(context) + 4, fontWeight: FontWeight.w900, color: ob.textPrimary, letterSpacing: -0.5, height: 1.15), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(t(data.descKey), textAlign: TextAlign.center, style: TextStyle(fontSize: R.fontMd(context), color: ob.textSecondary, height: 1.55, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 28),
                  ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: GlassFeatureTile(label: f, accent: data.gradient[0], ob: ob))),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
