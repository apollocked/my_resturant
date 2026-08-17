import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/widgets/profile/pin_dialog_header.dart';

class PinDialog extends StatefulWidget {
  const PinDialog({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.cancelLabel,
    required this.verifyLabel,
  });

  final Role role;
  final String title;
  final String subtitle;
  final String cancelLabel;
  final String verifyLabel;

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _submit(String value) => Navigator.of(context).pop(value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: R.isPhone(context) ? 24 : 48,
        vertical: 24,
      ),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PinDialogHeader(
                  role: widget.role,
                  title: widget.title,
                  subtitle: widget.subtitle,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _ctl,
                  autofocus: true,
                  obscureText: true,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.fontXl(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: R.fontXl(context) / 3,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                  onSubmitted: _submit,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(widget.cancelLabel),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: () => _submit(_ctl.text),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: Text(widget.verifyLabel),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
