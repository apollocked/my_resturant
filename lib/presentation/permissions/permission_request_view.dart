import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

/// Branded permission prompt built entirely from the app's own widgets
/// (never the system prompt). Used both as a full screen on first launch and
/// inside a dialog for contextual re-prompts after a denial.
class PermissionRequestView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String allowLabel;
  final String skipLabel;
  final bool busy;
  final VoidCallback? onAllow;
  final VoidCallback? onSkip;

  const PermissionRequestView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.allowLabel,
    required this.skipLabel,
    this.busy = false,
    this.onAllow,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.softSurface(context),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 46, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 26),
        FilledButton.icon(
          onPressed: busy ? null : onAllow,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(allowLabel),
          ),
        ),
        const SizedBox(height: 6),
        TextButton(onPressed: busy ? null : onSkip, child: Text(skipLabel)),
      ],
    );
  }
}