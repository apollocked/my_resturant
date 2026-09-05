import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/app_errors.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';

class UpdatePasswordDialog extends StatefulWidget {
  const UpdatePasswordDialog({super.key, required this.cubit, required this.t});

  final AccountCubit cubit;
  final String Function(String) t;

  @override
  State<UpdatePasswordDialog> createState() => _UpdatePasswordDialogState();
}

class _UpdatePasswordDialogState extends State<UpdatePasswordDialog> {
  final _curCtl = TextEditingController();
  final _newCtl = TextEditingController();

  @override
  void dispose() {
    _curCtl.dispose();
    _newCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_curCtl.text.isEmpty || _newCtl.text.length < 6) return;
    Navigator.of(context).pop();
    try {
      await widget.cubit.updatePassword(_curCtl.text, _newCtl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.t('password_updated')),
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
      title: Text(widget.t('update_password')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _curCtl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: widget.t('current_password'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newCtl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: widget.t('new_password'),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
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
