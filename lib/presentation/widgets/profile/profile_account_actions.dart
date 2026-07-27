import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class ProfileAccountActions extends StatelessWidget {
  final VoidCallback onUpdateEmail;
  final VoidCallback onUpdatePassword;
  const ProfileAccountActions({
    super.key,
    required this.onUpdateEmail,
    required this.onUpdatePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _actionCard(
          Icons.email_outlined,
          'update_email',
          onUpdateEmail,
          context,
        ),
        _actionCard(
          Icons.lock_outline,
          'update_password',
          onUpdatePassword,
          context,
        ),
      ],
    );
  }

  Widget _actionCard(
    IconData icon,
    String labelKey,
    VoidCallback onTap,
    BuildContext context,
  ) {
    final _ = Theme.of(context).colorScheme;
    return PressableScale(
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            labelKey,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: R.fontMd(context),
            ),
          ),
          trailing: const Icon(Icons.chevron_left, size: 18),
        ),
      ),
    );
  }
}
