import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.roleName,
    required this.email,
    required this.t,
    required this.cs,
  });

  final String roleName;
  final String? email;
  final String Function(String) t;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const ProfileAvatar(),
        const SizedBox(height: 12),
        Center(
          child: Text(
            roleName,
            style: TextStyle(
              fontSize: R.fontXl(context),
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            t('restaurant_name'),
            style: TextStyle(
              fontSize: R.fontSm(context),
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        Center(
          child: Text(
            email ?? '',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
