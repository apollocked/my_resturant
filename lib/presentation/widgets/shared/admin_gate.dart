import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/cubits/admin_auth_cubit.dart';

class AdminGate extends StatefulWidget {
  final WidgetBuilder builder;
  const AdminGate({super.key, required this.builder});

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPin());
  }

  Future<void> _checkPin() async {
    if (context.read<AdminAuthCubit>().state.authenticated) return;
    final pinCtl = TextEditingController();
    final locale = context.read<SettingsCubit>().state.locale;
    String t(String key) => Tr.get(key, locale);
    final pin = await showDialog<String>(context: context,
      builder: (ctx) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
        title: Text(t('admin_pin_title')),
        content: TextField(
          controller: pinCtl, obscureText: true, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: t('admin_pin_hint'), border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, pinCtl.text),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary), child: Text(t('verify'))),
        ],
      )),
    );
    if (pin == null) { if (mounted) Navigator.of(context).maybePop(); return; }
    if (mounted) {
      final authed = context.read<AdminAuthCubit>().authenticate(pin);
      if (!authed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('admin_pin_invalid'))));
        WidgetsBinding.instance.addPostFrameCallback((_) => _checkPin());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return context.watch<AdminAuthCubit>().state.authenticated
      ? widget.builder(context) : const SizedBox.shrink();
  }
}
