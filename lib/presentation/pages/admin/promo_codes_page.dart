import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
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
    final result = await showCreatePromoCodeDialog(context);
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
          content: Text('Code "$code" created (expires in $months months)'),
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
    final confirm = await showDeletePromoCodeDialog(context, code);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promo Codes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _createCode,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Code'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _codes.isEmpty
          ? const EmptyState(
              icon: Icons.vpn_key_off_outlined,
              title: 'No promo codes yet',
              subtitle:
                  'Create a code to let restaurants activate '
                  'their account.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: isDesktop
                  ? PromoCodeTable(codes: _codes, onDelete: _deleteCode)
                  : PromoCodeList(codes: _codes, onDelete: _deleteCode),
            ),
    );
  }
}
