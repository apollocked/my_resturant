import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/app_errors.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';

class UpdateEmailDialog extends StatefulWidget {
  const UpdateEmailDialog({super.key, required this.cubit, required this.t});

  final AccountCubit cubit;
  final String Function(String) t;

  @override
  State<UpdateEmailDialog> createState() => _UpdateEmailDialogState();
}

class _UpdateEmailDialogState extends State<UpdateEmailDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctl.text.isEmpty || !_ctl.text.contains('@')) return;
    Navigator.of(context).pop();
    try {
      await widget.cubit.updateEmail(_ctl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.t('email_updated')}. ${widget.t('email_confirmation_hint')}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.t(localizedErrorKey(e))),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.t('update_email')),
      content: TextField(
        controller: _ctl,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: widget.t('new_email'),
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.t('cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _save,
          child: Text(widget.t('save')),
        ),
      ],
    );
  }
}
