import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/shimmer/shimmer_box.dart';

class ShimmerOrderCard extends StatelessWidget {
  const ShimmerOrderCard({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    final isTablet = R.isTablet(context);
    final p = isDesktop
        ? 20.0
        : isTablet
        ? 18.0
        : 16.0;
    return Card(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 18 : 16),
      ),
      child: Shimmer.fromColors(
        baseColor: cs.surfaceContainerHighest,
        highlightColor: cs.surface,
        child: Padding(
          padding: EdgeInsets.all(p),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 90, height: 28, radius: 8),
                  ShimmerBox(width: 60, height: 28, radius: 8),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      ShimmerBox(width: 26, height: 26, radius: 6),
                      SizedBox(width: 8),
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 12,
                          radius: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 80, height: 32, radius: 10),
                  ShimmerBox(width: 100, height: 32, radius: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
