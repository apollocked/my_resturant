import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final Widget? action;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.color, this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? AppColors.primary;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 104, height: 104,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: c.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Icon(icon, size: 46, color: c),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(title, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(subtitle!, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4, color: cs.onSurfaceVariant)),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 20),
          action!,
        ],
      ]),
    );
  }
}
