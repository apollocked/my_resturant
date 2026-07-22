import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

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
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  t('change_pins_hint'),
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                ...Role.values.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _field(r, _ctl[r]!, t, cs),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      t('show_passwords'),
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Switch(
                      value: !_obscure,
                      onChanged: (v) => setState(() => _obscure = !v),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: PressableScale(
                    onTap: _save,
                    child: FilledButton(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        t('save'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    Role r,
    TextEditingController ctl,
    String Function(String) t,
    ColorScheme cs,
  ) {
    return TextFormField(
      controller: ctl,
      obscureText: _obscure,
      maxLength: 6,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: '',
        labelText: t(r.name),
        prefixIcon: Icon(_roleIcon(r), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      validator: (v) => v == null || v.isEmpty
          ? t('pin_required')
          : v.length < 4
          ? t('pin_too_short')
          : null,
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
    for (final r in Role.values) {
      await cubit.changePin(r, _ctl[r]!.text);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Tr.get('pins_updated', context.read<SettingsCubit>().state.locale),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}
