import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class TablePickerHeader extends StatelessWidget {
  const TablePickerHeader({
    super.key,
    required this.cs,
    required this.isDesktop,
    required this.avatarSize,
    required this.iconSize,
  });

  final ColorScheme cs;
  final bool isDesktop;
  final double avatarSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: R.hp(context, isDesktop ? 4 : 2)),
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Icon(
            Icons.table_restaurant,
            size: iconSize,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: R.hp(context, isDesktop ? 5 : 3)),
        Text(
          'select_table',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? R.fontXxl(context) : R.fontXl(context),
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        SizedBox(height: R.hp(context, isDesktop ? 4 : 3)),
      ],
    );
  }
}
