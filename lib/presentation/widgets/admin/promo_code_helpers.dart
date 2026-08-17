import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

bool isPromoExpired(Map<String, dynamic> code) {
  final expires = code['expires_at'];
  if (expires == null) return false;
  final d = DateTime.tryParse(expires.toString());
  return d != null && d.isBefore(DateTime.now());
}

String promoStatusText(Map<String, dynamic> code) {
  if (code['used_by'] != null) return 'Used';
  if (isPromoExpired(code)) return 'Expired';
  return 'Available';
}

Color promoStatusColor(Map<String, dynamic> code) {
  if (code['used_by'] != null) return AppColors.warning;
  if (isPromoExpired(code)) return AppColors.error;
  return AppColors.success;
}

IconData promoStatusIcon(Map<String, dynamic> code) {
  if (code['used_by'] != null) return Icons.lock_outline;
  if (isPromoExpired(code)) return Icons.timer_off_outlined;
  return Icons.vpn_key;
}

String formatPromoDate(dynamic v) {
  if (v == null) return '-';
  final d = DateTime.tryParse(v.toString())?.toLocal();
  if (d == null) return '-';
  return '${d.day}/${d.month}/${d.year}';
}
