import 'package:flutter/material.dart';
import 'package:my_resturant/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final String? sub;
  final Color color;
  const StatCard({super.key, required this.icon, required this.label, required this.value, this.sub, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: color)),
        const Spacer(),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ]),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
      if (sub != null) Text(sub!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ])));
  }
}
