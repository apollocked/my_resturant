import 'package:flutter/material.dart';

import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/features/profile/presentation/widgets/profile_info_card_body.dart';
import 'package:my_resturant/features/profile/presentation/widgets/profile_info_items.dart';

/// A tappable, expandable card in the profile info section.
class ProfileInfoCard extends StatelessWidget {
  final InfoItem item;
  final String Function(String) t;
  final bool isOpen;
  final VoidCallback onToggle;

  const ProfileInfoCard({
    super.key,
    required this.item,
    required this.t,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.softSurface(context),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(item.icon, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t(item.titleKey),
                        style: TextStyle(
                          fontSize: R.fontMd(context),
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      isOpen ? Icons.expand_less : Icons.expand_more,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState:
                    isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: ProfileInfoCardBody(item: item, t: t),
              ),
            ],
          ),
        ),
      ),
    );
  }
}