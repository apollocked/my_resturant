import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';

class _InfoItem {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final List<String> featKeys;
  final Set<Role> visibleFor;
  const _InfoItem(
    this.icon,
    this.titleKey,
    this.descKey,
    this.featKeys, {
    required this.visibleFor,
  });
}

const List<_InfoItem> _items = [
  _InfoItem(
    Icons.menu_book_outlined,
    'info_menu_title',
    'info_menu_desc',
    ['info_menu_feat_1', 'info_menu_feat_2', 'info_menu_feat_3'],
    visibleFor: {Role.waiter, Role.admin},
  ),
  _InfoItem(
    Icons.shopping_bag_outlined,
    'info_cart_title',
    'info_cart_desc',
    ['info_cart_feat_1', 'info_cart_feat_2', 'info_cart_feat_3'],
    visibleFor: {Role.waiter, Role.admin},
  ),
  _InfoItem(
    Icons.receipt_long_outlined,
    'info_kitchen_title',
    'info_kitchen_desc',
    ['info_kitchen_feat_1', 'info_kitchen_feat_2', 'info_kitchen_feat_3'],
    visibleFor: {Role.waiter, Role.kitchen, Role.admin},
  ),
  _InfoItem(
    Icons.receipt_outlined,
    'info_order_detail_title',
    'info_order_detail_desc',
    ['info_order_detail_feat_1', 'info_order_detail_feat_2', 'info_order_detail_feat_3'],
    visibleFor: {Role.waiter, Role.kitchen, Role.admin},
  ),
  _InfoItem(
    Icons.history,
    'info_history_title',
    'info_history_desc',
    ['info_history_feat_1', 'info_history_feat_2', 'info_history_feat_3'],
    visibleFor: {Role.admin},
  ),
  _InfoItem(
    Icons.bar_chart,
    'info_report_title',
    'info_report_desc',
    ['info_report_feat_1', 'info_report_feat_2', 'info_report_feat_3'],
    visibleFor: {Role.admin},
  ),
  _InfoItem(
    Icons.table_restaurant_outlined,
    'info_table_management_title',
    'info_table_management_desc',
    ['info_table_management_feat_1', 'info_table_management_feat_2'],
    visibleFor: {Role.admin},
  ),
  _InfoItem(
    Icons.restaurant_menu,
    'info_food_management_title',
    'info_food_management_desc',
    ['info_food_management_feat_1', 'info_food_management_feat_2', 'info_food_management_feat_3'],
    visibleFor: {Role.admin},
  ),
  _InfoItem(
    Icons.category_outlined,
    'info_category_management_title',
    'info_category_management_desc',
    ['info_category_management_feat_1', 'info_category_management_feat_2'],
    visibleFor: {Role.admin},
  ),
  _InfoItem(
    Icons.toggle_on_outlined,
    'info_availability_title',
    'info_availability_desc',
    ['info_availability_feat_1', 'info_availability_feat_2'],
    visibleFor: {Role.admin},
  ),
  _InfoItem(
    Icons.lock_outline,
    'info_change_pins_title',
    'info_change_pins_desc',
    ['info_change_pins_feat_1', 'info_change_pins_feat_2'],
    visibleFor: {Role.admin},
  ),
  _InfoItem(
    Icons.print_outlined,
    'info_printer_title',
    'info_printer_desc',
    ['info_printer_feat_1', 'info_printer_feat_2', 'info_printer_feat_3'],
    visibleFor: {Role.admin},
  ),
  _InfoItem(
    Icons.person_outline,
    'info_profile_title',
    'info_profile_desc',
    ['info_profile_feat_1', 'info_profile_feat_2', 'info_profile_feat_3'],
    visibleFor: {Role.waiter, Role.kitchen, Role.admin},
  ),
];

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
        _items.where((i) => i.visibleFor.contains(widget.role)).toList();
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
        ...items.asMap().entries.map((e) => _buildCard(context, e.key, e.value)),
      ],
    );
  }

  Widget _buildCard(BuildContext context, int index, _InfoItem item) {
    final cs = Theme.of(context).colorScheme;
    final isOpen = _expanded.contains(index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            setState(() {
              if (_expanded.contains(index)) {
                _expanded.remove(index);
              } else {
                _expanded.add(index);
              }
            });
          },
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
                        widget.t(item.titleKey),
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
                secondChild: _buildBody(context, item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, _InfoItem item) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            widget.t(item.descKey),
            style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 12),
          ...item.featKeys.map((k) => _buildFeat(context, widget.t(k))),
        ],
      ),
    );
  }

  Widget _buildFeat(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: R.fontSm(context), color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
