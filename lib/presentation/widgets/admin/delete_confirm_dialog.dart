import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final String title, content;
  final String cancelLabel, deleteLabel;

  const DeleteConfirmDialog({super.key, required this.title, required this.content, required this.cancelLabel, required this.deleteLabel});

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel)),
        FilledButton(onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error), child: Text(deleteLabel)),
      ],
    ));
  }
}
