import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

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
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    String t(String key) => Tr.get(key, settings.state.locale);
    return Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
      title: Text(t('notes_title')),
      content: TextField(controller: _c, maxLines: 3, decoration: InputDecoration(hintText: t('notes_hint_dialog'))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t('cancel'))),
        FilledButton(onPressed: () => Navigator.pop(context, _c.text),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary), child: Text(t('save'))),
      ],
    ));
  }
}
