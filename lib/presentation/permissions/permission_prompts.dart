import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/notifications/order_notification_service.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'permission_request_dialog.dart';

Future<bool> bluetoothGranted() async {
  if (kIsWeb) return false;
  try {
    return await Permission.bluetooth.isGranted;
  } catch (_) {
    return false;
  }
}

Future<bool> bluetoothPermanentlyDenied() async {
  if (kIsWeb) return true;
  try {
    return await Permission.bluetooth.isPermanentlyDenied;
  } catch (_) {
    return true;
  }
}

Future<bool> requestBluetoothSystem() async {
  if (kIsWeb) return false;
  try {
    final status = await Permission.bluetooth.request();
    return status.isGranted;
  } catch (_) {
    return false;
  }
}

/// Custom-widget prompt shown whenever the user actually uses Bluetooth
/// (scan / pair / connect) but the permission was previously denied.
Future<bool> ensureBluetoothPermission(BuildContext context) async {
  if (kIsWeb) return false;
  if (await bluetoothGranted()) return true;
  if (!context.mounted) return false;
  final settings = context.read<SettingsCubit>().state;
  String t(String key) => Tr.get(key, settings.locale);
  final permanent = await bluetoothPermanentlyDenied();
  if (!context.mounted) return false;
  final allowed = await showPermissionRequestDialog(
    context,
    icon: permanent ? Icons.settings_bluetooth : Icons.bluetooth,
    title: t(permanent ? 'bt_perm_settings_title' : 'bt_perm_title'),
    subtitle: t(permanent ? 'bt_perm_settings_sub' : 'bt_perm_sub'),
    allowLabel: t(permanent ? 'bt_perm_settings_action' : 'bt_perm_allow'),
    skipLabel: t('bt_perm_not_now'),
  );
  if (allowed != true) return false;
  if (permanent) {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }
  return requestBluetoothSystem();
}

/// Custom-widget prompt shown when the user needs notifications (kitchen /
/// waiter roles) but the permission was previously denied.
Future<bool> ensureNotificationPermission(BuildContext context) async {
  final service = OrderNotificationService();
  try {
    if (await service.areNotificationsEnabled()) return true;
  } catch (_) {}
  if (!context.mounted) return false;
  final settings = context.read<SettingsCubit>().state;
  String t(String key) => Tr.get(key, settings.locale);
  final allowed = await showPermissionRequestDialog(
    context,
    icon: Icons.notifications_active_outlined,
    title: t('notif_permission_title'),
    subtitle: t('notif_permission_subtitle'),
    allowLabel: t('notif_permission_allow'),
    skipLabel: t('notif_permission_skip'),
  );
  if (allowed != true) return false;
  try {
    return await service.requestPermission() ?? false;
  } catch (_) {
    return false;
  }
}

void promptNotificationIfNeeded(BuildContext context) {
  unawaited(ensureNotificationPermission(context));
}