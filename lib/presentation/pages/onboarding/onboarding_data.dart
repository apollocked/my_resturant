import 'package:flutter/material.dart';

enum OnbPage {
  welcome,
  settings,
  menu,
  kitchen,
  reports;

  List<Color> get gradient => switch (this) {
        welcome  => const [Color(0xFFE8611A), Color(0xFFD44A0A), Color(0xFF8B2FC9)],
        settings => const [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
        menu     => const [Color(0xFF3B82F6), Color(0xFF6366F1), Color(0xFF8B5CF6)],
        kitchen  => const [Color(0xFFF97316), Color(0xFFEF4444), Color(0xFFEC4899)],
        reports  => const [Color(0xFF10B981), Color(0xFF06B6D4), Color(0xFF3B82F6)],
      };

  IconData get icon => switch (this) {
        welcome  => Icons.restaurant_rounded,
        settings => Icons.language_rounded,
        menu     => Icons.restaurant_menu_rounded,
        kitchen  => Icons.kitchen_rounded,
        reports  => Icons.analytics_rounded,
      };

  String get titleKey => switch (this) {
        welcome  => 'onboarding_welcome_title',
        settings => 'onboarding_settings_title',
        menu     => 'onboarding_menu_title',
        kitchen  => 'onboarding_kitchen_title',
        reports  => 'onboarding_reports_title',
      };

  String get descKey => switch (this) {
        welcome  => 'onboarding_welcome_desc',
        settings => 'onboarding_settings_desc',
        menu     => 'onboarding_menu_desc',
        kitchen  => 'onboarding_kitchen_desc',
        reports  => 'onboarding_reports_desc',
      };

  String get subKey => switch (this) {
        welcome => 'onboarding_welcome_sub',
        _       => '',
      };

  List<String> get featureKeys => switch (this) {
        welcome  => [],
        settings => [],
        menu     => ['onboarding_feat_table', 'onboarding_feat_categories', 'onboarding_feat_notes', 'onboarding_feat_search'],
        kitchen  => ['onboarding_feat_pipeline', 'onboarding_feat_notifications', 'onboarding_feat_clearing', 'onboarding_feat_status'],
        reports  => ['onboarding_feat_revenue', 'onboarding_feat_ranking', 'onboarding_feat_history', 'onboarding_feat_stats'],
      };
}
