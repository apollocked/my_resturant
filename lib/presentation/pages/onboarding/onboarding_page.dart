import 'dart:ui';
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

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late final PageController _pageCtl;
  int _page = 0;

  static const _pages = _PageData.values;

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
              child: _MeshBackground(
                key: ValueKey(_page),
                colors: _pages[_page].gradient,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _page < _pages.length - 1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8, right: 8),
                            child: PressableScale(
                              onTap: _finish,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Text(
                                  t('onboarding_skip'),
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(height: 52),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageCtl,
                      onPageChanged: (i) => setState(() => _page = i),
                      children: [
                        _WelcomePage(t: t),
                        ..._pages.skip(1).map((p) => _FeaturePage(
                              data: p,
                              t: t,
                            )),
                      ],
                    ),
                  ),
                  _BottomBar(
                    page: _page,
                    totalPages: _pages.length,
                    accent: _pages[_page].gradient[0],
                    onNext: _next,
                    t: t,
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

enum _PageData {
  welcome,
  menu,
  kitchen,
  reports;

  List<Color> get gradient => switch (this) {
        welcome => const [
            Color(0xFFE8611A),
            Color(0xFFD44A0A),
            Color(0xFF8B2FC9),
          ],
        menu => const [
            Color(0xFF3B82F6),
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        kitchen => const [
            Color(0xFFF97316),
            Color(0xFFEF4444),
            Color(0xFFEC4899),
          ],
        reports => const [
            Color(0xFF10B981),
            Color(0xFF06B6D4),
            Color(0xFF3B82F6),
          ],
      };

  IconData get icon => switch (this) {
        welcome => Icons.restaurant_rounded,
        menu => Icons.restaurant_menu_rounded,
        kitchen => Icons.kitchen_rounded,
        reports => Icons.analytics_rounded,
      };

  String get titleKey => switch (this) {
        welcome => 'onboarding_welcome_title',
        menu => 'onboarding_menu_title',
        kitchen => 'onboarding_kitchen_title',
        reports => 'onboarding_reports_title',
      };

  String get descKey => switch (this) {
        welcome => 'onboarding_welcome_desc',
        menu => 'onboarding_menu_desc',
        kitchen => 'onboarding_kitchen_desc',
        reports => 'onboarding_reports_desc',
      };

  String get subKey => switch (this) {
        welcome => 'onboarding_welcome_sub',
        _ => '',
      };

  List<String> get featuresKeys => switch (this) {
        welcome => [],
        menu => [
            'onboarding_feat_table',
            'onboarding_feat_categories',
            'onboarding_feat_notes',
            'onboarding_feat_search',
          ],
        kitchen => [
            'onboarding_feat_pipeline',
            'onboarding_feat_notifications',
            'onboarding_feat_clearing',
            'onboarding_feat_status',
          ],
        reports => [
            'onboarding_feat_revenue',
            'onboarding_feat_ranking',
            'onboarding_feat_history',
            'onboarding_feat_stats',
          ],
      };
}

class _MeshBackground extends StatefulWidget {
  final List<Color> colors;
  const _MeshBackground({super.key, required this.colors});

  @override
  State<_MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<_MeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, _) {
        final t = _ctl.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + t * 0.5, -1.0 + t * 0.3),
              end: Alignment(1.0 - t * 0.5, 1.0 - t * 0.3),
              colors: [
                widget.colors[0],
                widget.colors[1],
                widget.colors[2],
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80 + t * 40,
                left: -60 + t * 30,
                child: _Blob(
                  size: 280,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              Positioned(
                bottom: -100 + t * 50,
                right: -80 + t * 40,
                child: _Blob(
                  size: 320,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                right: -40 + t * 20,
                child: _Blob(
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final String Function(String) t;
  const _WelcomePage({required this.t});

  @override
  Widget build(BuildContext context) {
    final pad = R.padding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/my Restaurant.png',
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFFFD4B0)],
            ).createShader(bounds),
            child: Text(
              t('onboarding_welcome_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            t('onboarding_welcome_sub'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 17,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              t('onboarding_welcome_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14.5,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _FeaturePage extends StatelessWidget {
  final _PageData data;
  final String Function(String) t;
  const _FeaturePage({required this.data, required this.t});

  @override
  Widget build(BuildContext context) {
    final pad = R.padding(context);
    final features = data.featuresKeys.map((k) => t(k)).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          _GlowingIcon(
            icon: data.icon,
            color: data.gradient[0],
          ),
          const SizedBox(height: 44),
          Text(
            t(data.titleKey),
            style: TextStyle(
              fontSize: R.fontXl(context) + 4,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            t(data.descKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: R.fontMd(context),
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 36),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GlassFeatureTile(
                  label: f,
                  accent: data.gradient[0],
                ),
              )),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _GlowingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _GlowingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 50,
            spreadRadius: 15,
          ),
        ],
      ),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.5,
          ),
        ),
        child: Icon(icon, size: 52, color: Colors.white),
      ),
    );
  }
}

class _GlassFeatureTile extends StatelessWidget {
  final String label;
  final Color accent;
  const _GlassFeatureTile({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_rounded, size: 18, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: R.fontMd(context),
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final Color accent;
  final VoidCallback onNext;
  final String Function(String) t;

  const _BottomBar({
    required this.page,
    required this.totalPages,
    required this.accent,
    required this.onNext,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final pad = R.padding(context);
    final isLast = page == totalPages - 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 0, pad, pad + 8),
      child: Row(
        children: [
          ...List.generate(totalPages, (i) {
            final isActive = page == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              margin: const EdgeInsets.only(right: 6),
              width: isActive ? 32 : 10,
              height: 10,
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          accent,
                          accent.withValues(alpha: 0.6),
                        ],
                      )
                    : null,
                color: isActive ? null : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
          const Spacer(),
          PressableScale(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.75)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLast
                        ? t('onboarding_get_started')
                        : t('onboarding_next'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
