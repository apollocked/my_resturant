import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/profile/settings_option_button.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});
  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: R.fontMd(context),
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cubit = context.read<SettingsCubit>();
    final isRtl = settings.locale.languageCode != 'en';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: AlertDialog(
        title: Text(
          t('settings'),
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionTitle(t('theme')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SettingsOptionButton(
                      label: t('light'),
                      selected: settings.themeMode == ThemeMode.light,
                      onPressed: () => cubit.setThemeMode(ThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SettingsOptionButton(
                      label: t('dark'),
                      selected: settings.themeMode == ThemeMode.dark,
                      onPressed: () => cubit.setThemeMode(ThemeMode.dark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle(t('language')),
              const SizedBox(height: 8),
              SettingsOptionButton(
                label: t('kurdish'),
                selected: settings.locale == const Locale('ku'),
                onPressed: () => cubit.setLocale(const Locale('ku')),
              ),
              const SizedBox(height: 6),
              SettingsOptionButton(
                label: t('arabic'),
                selected: settings.locale == const Locale('ar'),
                onPressed: () => cubit.setLocale(const Locale('ar')),
              ),
              const SizedBox(height: 6),
              SettingsOptionButton(
                label: t('english'),
                selected: settings.locale == const Locale('en'),
                onPressed: () => cubit.setLocale(const Locale('en')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
        ],
      ),
    );
  }
}
