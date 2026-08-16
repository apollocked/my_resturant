import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/widgets/profile/admin_action_button.dart';

class AdminActionRow extends StatelessWidget {
  const AdminActionRow({super.key, required this.t});

  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AdminActionButton(
            icon: Icons.table_restaurant_outlined,
            label: t('add_table'),
            route: '/table-management',
            t: t,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AdminActionButton(
            icon: Icons.restaurant_menu,
            label: t('add_food'),
            route: '/dish-form',
            t: t,
          ),
        ),
      ],
    );
  }
}
