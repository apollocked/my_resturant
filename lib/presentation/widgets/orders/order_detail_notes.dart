import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class OrderDetailNotes extends StatefulWidget {
  const OrderDetailNotes({
    super.key,
    required this.notes,
    required this.cs,
    required this.t,
    this.canEdit = false,
    this.onEdit,
  });

  final String notes;
  final ColorScheme cs;
  final String Function(String) t;
  final bool canEdit;
  final ValueChanged<String>? onEdit;

  @override
  State<OrderDetailNotes> createState() => _OrderDetailNotesState();
}

class _OrderDetailNotesState extends State<OrderDetailNotes> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.notes);
  }

  @override
  void didUpdateWidget(covariant OrderDetailNotes old) {
    super.didUpdateWidget(old);
    if (old.notes != widget.notes) _ctrl.text = widget.notes;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _edit() {
    final ctrl = TextEditingController(text: widget.notes);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.t('notes')),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          autofocus: true,
          decoration: InputDecoration(hintText: widget.t('order_notes_hint')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(widget.t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              widget.onEdit?.call(ctrl.text);
              Navigator.pop(ctx);
            },
            child: Text(widget.t('save')),
          ),
        ],
      ),
    ).whenComplete(ctrl.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.canEdit ? _edit : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: widget.cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: widget.canEdit
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          children: [
            if (widget.canEdit)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: Icon(
                  Icons.edit,
                  size: 14,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            if (widget.canEdit) const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.notes.isEmpty
                    ? (widget.canEdit ? widget.t('tap_to_add_notes') : '')
                    : widget.notes,
                style: TextStyle(
                  fontSize: R.fontSm(context),
                  color: widget.notes.isEmpty
                      ? widget.cs.onSurfaceVariant.withValues(alpha: 0.4)
                      : widget.cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
