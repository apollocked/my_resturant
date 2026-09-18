import 'package:flutter/material.dart';

import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/features/profile/presentation/widgets/profile_info_feat_row.dart';
import 'package:my_resturant/features/profile/presentation/widgets/profile_info_items.dart';

/// The scroll-out section of an expandable profile info card: a short
/// description followed by the card's feature checklist.
class ProfileInfoCardBody extends StatelessWidget {
  final InfoItem item;
  final String Function(String) t;

  const ProfileInfoCardBody({super.key, required this.item, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            t(item.descKey),
            style: TextStyle(
              fontSize: R.fontSm(context),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...item.featKeys.map((k) => ProfileInfoFeatRow(label: t(k))),
        ],
      ),
    );
  }
}