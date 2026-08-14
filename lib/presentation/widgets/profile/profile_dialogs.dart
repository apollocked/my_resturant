import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';

class ProfileDialogs {
  static Future<void> switchRole(
    BuildContext context,
    Role r,
    RoleCubit cubit,
    String Function(String) t,
  ) async {
    if (cubit.state.role == r) return;

    String? pin;
    if (cubit.state.role != Role.admin) {
      pin = await _showPinDialog(context, r, t);
      if (pin == null) return;
    }
    if (!context.mounted) return;

    final fromRole = cubit.state.role;

    final ok = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, _, _) => _RoleTransitionOverlay(
        fromRole: fromRole,
        toRole: r,
        toLabel: t(r.name),
        t: t,
        task: () => cubit.switchRole(r, pin: pin),
      ),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.88,
            end: 1,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

    if (!context.mounted) return;
    if (ok != true && cubit.state.role != r) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('pin_invalid')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  static Future<String?> _showPinDialog(
    BuildContext context,
    Role r,
    String Function(String) t,
  ) {
    return showDialog<String>(
      context: context,
      builder: (_) => _PinDialog(
        role: r,
        title: t('enter_pin_for').replaceAll('{role}', t(r.name)),
        subtitle: t('pin_hint'),
        cancelLabel: t('cancel'),
        verifyLabel: t('verify'),
      ),
    );
  }

  static void confirmLogout(
    BuildContext context,
    AccountCubit acct,
    RoleCubit role,
    String Function(String) t,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('logout')),
        content: Text(t('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await role.logout();
              await acct.logout();
              if (!context.mounted) return;
              context.go('/account-auth');
            },
            child: Text(
              t('logout'),
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  static void showUpdateEmail(
    BuildContext context,
    AccountCubit cubit,
    String Function(String) t,
  ) {
    final ctl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('update_email')),
        content: TextField(
          controller: ctl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: t('new_email'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (ctl.text.isEmpty || !ctl.text.contains('@')) return;
              Navigator.pop(ctx);
              try {
                await cubit.updateEmail(ctl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${t('email_updated')}. ${t('email_confirmation_hint')}',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    ).then(
      (_) => Future.delayed(const Duration(milliseconds: 300), ctl.dispose),
    );
  }

  static void showUpdatePassword(
    BuildContext context,
    AccountCubit cubit,
    String Function(String) t,
  ) {
    final curCtl = TextEditingController();
    final newCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('update_password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: curCtl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: t('current_password'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: t('new_password'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (curCtl.text.isEmpty || newCtl.text.length < 6) return;
              Navigator.pop(ctx);
              try {
                await cubit.updatePassword(curCtl.text, newCtl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t('password_updated')),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    ).then(
      (_) => Future.delayed(const Duration(milliseconds: 300), () {
        curCtl.dispose();
        newCtl.dispose();
      }),
    );
  }
}

enum _Phase { working, success, error }

class _PinDialog extends StatefulWidget {
  final Role role;
  final String title;
  final String subtitle;
  final String cancelLabel;
  final String verifyLabel;

  const _PinDialog({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.cancelLabel,
    required this.verifyLabel,
  });

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _submit(String value) => Navigator.of(context).pop(value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: R.isPhone(context) ? 24 : 48,
        vertical: 24,
      ),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, Color(0xFFFF8A5C)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.role.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _ctl,
                  autofocus: true,
                  obscureText: true,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.fontXl(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: R.fontXl(context) / 3,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                  onSubmitted: _submit,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(widget.cancelLabel),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: () => _submit(_ctl.text),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: Text(widget.verifyLabel),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleTransitionOverlay extends StatefulWidget {
  final Role fromRole;
  final Role toRole;
  final String toLabel;
  final String Function(String) t;
  final Future<bool> Function() task;

  const _RoleTransitionOverlay({
    required this.fromRole,
    required this.toRole,
    required this.toLabel,
    required this.t,
    required this.task,
  });

  @override
  State<_RoleTransitionOverlay> createState() => _RoleTransitionOverlayState();
}

class _RoleTransitionOverlayState extends State<_RoleTransitionOverlay>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.working;
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
      setState(() => _phase = ok ? _Phase.success : _Phase.error);
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
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final done = _phase != _Phase.working;
    final accent = _phase == _Phase.error
        ? AppColors.error
        : _phase == _Phase.success
        ? AppColors.success
        : AppColors.primary;

    final title = _phase == _Phase.working
        ? widget.t('switching_to').replaceAll('{role}', widget.toLabel)
        : widget.toLabel;
    final subtitle = _phase == _Phase.working
        ? widget.t('switching_role')
        : _phase == _Phase.success
        ? widget.t('role_switched_to').replaceAll('{role}', widget.toLabel)
        : widget.t('role_switch_failed');

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: EdgeInsets.symmetric(
          horizontal: R.isPhone(context) ? 28 : 40,
          vertical: 34,
        ),
        decoration: BoxDecoration(
          color: dark ? const Color(0xB3121A2A) : const Color(0xE6FFFFFF),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withValues(alpha: dark ? 0.10 : 0.5),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.5 : 0.14),
              blurRadius: 60,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 152,
                  height: 152,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_phase == _Phase.working)
                        RotationTransition(
                          turns: _orbit,
                          child: CustomPaint(
                            size: const Size(152, 152),
                            painter: _OrbitRingPainter(
                              accent: AppColors.primary,
                              track: cs.outlineVariant.withValues(alpha: 0.25),
                            ),
                          ),
                        )
                      else if (_phase == _Phase.success)
                        CustomPaint(
                          size: const Size(152, 152),
                          painter: _BurstPainter(
                            progress: _status.value,
                            color: AppColors.success,
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [accent, accent.withValues(alpha: 0.72)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(
                                alpha: done ? 0.25 : 0.4,
                              ),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 420),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.6,
                              end: 1,
                            ).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: _phase == _Phase.error
                              ? const Icon(
                                  Icons.close_rounded,
                                  key: ValueKey('x'),
                                  size: 40,
                                  color: Colors.white,
                                )
                              : Icon(
                                  (_showFrom ? widget.fromRole : widget.toRole)
                                      .icon,
                                  key: ValueKey(_showFrom ? 'from' : 'to'),
                                  size: 40,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      if (_phase == _Phase.success)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: ScaleTransition(
                            scale: _status,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.check_rounded,
                                size: 22,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ),
                      if (_phase == _Phase.error)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: ScaleTransition(
                            scale: _status,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.close_rounded,
                                size: 22,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: R.fontLg(context),
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Opacity(
                    key: ValueKey(_phase),
                    opacity: done ? 1 : _pulse.value,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: R.fontSm(context),
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final Color accent;
  final Color track;
  _OrbitRingPainter({required this.accent, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 6.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * 0.82,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          colors: [
            accent.withValues(alpha: 0.0),
            accent.withValues(alpha: 0.35),
            accent,
          ],
        ).createShader(arcRect),
    );

    final tipAngle = -math.pi / 2 + math.pi * 2 * 0.82;
    final tip =
        center + Offset(math.cos(tipAngle), math.sin(tipAngle)) * radius;
    canvas.drawCircle(tip, stroke * 0.9, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_OrbitRingPainter old) =>
      old.accent != accent || old.track != track;
}

class _BurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  _BurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    for (var i = 0; i < 3; i++) {
      final t = ((progress * 1.15) - i * 0.28).clamp(0.0, 1.0);
      final radius = 4 + maxRadius * t;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color.withValues(alpha: (1 - t) * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      old.progress != progress || old.color != color;
}
