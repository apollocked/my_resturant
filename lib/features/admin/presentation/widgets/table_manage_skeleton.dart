import 'package:flutter/material.dart';
import 'package:my_resturant/shared/shimmer_skeletons.dart';

class TableManageSkeleton extends StatelessWidget {
  const TableManageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(width: 120, height: 18, radius: 6),
        const SizedBox(height: 10),
        const ShimmerBox(width: double.infinity, height: 80, radius: 14),
        const SizedBox(height: 20),
        const ShimmerBox(width: 120, height: 18, radius: 6),
        const SizedBox(height: 12),
        ...List.generate(
          5,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerListTile(),
          ),
        ),
      ],
    );
  }
}
