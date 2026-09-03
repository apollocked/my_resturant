import 'package:flutter/material.dart';
import 'package:my_resturant/shared/shimmer_skeletons.dart';

class HistoryShimmer extends StatelessWidget {
  const HistoryShimmer({super.key, required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 36, height: 36, radius: 8),
              ShimmerBox(width: 140, height: 36, radius: 8),
              ShimmerBox(width: 36, height: 36, radius: 8),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ShimmerGrid(itemCount: 6, itemBuilder: () => const ShimmerOrderCard()),
      ],
    );
  }
}
