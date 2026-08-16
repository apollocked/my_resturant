import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/shimmer/shimmer_box.dart';

class ShimmerFoodCard extends StatelessWidget {
  const ShimmerFoodCard({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    final isTablet = R.isTablet(context);
    final radius = isDesktop
        ? 24.0
        : isTablet
        ? 20.0
        : 16.0;
    final cp = isDesktop
        ? 20.0
        : isTablet
        ? 16.0
        : 12.0;
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHighest,
      highlightColor: cs.surface,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isDesktop
                  ? 160
                  : isTablet
                  ? 140
                  : 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(radius),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(cp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: double.infinity,
                    height: isDesktop ? 16 : 14,
                    radius: 6,
                  ),
                  const SizedBox(height: 8),
                  ShimmerBox(
                    width: 120,
                    height: isDesktop ? 12 : 10,
                    radius: 6,
                  ),
                  SizedBox(height: isDesktop ? 16 : 10),
                  const ShimmerBox(width: 80, height: 32, radius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
