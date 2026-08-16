import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/widgets/auth/role_card.dart';

class RoleSelectorRow extends StatelessWidget {
  const RoleSelectorRow({
    super.key,
    required this.t,
    required this.cs,
    required this.selected,
    required this.onSelected,
  });

  final String Function(String) t;
  final ColorScheme cs;
  final Role selected;
  final ValueChanged<Role> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          t('choose_role'),
          style: TextStyle(
            fontSize: R.fontMd(context),
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: Role.values
              .map(
                (r) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: RoleCard(
                      role: r,
                      selected: selected == r,
                      t: t,
                      onTap: () => onSelected(r),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
