import 'package:flutter/material.dart';
import 'permission_request_view.dart';

/// Shows the branded permission request as a dialog. Returns `true` when the
/// user taps the allow action, `false` when skipped, `null` when dismissed.
Future<bool?> showPermissionRequestDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required String allowLabel,
  required String skipLabel,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: PermissionRequestView(
          icon: icon,
          title: title,
          subtitle: subtitle,
          allowLabel: allowLabel,
          skipLabel: skipLabel,
          onAllow: () => Navigator.pop(context, true),
          onSkip: () => Navigator.pop(context, false),
        ),
      ),
    ),
  );
}