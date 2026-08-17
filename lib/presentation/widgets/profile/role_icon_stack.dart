import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/widgets/profile/role_phase.dart';
import 'package:my_resturant/presentation/widgets/profile/role_painters.dart';
import 'package:my_resturant/presentation/widgets/profile/role_status_badge.dart';

class RoleIconStack extends StatelessWidget {
  const RoleIconStack({
    super.key,
    required this.phase,
    required this.fromRole,
    required this.toRole,
    required this.showFrom,
    required this.orbit,
    required this.status,
  });

  final RolePhase phase;
  final Role fromRole;
  final Role toRole;
  final bool showFrom;
  final Animation<double> orbit;
  final Animation<double> status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final working = phase == RolePhase.working;
    final success = phase == RolePhase.success;
    final error = phase == RolePhase.error;
    final accent = error
        ? AppColors.error
        : success
        ? AppColors.success
        : AppColors.primary;
    return SizedBox(
      width: 152,
      height: 152,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (working)
            RotationTransition(
              turns: orbit,
              child: CustomPaint(
                size: const Size(152, 152),
                painter: OrbitRingPainter(
                  accent: AppColors.primary,
                  track: cs.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
            )
          else if (success)
            CustomPaint(
              size: const Size(152, 152),
              painter: BurstPainter(
                progress: status.value,
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
                  color: accent.withValues(alpha: !working ? 0.15 : 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween<double>(begin: 0.6, end: 1).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: error
                  ? const Icon(
                      Icons.close_rounded,
                      key: ValueKey('x'),
                      size: 40,
                      color: Colors.white,
                    )
                  : Icon(
                      (showFrom ? fromRole : toRole).icon,
                      key: ValueKey(showFrom ? 'from' : 'to'),
                      size: 40,
                      color: Colors.white,
                    ),
            ),
          ),
          RoleStatusBadge(phase: phase, status: status),
        ],
      ),
    );
  }
}
