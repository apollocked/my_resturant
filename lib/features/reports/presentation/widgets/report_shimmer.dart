import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/shimmer_skeletons.dart';

class ReportShimmer extends StatelessWidget {
  const ReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final p = R.padding(context);
    final isDesktop = R.isDesktop(context);
    return ListView(
      padding: EdgeInsets.all(p),
      children: [
        if (isDesktop)
          Row(
            children:
                List.generate(
                    3,
                    (_) => const ShimmerBox(
                      width: double.infinity,
                      height: 80,
                      radius: 14,
                    ),
                  ).expand((w) => [w, const SizedBox(width: 12)]).toList()
                  ..removeLast(),
          )
        else ...[
          const Row(
            children: [
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 80,
                  radius: 14,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 80,
                  radius: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const ShimmerBox(width: double.infinity, height: 80, radius: 14),
        ],
        const SizedBox(height: 24),
        const ShimmerBox(width: 140, height: 18, radius: 6),
        const SizedBox(height: 16),
        ...List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ShimmerListTile(),
          ),
        ),
      ],
    );
  }
}
