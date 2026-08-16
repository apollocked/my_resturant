import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

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
