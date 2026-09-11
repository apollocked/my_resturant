import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Describes which Rive asset, artboard, state machine and boolean input an
/// icon uses.
///
/// This spec-driven design lets the app render each nav icon from its own
/// Rive artboard/state machine today (the bundled demo pack), and lets you swap
/// in your own authored file later without touching the widget.
class NavRiveSpec {
  final String assetPath;
  final String artboard;
  final String stateMachine;
  final String input;

  const NavRiveSpec({
    required this.assetPath,
    required this.artboard,
    required this.stateMachine,
    required this.input,
  });

  /// Demo pack: Rive's official UI-kit icon pack (bundled below). One artboard
  /// per icon, each with its own `<ICON>_Interactivity` state machine and a
  /// single boolean input `active` that plays the icon's active animation.
  static const String currentPack = 'assets/rive/icons.riv';

  /// Maps a nav label key to its Rive spec.
  ///
  /// To use your own icons: export your file to [currentPack] (or a new path)
  /// and point each label at the matching artboard/state machine/input.
  static NavRiveSpec forLabel(String labelKey) {
    switch (labelKey) {
      case 'cart':
        return const NavRiveSpec(
          assetPath: currentPack,
          artboard: 'STAR',
          stateMachine: 'STAR_Interactivity',
          input: 'active',
        );
      case 'menu':
        return const NavRiveSpec(
          assetPath: currentPack,
          artboard: 'HOME',
          stateMachine: 'HOME_interactivity',
          input: 'active',
        );
      case 'orders':
        return const NavRiveSpec(
          assetPath: currentPack,
          artboard: 'TIMER',
          stateMachine: 'TIMER_Interactivity',
          input: 'active',
        );
      case 'kitchen':
        return const NavRiveSpec(
          assetPath: currentPack,
          artboard: 'TIMER',
          stateMachine: 'TIMER_Interactivity',
          input: 'active',
        );
      case 'history':
        return const NavRiveSpec(
          assetPath: currentPack,
          artboard: 'RELOAD',
          stateMachine: 'RELOAD_Interactivity',
          input: 'active',
        );
      case 'profile':
        return const NavRiveSpec(
          assetPath: currentPack,
          artboard: 'USER',
          stateMachine: 'USER_Interactivity',
          input: 'active',
        );
    }
    return const NavRiveSpec(
      assetPath: currentPack,
      artboard: 'USER',
      stateMachine: 'USER_Interactivity',
      input: 'active',
    );
  }
}

/// A Rive-driven nav icon that plays its active animation when [active] flips
/// to true and returns to its idle visual when [active] flips to false.
///
/// The Rive asset is validated on startup before the artboard is shown. When
/// the file is missing or does not match [NavRiveSpec], this widget gracefully
/// falls back to the classic Material icon so the nav bar always renders.
class NavRiveIcon extends StatefulWidget {
  final NavRiveSpec spec;
  final bool active;
  final IconData icon;
  final IconData activeIcon;
  final Color color;
  final Color inactiveColor;
  final double size;

  const NavRiveIcon({
    super.key,
    required this.spec,
    required this.active,
    required this.icon,
    required this.activeIcon,
    required this.color,
    required this.inactiveColor,
    this.size = 24,
  });

  @override
  State<NavRiveIcon> createState() => _NavRiveIconState();
}

class _NavRiveIconState extends State<NavRiveIcon> {
  bool _available = false;
  StateMachineController? _controller;
  SMIBool? _input;

  @override
  void initState() {
    super.initState();
    _checkAsset();
  }

  Future<void> _checkAsset() async {
    try {
      final riveFile = await RiveFile.asset(widget.spec.assetPath);
      final artboard = riveFile.artboardByName(widget.spec.artboard);
      if (artboard == null) {
        throw StateError('Artboard ${widget.spec.artboard} not found');
      }
      final controller =
          StateMachineController.fromArtboard(artboard, widget.spec.stateMachine);
      if (controller == null) {
        throw StateError(
          'State machine ${widget.spec.stateMachine} not found',
        );
      }
      if (controller.findInput<bool>(widget.spec.input) == null) {
        controller.dispose();
        throw StateError('Input ${widget.spec.input} not found');
      }
      controller.dispose();
      if (mounted) {
        setState(() => _available = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _available = false);
      }
    }
  }

  void _onInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      widget.spec.stateMachine,
    );
    if (controller == null) {
      return;
    }
    artboard.addController(controller);
    _controller = controller;
    _input = controller.findInput<bool>(widget.spec.input) as SMIBool?;
    _input?.value = widget.active;
  }

  @override
  void didUpdateWidget(covariant NavRiveIcon old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active && _input != null) {
      _input!.value = widget.active;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_available) {
      return RiveAnimation.asset(
        widget.spec.assetPath,
        artboard: widget.spec.artboard,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        onInit: _onInit,
      );
    }
    return Icon(
      widget.active ? widget.activeIcon : widget.icon,
      size: widget.size,
      color: widget.active ? widget.color : widget.inactiveColor,
    );
  }
}