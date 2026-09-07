import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/passcode_field.dart';
import 'package:my_resturant/presentation/widgets/admin/passcode_save_button.dart';

class ChangePasscodesPage extends StatefulWidget {
  const ChangePasscodesPage({super.key});
  @override
  State<ChangePasscodesPage> createState() => _ChangePasscodesPageState();
}

class _ChangePasscodesPageState extends State<ChangePasscodesPage> {
  final _formKey = GlobalKey<FormState>();
  final _ctl = {
    Role.waiter: TextEditingController(),
    Role.kitchen: TextEditingController(),
    Role.admin: TextEditingController(),
  };
  bool _obscure = true;

  @override
  void dispose() {
    for (final c in _ctl.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final cs = Theme.of(context).colorScheme;
    String t(String key) => Tr.get(key, settings.locale);

    return Scaffold(
      appBar: AppBar(title: Text(t('change_pins'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(R.padding(context)),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      t('change_pins_hint'),
                      style: TextStyle(
                        fontSize: R.fontSm(context),
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...Role.values.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PasscodeField(
                          controller: _ctl[r]!,
                          obscure: _obscure,
                          label: t(r.name),
                          icon: _roleIcon(r),
                          t: t,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t('show_passwords'),
                            style: TextStyle(
                              fontSize: R.fontSm(context),
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Switch(
                          value: !_obscure,
                          onChanged: (v) => setState(() => _obscure = !v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    PasscodeSaveButton(label: t('save'), onTap: _save),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _roleIcon(Role r) {
    switch (r) {
      case Role.waiter:
        return Icons.room_service_outlined;
      case Role.kitchen:
        return Icons.restaurant_outlined;
      case Role.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<RoleCubit>();
    final locale = context.read<SettingsCubit>().state.locale;
    try {
      for (final r in Role.values) {
        await cubit.changePin(r, _ctl[r]!.text);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Tr.get('error_occurred', locale))),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Tr.get('pins_updated', locale))),
      );
      Navigator.pop(context);
    }
  }
}
