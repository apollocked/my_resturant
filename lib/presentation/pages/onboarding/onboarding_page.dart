import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/onboarding/mesh_background.dart';
import 'package:my_resturant/presentation/widgets/onboarding/onboarding_bottom_bar.dart';
import 'package:my_resturant/presentation/pages/onboarding/onboarding_data.dart';
import 'package:my_resturant/presentation/pages/onboarding/skip_button.dart';
import 'package:my_resturant/presentation/pages/onboarding/welcome_page.dart';
import 'package:my_resturant/presentation/pages/onboarding/feature_page.dart';
import 'package:my_resturant/presentation/pages/onboarding/settings_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageCtl;
  int _page = 0;
  static const _pages = OnbPage.values;

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
    if (_page < _pages.length - 1) {
      _pageCtl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
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
    String t(String key) => Tr.get(key, settings.locale);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: MeshBackground(
                key: ValueKey(_page),
                colors: _pages[_page].gradient,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SkipButton(page: _page, total: _pages.length, onFinish: _finish),
                  Expanded(
                    child: PageView(
                      controller: _pageCtl,
                      onPageChanged: (i) => setState(() => _page = i),
                      children: [
                        WelcomePage(t: t),
                        OnboardingSettingsPage(t: t),
                        ..._pages.skip(2).map((p) => FeaturePage(data: p, t: t)),
                      ],
                    ),
                  ),
                  OnboardingBottomBar(
                    page: _page,
                    totalPages: _pages.length,
                    accent: _pages[_page].gradient[0],
                    onNext: _next,
                    label: _page < _pages.length - 1
                        ? t('onboarding_next')
                        : t('onboarding_get_started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
