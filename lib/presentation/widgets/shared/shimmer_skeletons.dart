import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class ShimmerBox extends StatelessWidget {
  final double width, height, radius;
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

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

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function() itemBuilder;
  const ShimmerGrid({super.key, this.itemCount = 6, required this.itemBuilder});
  @override
  Widget build(BuildContext context) {
    final isDesktop = R.isDesktop(context);
    if (isDesktop) {
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: R.menuGridAspectRatio(context),
          crossAxisSpacing: R.gridSpacing(context),
          mainAxisSpacing: R.gridSpacing(context),
        ),
        itemCount: itemCount,
        itemBuilder: (_, _) => itemBuilder(),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: R.menuGridColumns(context),
          childAspectRatio: R.menuGridAspectRatio(context),
          crossAxisSpacing: R.gridSpacing(context),
          mainAxisSpacing: R.gridSpacing(context),
        ),
        itemCount: itemCount,
        itemBuilder: (_, _) => itemBuilder(),
      ),
    );
  }
}

class ShimmerListView extends StatelessWidget {
  final int itemCount;
  final Widget Function() itemBuilder;
  const ShimmerListView({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          itemCount,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: itemBuilder(),
          ),
        ),
      ),
    );
  }
}
