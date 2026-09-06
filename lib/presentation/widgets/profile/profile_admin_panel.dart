import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/profile/admin_action_row.dart';
import 'package:my_resturant/presentation/widgets/profile/admin_panel_card.dart';

class ProfileAdminPanel extends StatelessWidget {
  final String Function(String) t;
  const ProfileAdminPanel({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final isDesktop = R.isDesktop(context);
    final cards = _buildCards(context);

    return Column(
      children: [
        const SizedBox(height: 10),
        AdminActionRow(t: t),
        const SizedBox(height: 24),
        if (isDesktop)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: R.gridSpacing(context),
            mainAxisSpacing: R.gridSpacing(context),
            childAspectRatio: 1.5,
            children: cards,
          )
        else
          ...cards,
      ],
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    return [
      AdminPanelCard(
        icon: Icons.table_restaurant_outlined,
        title: t('table_management'),
        sub: t('table_management_sub'),
        route: '/table-management',
      ),
      AdminPanelCard(
        icon: Icons.restaurant_menu,
        title: t('food_management'),
        sub: t('food_management_sub'),
        route: '/food-management',
      ),
      AdminPanelCard(
        icon: Icons.category_outlined,
        title: t('category_management'),
        sub: t('category_management_sub'),
        route: '/category-management',
      ),
      AdminPanelCard(
        icon: Icons.toggle_on_outlined,
        title: t('available_foods'),
        sub: t('available_foods_sub'),
        route: '/availability',
      ),
      AdminPanelCard(
        icon: Icons.bar_chart,
        title: t('report'),
        sub: t('report_sub'),
        route: '/report',
      ),
    ];
  }
}
