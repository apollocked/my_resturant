import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/notifications/order_notification_service.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'permission_prompts.dart';
import 'permission_request_view.dart';

enum _Phase { loading, notifications, bluetooth, done }

/// Asks for notifications and Bluetooth once, on the first app open, using the
/// app's own widgets. If the user later denies them, the per-action prompts in
/// [permission_prompts.dart] re-ask at the moment they are actually needed.
class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  _Phase _phase = _Phase.loading;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
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
      setState(() => _phase = _Phase.notifications);
    } else if (!btAsked && !btGranted) {
      setState(() => _phase = _Phase.bluetooth);
    } else {
      setState(() => _phase = _Phase.done);
    }
  }

  Future<void> _allow() async {
    if (_busy) return;
    setState(() => _busy = true);
    final prefs = await SharedPreferences.getInstance();
    if (_phase == _Phase.notifications) {
      await prefs.setBool('notif_permission_prompt', true);
      try {
        await OrderNotificationService().requestPermission();
      } catch (_) {}
    } else {
      await prefs.setBool('bt_permission_prompt', true);
      await requestBluetoothSystem();
    }
    if (!mounted) return;
    setState(() => _busy = false);
    await _advance();
  }

  Future<void> _skip() async {
    if (_busy) return;
    setState(() => _busy = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _phase == _Phase.notifications
          ? 'notif_permission_prompt'
          : 'bt_permission_prompt',
      true,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    await _advance();
  }

  Future<void> _advance() async {
    if (_phase == _Phase.notifications) {
      final prefs = await SharedPreferences.getInstance();
      final btAsked = prefs.getBool('bt_permission_prompt') ?? false;
      final btGranted = await bluetoothGranted();
      if (!mounted) return;
      if (!btAsked && !btGranted) {
        setState(() => _phase = _Phase.bluetooth);
      } else {
        setState(() => _phase = _Phase.done);
      }
      return;
    }
    setState(() => _phase = _Phase.done);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.loading:
        return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor);
      case _Phase.notifications:
      case _Phase.bluetooth:
        final notifications = _phase == _Phase.notifications;
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
                    busy: _busy,
                    onAllow: _allow,
                    onSkip: _skip,
                  ),
                ),
              ),
            ),
          ),
        );
      case _Phase.done:
        return widget.child;
    }
  }
}