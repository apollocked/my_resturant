import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class AdminPanelCard extends StatelessWidget {
  const AdminPanelCard({
    super.key,
    required this.icon,
    required this.title,
    required this.sub,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String sub;
  final String route;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        onTap: () => context.push(route),
        child: Card(
          child: ListTile(
            leading: Icon(icon, color: AppColors.primary),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: R.fontMd(context),
              ),
            ),
            subtitle: Text(
              sub,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.fontSm(context),
                color: cs.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
