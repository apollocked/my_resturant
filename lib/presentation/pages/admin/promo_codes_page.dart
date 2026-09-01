import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/promo_code_dialogs.dart';
import 'package:my_resturant/presentation/widgets/admin/promo_code_list.dart';
import 'package:my_resturant/presentation/widgets/admin/promo_code_table.dart';
import 'package:my_resturant/shared/empty_state.dart';

class PromoCodesPage extends StatefulWidget {
  const PromoCodesPage({super.key});
  @override
  State<PromoCodesPage> createState() => _PromoCodesPageState();
}

class _PromoCodesPageState extends State<PromoCodesPage> {
  SupabaseClient get _db => Supabase.instance.client;
  List<Map<String, dynamic>> _codes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await _db
          .from('promo_codes')
          .select()
          .order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _codes = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e);
    }
  }

  Future<void> _createCode() async {
    final settings = context.read<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final result = await showCreatePromoCodeDialog(context, t);
    if (result == null) return;
    final code = result['code'] as String;
    final months = result['months'] as int;
    final expiresAt = DateTime.now().add(Duration(days: months * 30));
    try {
      await _db.from('promo_codes').insert({
        'code': code,
        'expires_at': expiresAt.toUtc().toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('promo_created')
                .replaceAll('{code}', code)
                .replaceAll('{months}', '$months'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    }
  }

  Future<void> _deleteCode(String code) async {
    final settings = context.read<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final confirm = await showDeletePromoCodeDialog(context, code, t);
    if (confirm != true) return;
    try {
      await _db.from('promo_codes').delete().eq('code', code);
      if (!mounted) return;
      _load();
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    }
  }

  void _showError(Object e) {
    final settings = context.read<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('error_prefix').replaceAll('{error}', '$e')),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = R.isDesktop(context);
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    return Scaffold(
      appBar: AppBar(
        title: Text(t('promo_codes_title')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: _createCode,
              icon: const Icon(Icons.add, size: 18),
              label: Text(t('promo_new_code')),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _codes.isEmpty
          ? EmptyState(
              icon: Icons.vpn_key_off_outlined,
              title: t('promo_empty_title'),
              subtitle: t('promo_empty_subtitle'),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: isDesktop
                  ? PromoCodeTable(codes: _codes, onDelete: _deleteCode, t: t)
                  : PromoCodeList(codes: _codes, onDelete: _deleteCode, t: t),
            ),
    );
  }
}
