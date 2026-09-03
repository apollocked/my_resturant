import 'package:flutter/services.dart';

/// Thin wrapper around HapticFeedback so every interaction site imports a
/// single, expressive API instead of the raw services class.
abstract final class Haptics {
  /// Light tap — button press, chip selection, category switch.
  static void tap() => HapticFeedback.lightImpact();

  /// Medium thud — item added to cart, quantity incremented.
  static void added() => HapticFeedback.mediumImpact();

  /// Heavy thud — destructive action, status change, error.
  static void heavy() => HapticFeedback.heavyImpact();

  /// Subtle tick — slider drag, long-press start.
  static void tick() => HapticFeedback.selectionClick();
}
