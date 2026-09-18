import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/orders/data/order_notification_service.dart';
import 'package:my_resturant/features/permissions/presentation/permission_gate.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/permissions/presentation/permission_prompts.dart';

enum PermissionPhase { loading, notifications, bluetooth, done }

/// One-time onboarding flow: asks for notifications then Bluetooth, tracking
/// what has been asked in SharedPreferences so real actions can re-ask later.
mixin PermissionFlowMixin on State<PermissionGate> {
  PermissionPhase phase = PermissionPhase.loading;
  bool busy = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final notifAsked = prefs.getBool('notif_permission_prompt') ?? false;
    final btAsked = prefs.getBool('bt_permission_prompt') ?? false;
    bool notifGranted = false;
    try {
      notifGranted = await OrderNotificationService().areNotificationsEnabled();
    } catch (_) {}
    final btGranted = await bluetoothGranted();
    if (!mounted) return;
    if (!notifAsked && !notifGranted) {
      setState(() => phase = PermissionPhase.notifications);
    } else if (!btAsked && !btGranted) {
      setState(() => phase = PermissionPhase.bluetooth);
    } else {
      setState(() => phase = PermissionPhase.done);
    }
  }

  Future<void> allow() async {
    if (busy) return;
    setState(() => busy = true);
    final prefs = await SharedPreferences.getInstance();
    if (phase == PermissionPhase.notifications) {
      await prefs.setBool('notif_permission_prompt', true);
      bool granted = false;
      try {
        granted = (await OrderNotificationService().requestPermission()) == true;
      } catch (_) {}
      if (!mounted) return;
      setState(() => busy = false);
      // If the system request was denied, show a brief snackbar with an
      // "Open settings" action so the user can fix it manually.
      if (!granted) _showBlockedSnackbar();
      await advance();
    } else {
      await prefs.setBool('bt_permission_prompt', true);
      final granted = await requestBluetoothSystem();
      if (!mounted) return;
      setState(() => busy = false);
      if (!granted) _showBlockedSnackbar();
      await advance();
    }
  }

  Future<void> skip() async {
    if (busy) return;
    setState(() => busy = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      phase == PermissionPhase.notifications
          ? 'notif_permission_prompt'
          : 'bt_permission_prompt',
      true,
    );
    if (!mounted) return;
    setState(() => busy = false);
    await advance();
  }

  Future<void> advance() async {
    if (phase == PermissionPhase.notifications) {
      final prefs = await SharedPreferences.getInstance();
      final btAsked = prefs.getBool('bt_permission_prompt') ?? false;
      final btGranted = await bluetoothGranted();
      if (!mounted) return;
      setState(() {
        phase = !btAsked && !btGranted
            ? PermissionPhase.bluetooth
            : PermissionPhase.done;
      });
      return;
    }
    setState(() => phase = PermissionPhase.done);
  }

  void _showBlockedSnackbar() {
    if (!mounted) return;
    final settings = context.read<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('permission_denied_snackbar')),
        action: SnackBarAction(
          label: t('bt_perm_settings_action'),
          textColor: cs.primary,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }
}