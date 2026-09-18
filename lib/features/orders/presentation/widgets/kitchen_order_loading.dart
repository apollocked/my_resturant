import 'package:flutter/material.dart';

import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/shimmer_skeletons.dart';

/// Placeholder grid / list shown while the kitchen orders first load.
class KitchenOrderLoading extends StatelessWidget {
  final bool isGrid;

  const KitchenOrderLoading({super.key, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    if (!isGrid) {
      return ShimmerListView(
        itemCount: 4,
        itemBuilder: () => const ShimmerOrderCard(),
      );
    }
    return GridView(
      padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 520,
        childAspectRatio: 0.9,
        crossAxisSpacing: R.gridSpacing(context),
        mainAxisSpacing: R.gridSpacing(context),
      ),
      children: List.generate(4, (_) => const ShimmerOrderCard()),
    );
  }
}