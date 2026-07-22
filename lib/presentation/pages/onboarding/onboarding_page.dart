import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  late final PageController _pageCtl;
  int _page = 0;

  static const _accentColors = [
    Color(0xFFE8611A),
    Color(0xFF3B82F6),
    Color(0xFF2EC153),
    Color(0xFF8B5CF6),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtl = PageController();
  }

  @override
  void dispose() {
    _pageCtl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _pageCtl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() async {
    await context.read<SettingsCubit>().completeOnboarding();
    if (mounted) context.go('/account-auth');
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final cs = Theme.of(context).colorScheme;
    String t(String key) => Tr.get(key, settings.locale);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: _page < 3
                    ? TextButton(
                        onPressed: _finish,
                        child: Text(t('onboarding_skip'),
                            style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 15)),
                      )
                    : const SizedBox(height: 48),
              ),
              Expanded(
                child: PageView(
                  controller: _pageCtl,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _WelcomePage(t: t),
                    _FeaturePage(
                      accent: _accentColors[0],
                      icon: Icons.restaurant_menu_rounded,
                      title: t('onboarding_menu_title'),
                      desc: t('onboarding_menu_desc'),
                      features: [t('onboarding_feat_table'), t('onboarding_feat_categories'), t('onboarding_feat_notes'), t('onboarding_feat_search')],
                      t: t,
                    ),
                    _FeaturePage(
                      accent: _accentColors[1],
                      icon: Icons.kitchen_rounded,
                      title: t('onboarding_kitchen_title'),
                      desc: t('onboarding_kitchen_desc'),
                      features: [t('onboarding_feat_pipeline'), t('onboarding_feat_notifications'), t('onboarding_feat_clearing'), t('onboarding_feat_status')],
                      t: t,
                    ),
                    _FeaturePage(
                      accent: _accentColors[2],
                      icon: Icons.analytics_rounded,
                      title: t('onboarding_reports_title'),
                      desc: t('onboarding_reports_desc'),
                      features: [t('onboarding_feat_revenue'), t('onboarding_feat_ranking'), t('onboarding_feat_history'), t('onboarding_feat_stats')],
                      t: t,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(R.padding(context), 0, R.padding(context), R.padding(context)),
                child: Row(
                  children: [
                    ...List.generate(4, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: _page == i ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i ? _accentColors[_page] : cs.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                    const Spacer(),
                    PressableScale(
                      onTap: _next,
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        decoration: BoxDecoration(
                          color: _accentColors[_page],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _page < 3 ? t('onboarding_next') : t('onboarding_get_started'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            Icon(_page < 3 ? Icons.arrow_forward_rounded : Icons.check_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final String Function(String) t;
  const _WelcomePage({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8611A), Color(0xFFD44A0A), Color(0xFFB73E08)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: ClipOval(
                  child: Image.asset('assets/icons/my Restaurant.png', width: 96, height: 96, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(t('onboarding_welcome_title'),
              style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(t('onboarding_welcome_sub'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 17, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(t('onboarding_welcome_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _FeaturePage extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title, desc;
  final List<String> features;
  final String Function(String) t;

  const _FeaturePage({
    required this.accent,
    required this.icon,
    required this.title,
    required this.desc,
    required this.features,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(R.padding(context)),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: accent),
          ),
          const SizedBox(height: 32),
          Text(title,
              style: TextStyle(fontSize: R.fontXl(context), fontWeight: FontWeight.w900, color: cs.onSurface)),
          const SizedBox(height: 12),
          Text(desc,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: R.fontMd(context), color: cs.onSurfaceVariant, height: 1.5)),
          const SizedBox(height: 32),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.check_rounded, size: 18, color: accent),
                ),
                const SizedBox(width: 14),
                Text(f, style: TextStyle(fontSize: R.fontMd(context), fontWeight: FontWeight.w600, color: cs.onSurface)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
