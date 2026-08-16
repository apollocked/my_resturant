import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/widgets/profile/role_icon_stack.dart';
import 'package:my_resturant/presentation/widgets/profile/role_overlay_card.dart';
import 'package:my_resturant/presentation/widgets/profile/role_phase.dart';
import 'package:my_resturant/presentation/widgets/profile/role_status_text.dart';

class RoleTransitionOverlay extends StatefulWidget {
  const RoleTransitionOverlay({
    super.key,
    required this.fromRole,
    required this.toRole,
    required this.toLabel,
    required this.t,
    required this.task,
  });

  final Role fromRole;
  final Role toRole;
  final String toLabel;
  final String Function(String) t;
  final Future<bool> Function() task;

  @override
  State<RoleTransitionOverlay> createState() => _RoleTransitionOverlayState();
}

class _RoleTransitionOverlayState extends State<RoleTransitionOverlay>
    with TickerProviderStateMixin {
  RolePhase _phase = RolePhase.working;
  late final AnimationController _orbit;
  late final AnimationController _status;
  late final Animation<double> _pulse;
  Timer? _iconSwap;
  Timer? _autoClose;
  bool _showFrom = true;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _pulse = Tween<double>(
      begin: 0.55,
      end: 1,
    ).animate(CurvedAnimation(parent: _orbit, curve: Curves.easeInOut));
    _status = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _iconSwap = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showFrom = false);
    });
    _run();
  }

  Future<bool> _safeTask() async {
    try {
      return await widget.task();
    } catch (_) {
      return false;
    }
  }

  void _run() {
    _safeTask().then((ok) {
      if (!mounted) return;
      _iconSwap?.cancel();
      _orbit.stop();
      setState(() => _phase = ok ? RolePhase.success : RolePhase.error);
      _status.forward();
      if (ok) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
      _autoClose = Timer(
        ok
            ? const Duration(milliseconds: 1500)
            : const Duration(milliseconds: 1900),
        () {
          if (mounted) Navigator.of(context).pop(ok);
        },
      );
    });
  }

  @override
  void dispose() {
    _orbit.dispose();
    _status.dispose();
    _iconSwap?.cancel();
    _autoClose?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _phase != RolePhase.working;
    final title = _phase == RolePhase.working
        ? widget.t('switching_to').replaceAll('{role}', widget.toLabel)
        : widget.toLabel;
    final subtitle = _phase == RolePhase.working
        ? widget.t('switching_role')
        : _phase == RolePhase.success
        ? widget.t('role_switched_to').replaceAll('{role}', widget.toLabel)
        : widget.t('role_switch_failed');

    return Center(
      child: RoleOverlayCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoleIconStack(
              phase: _phase,
              fromRole: widget.fromRole,
              toRole: widget.toRole,
              showFrom: _showFrom,
              orbit: _orbit,
              status: _status,
            ),
            const SizedBox(height: 24),
            RoleStatusTexts(
              title: title,
              subtitle: subtitle,
              done: done,
              pulse: _pulse,
            ),
          ],
        ),
      ),
    );
  }
}
