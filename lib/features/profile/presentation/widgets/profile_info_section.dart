import 'package:flutter/material.dart';

import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';
import 'package:my_resturant/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:my_resturant/features/profile/presentation/widgets/profile_info_items.dart';

/// The profile helpers section: a role-filtered list of tappable info cards,
/// all collapsed except the first one opened.
class ProfileInfoSection extends StatefulWidget {
  final Role role;
  final String Function(String) t;
  final bool showHeader;

  const ProfileInfoSection({
    super.key,
    required this.role,
    required this.t,
    this.showHeader = true,
  });

  @override
  State<ProfileInfoSection> createState() => _ProfileInfoSectionState();
}

class _ProfileInfoSectionState extends State<ProfileInfoSection> {
  final Set<int> _expanded = {0};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items =
        kProfileInfoItems.where((i) => i.visibleFor.contains(widget.role)).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.help_outline, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                widget.t('info_section_title'),
                style: TextStyle(
                  fontSize: R.fontLg(context),
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.t('info_section_subtitle'),
            style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
        ],
        ...items.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value;
          return ProfileInfoCard(
            item: item,
            t: widget.t,
            isOpen: _expanded.contains(index),
            onToggle: () => setState(() {
              if (_expanded.contains(index)) {
                _expanded.remove(index);
              } else {
                _expanded.add(index);
              }
            }),
          );
        }),
      ],
    );
  }
}