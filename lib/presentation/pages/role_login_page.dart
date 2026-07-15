import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';

class RoleLoginPage extends StatefulWidget {
  const RoleLoginPage({super.key});
  @override
  State<RoleLoginPage> createState() => _RoleLoginPageState();
}

class _RoleLoginPageState extends State<RoleLoginPage> {
  Role _selected = Role.waiter;
  final _pinCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pinCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final cs = Theme.of(context).colorScheme;
    String t(String key) => Tr.get(key, settings.locale);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t('role_login_title'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t('role_login_subtitle'),
                      style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      t('choose_role'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: Role.values
                          .map(
                            (r) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: _roleCard(r, _selected == r, cs, t),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _pinCtl,
                      obscureText: true,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: t('pin_hint'),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_error case final err?)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(err, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _loading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                t('enter'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _roleCard(
    Role r,
    bool selected,
    ColorScheme cs,
    String Function(String) t,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _selected = r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : cs.outlineVariant,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              _roleIcon(r),
              size: 28,
              color: selected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 6),
            Text(
              t(r.name),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : cs.onSurface,
              ),
            ),
          ],
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

  Future<void> _login() async {
    if (_pinCtl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final ok = await context.read<RoleCubit>().loginAsync(
      _selected,
      _pinCtl.text,
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _loading = false);
      context.go('/menu');
    } else {
      setState(() {
        _loading = false;
        _error = Tr.get('pin_invalid', context.read<SettingsCubit>().state.locale);
      });
      _pinCtl.clear();
    }
  }
}
