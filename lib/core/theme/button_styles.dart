import 'package:flutter/material.dart';

/// Physical "real button" styles for Material buttons.
///
/// While pressed, a button darkens its overlay and deepens its shadow so it
/// visibly depresses like a physical key, then springs back on release.
/// Handles both filled/elevated buttons and outlined buttons.
abstract final class PhysicalButtons {
  static const double _radius = 12;
  static const EdgeInsetsGeometry _padding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );
  static const TextStyle _text = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
  );

  /// Filled / elevated buttons: solid background that darkens and gets a
  /// deeper shadow on press.
  static ButtonStyle filled({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color overlayColor,
    required Color shadowColor,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? null
            : backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        // Don't override a button's own disabledForegroundColor (set via
        // styleFrom) — let it fall back to the button's explicit value.
        return states.contains(WidgetState.disabled)
            ? null
            : foregroundColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.pressed)
            ? overlayColor
            : Colors.transparent;
      }),
      shadowColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.pressed)
            ? shadowColor.withValues(alpha: 0.35)
            : shadowColor.withValues(alpha: 0.1);
      }),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
        ),
      ),
      padding: const WidgetStatePropertyAll(_padding),
      textStyle: const WidgetStatePropertyAll(_text),
    );
  }

  /// Outlined buttons: transparent fill with a border that darkens on press.
  static ButtonStyle outlined({
    required Color foregroundColor,
    required Color overlayColor,
    required Color shadowColor,
  }) {
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? null
            : foregroundColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.pressed)
            ? overlayColor
            : Colors.transparent;
      }),
      shadowColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.pressed)
            ? shadowColor.withValues(alpha: 0.2)
            : Colors.transparent;
      }),
      side: WidgetStateProperty.all(
        BorderSide(color: foregroundColor.withValues(alpha: 0.4)),
      ),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
        ),
      ),
      padding: const WidgetStatePropertyAll(_padding),
      textStyle: const WidgetStatePropertyAll(_text),
      elevation: const WidgetStatePropertyAll(0),
    );
  }

  /// Text buttons: no fill, just a colored label that darkens on press.
  static ButtonStyle text({
    required Color foregroundColor,
    required Color overlayColor,
  }) {
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? null
            : foregroundColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.pressed)
            ? overlayColor
            : Colors.transparent;
      }),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}