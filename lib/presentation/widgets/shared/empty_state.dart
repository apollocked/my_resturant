import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 100, height: 100, decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
        child: Icon(icon, size: 44, color: cs.onSurfaceVariant)),
      const SizedBox(height: 20),
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
      if (subtitle != null) ...[
        const SizedBox(height: 6),
        Text(subtitle!, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
      ],
    ]));
  }
}
