import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/shimmer/shimmer_box.dart';

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    return Card(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 8),
      child: Shimmer.fromColors(
        baseColor: cs.surfaceContainerHighest,
        highlightColor: cs.surface,
        child: const ListTile(
          leading: ShimmerBox(width: 48, height: 48, radius: 8),
          title: ShimmerBox(width: 160, height: 14, radius: 6),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 8),
            child: ShimmerBox(width: 100, height: 12, radius: 6),
          ),
        ),
      ),
    );
  }
}
