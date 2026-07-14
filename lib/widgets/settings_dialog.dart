import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/cubits/settings_cubit.dart';
import 'package:my_resturant/l10n/tr.dart';
import 'package:my_resturant/theme/app_theme.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});
  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final isRtl = settings.locale.languageCode != 'en';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: AlertDialog(
        title: Text(t('settings'), textAlign: isRtl ? TextAlign.right : TextAlign.left),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(t('theme'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _themeBtn(context, t('light'), ThemeMode.light, settings.themeMode)),
            const SizedBox(width: 8),
            Expanded(child: _themeBtn(context, t('dark'), ThemeMode.dark, settings.themeMode)),
          ]),
          const SizedBox(height: 20),
          Text(t('language'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          _langBtn(context, t('kurdish'), const Locale('ku'), settings.locale),
          const SizedBox(height: 6),
          _langBtn(context, t('arabic'), const Locale('ar'), settings.locale),
          const SizedBox(height: 6),
          _langBtn(context, t('english'), const Locale('en'), settings.locale),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t('cancel')))],
      ),
    );
  }

  Widget _themeBtn(BuildContext context, String label, ThemeMode mode, ThemeMode current) {
    final sel = mode == current;
    return SizedBox(height: 40, child: OutlinedButton(
      onPressed: () => context.read<SettingsCubit>().setThemeMode(mode),
      style: OutlinedButton.styleFrom(
        backgroundColor: sel ? AppTheme.primary : Colors.white,
        foregroundColor: sel ? Colors.white : AppTheme.textPrimary,
        side: BorderSide(color: sel ? AppTheme.primary : const Color(0xFFE0DCD8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ));
  }

  Widget _langBtn(BuildContext context, String label, Locale locale, Locale current) {
    final sel = locale == current;
    return SizedBox(height: 40, child: OutlinedButton(
      onPressed: () => context.read<SettingsCubit>().setLocale(locale),
      style: OutlinedButton.styleFrom(
        backgroundColor: sel ? AppTheme.primary : Colors.white,
        foregroundColor: sel ? Colors.white : AppTheme.textPrimary,
        side: BorderSide(color: sel ? AppTheme.primary : const Color(0xFFE0DCD8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ));
  }
}
