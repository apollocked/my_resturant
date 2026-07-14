import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/widgets/settings_dialog.dart';

class SettingsButton extends StatelessWidget {
  final Color? color;
  const SettingsButton({super.key, this.color});
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () => showDialog(context: context, builder: (_) => const SettingsDialog()),
      child: Padding(padding: const EdgeInsets.all(6), child: Icon(Icons.settings, size: 20, color: color)));
  }
}
