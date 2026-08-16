import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/profile/role_phase.dart';

class RoleStatusBadge extends StatelessWidget {
  const RoleStatusBadge({super.key, required this.phase, required this.status});

  final RolePhase phase;
  final Animation<double> status;

  @override
  Widget build(BuildContext context) {
    final success = phase == RolePhase.success;
    if (!success && phase != RolePhase.error) return const SizedBox.shrink();
    return Positioned(
      right: 4,
      bottom: 4,
      child: ScaleTransition(
        scale: status,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: success
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(
            success ? Icons.check_rounded : Icons.close_rounded,
            size: 22,
            color: success ? AppColors.success : AppColors.error,
          ),
        ),
      ),
    );
  }
}
