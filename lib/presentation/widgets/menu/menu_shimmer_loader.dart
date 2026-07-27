import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/widgets/shared/shimmer_skeletons.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class MenuShimmerLoader extends StatelessWidget {
  const MenuShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: R.isDesktop(context)
              ? Row(children: [
                  Container(
                    width: 180,
                    padding: EdgeInsets.fromLTRB(R.padding(context), 24, 0, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const ShimmerBox(width: 80, height: 14, radius: 6),
                      const SizedBox(height: 16),
                      ...List.generate(5, (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: ShimmerBox(width: double.infinity, height: 36, radius: 20),
                      )),
                    ]),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: Padding(
                    padding: EdgeInsets.all(R.padding(context)),
                    child: ShimmerGrid(itemCount: 8, itemBuilder: () => const ShimmerFoodCard()),
                  )),
                ])
              : Column(children: [
                  SizedBox(height: R.isTablet(context) ? 20 : 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                    child: const ShimmerBox(width: double.infinity, height: 44, radius: 12),
                  ),
                  SizedBox(height: R.isTablet(context) ? 28 : 24),
                  Expanded(child: ShimmerGrid(itemCount: 6, itemBuilder: () => const ShimmerFoodCard())),
                ]),
        ),
      ),
    );
  }
}
