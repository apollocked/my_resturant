import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/pages/onboarding/onb_colors.dart';
import 'package:my_resturant/presentation/pages/onboarding/settings_widgets.dart';

class OnboardingSettingsPage extends StatelessWidget {
  final String Function(String) t;
  const OnboardingSettingsPage({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final pad = R.padding(context);
    final settings = context.watch<SettingsCubit>().state;
    final ob = OnbColors.of(context);
    final currentLocale = settings.locale;
    final currentTheme = settings.themeMode;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            GlowingSettingIcon(ob: ob),
            const SizedBox(height: 36),
            Text(t('onboarding_settings_title'), style: TextStyle(fontSize: R.fontXl(context) + 4, fontWeight: FontWeight.w900, color: ob.textPrimary, letterSpacing: -0.5, height: 1.15), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(t('onboarding_settings_desc'), textAlign: TextAlign.center, style: TextStyle(fontSize: R.fontMd(context), color: ob.textSecondary, height: 1.55)),
            const SizedBox(height: 36),
            SectionLabel(label: t('onboarding_select_language'), ob: ob),
            const SizedBox(height: 12),
            LanguageOption(label: t('kurdish'), flag: ' Kurdish', locale: const Locale('ku'), isSelected: currentLocale.languageCode == 'ku', onTap: () => context.read<SettingsCubit>().setLocale(const Locale('ku')), ob: ob),
            const SizedBox(height: 10),
            LanguageOption(label: t('arabic'), flag: ' Arabic', locale: const Locale('ar'), isSelected: currentLocale.languageCode == 'ar', onTap: () => context.read<SettingsCubit>().setLocale(const Locale('ar')), ob: ob),
            const SizedBox(height: 10),
            LanguageOption(label: t('english'), flag: ' English', locale: const Locale('en'), isSelected: currentLocale.languageCode == 'en', onTap: () => context.read<SettingsCubit>().setLocale(const Locale('en')), ob: ob),
            const SizedBox(height: 32),
            SectionLabel(label: t('onboarding_select_theme'), ob: ob),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ThemeOption(label: t('onboarding_light_mode'), icon: Icons.light_mode_rounded, isSelected: currentTheme == ThemeMode.light, onTap: () => context.read<SettingsCubit>().setThemeMode(ThemeMode.light), ob: ob)),
                const SizedBox(width: 12),
                Expanded(child: ThemeOption(label: t('onboarding_dark_mode'), icon: Icons.dark_mode_rounded, isSelected: currentTheme == ThemeMode.dark, onTap: () => context.read<SettingsCubit>().setThemeMode(ThemeMode.dark), ob: ob)),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
