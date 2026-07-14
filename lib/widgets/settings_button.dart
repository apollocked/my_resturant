import 'package:flutter/material.dart';
import 'package:my_resturant/widgets/settings_dialog.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () => showDialog(context: context, builder: (_) => const SettingsDialog()),
      child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.settings, size: 20)));
  }
}
