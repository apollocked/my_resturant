import 'package:flutter/material.dart';
import 'package:my_resturant/theme/app_theme.dart';

class NotesDialog extends StatefulWidget {
  final String initialNotes;
  const NotesDialog({super.key, required this.initialNotes});
  @override State<NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  late final TextEditingController _c;
  @override void initState() { super.initState(); _c = TextEditingController(text: widget.initialNotes); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
    title: const Text('تێبینی بۆ خواردن'),
    content: TextField(controller: _c, maxLines: 3, decoration: const InputDecoration(hintText: 'تێبینیەکانت بنووسە...')),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('ڕەتکردنەوە')),
      FilledButton(onPressed: () => Navigator.pop(context, _c.text),
        style: FilledButton.styleFrom(backgroundColor: AppTheme.primary), child: const Text('پاشەکەوت')),
    ],
  ));
}
