import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/permissions/presentation/permission_flow.dart';
import 'package:my_resturant/features/permissions/presentation/permission_request_view.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';

/// Asks for notifications and Bluetooth once, on the first app open, using the
/// app's own widgets. If the user later denies them, the per-action prompts in
/// [permission_prompts.dart] re-ask at the moment they are actually needed.
class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate>
    with PermissionFlowMixin {
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case PermissionPhase.loading:
        return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor);
      case PermissionPhase.notifications:
      case PermissionPhase.bluetooth:
        final notifications = phase == PermissionPhase.notifications;
        final settings = context.watch<SettingsCubit>().state;
        String t(String key) => Tr.get(key, settings.locale);
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: PermissionRequestView(
                    icon: notifications
                        ? Icons.notifications_active_outlined
                        : Icons.bluetooth,
                    title: t(
                      notifications ? 'notif_permission_title' : 'bt_perm_title',
                    ),
                    subtitle: t(
                      notifications ? 'notif_permission_subtitle' : 'bt_perm_sub',
                    ),
                    allowLabel: t(
                      notifications ? 'notif_permission_allow' : 'bt_perm_allow',
                    ),
                    skipLabel: t(
                      notifications ? 'notif_permission_skip' : 'bt_perm_not_now',
                    ),
                    busy: busy,
                    onAllow: allow,
                    onSkip: skip,
                  ),
                ),
              ),
            ),
          ),
        );
      case PermissionPhase.done:
        return widget.child;
    }
  }
}