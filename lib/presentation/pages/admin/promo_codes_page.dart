import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

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
    setState(() => _loading = true);
    final data = await _db.from('promo_codes').select().order('created_at', ascending: false);
    if (!mounted) return;
    setState(() { _codes = data; _loading = false; });
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<void> _createCode() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Promo Code'),
          content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Enter code or tap generate',
            suffixIcon: IconButton(
              icon: const Icon(Icons.casino_outlined, size: 20),
              tooltip: 'Generate random',
              onPressed: () {
                controller.text = _generateCode();
                controller.selection = TextSelection.collapsed(offset: controller.text.length);
              },
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.isNotEmpty ? controller.text : null),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    try {
      await _db.from('promo_codes').insert({'code': result.trim().toUpperCase()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code "${result.trim().toUpperCase()}" created'), backgroundColor: AppColors.primary));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  Future<void> _deleteCode(String code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Code?'),
        content: Text('Delete promo code "$code"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    await _db.from('promo_codes').delete().eq('code', code);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Promo Codes'), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton.icon(
            onPressed: _createCode,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Code'),
          ),
        ),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _codes.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.vpn_key_off_outlined, size: 64, color: cs.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No promo codes yet', style: TextStyle(color: cs.onSurfaceVariant, fontSize: R.fontLg(context))),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: isDesktop ? _buildTable(cs) : _buildList(cs),
                ),
    );
  }

  Widget _buildTable(ColorScheme cs) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(R.padding(context)),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1)},
          children: [
            TableRow(decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              children: [_th('Code', cs), _th('Used By', cs), _th('Date', cs), _th('', cs)]),
            for (int i = 0; i < _codes.length; i++)
              TableRow(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
                borderRadius: i == _codes.length - 1 ? const BorderRadius.vertical(bottom: Radius.circular(16)) : null),
                children: [_td(_codes[i]['code'] ?? '', cs, bold: true),
                  _td(_codes[i]['used_by'] != null ? 'Used' : 'Available', cs, color: _codes[i]['used_by'] != null ? Colors.orange : Colors.green),
                  _td(_formatDate(_codes[i]['created_at']), cs),
                  _tdAction(_codes[i], cs)]),
          ],
        ),
      ),
    );
  }

  Widget _th(String text, ColorScheme cs) => Padding(
    padding: const EdgeInsets.all(12), child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, fontSize: 13)));

  Widget _td(String text, ColorScheme cs, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.all(12), child: Text(text, style: TextStyle(fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: color ?? cs.onSurface, fontSize: 14)));

  Widget _tdAction(Map<String, dynamic> code, ColorScheme cs) {
    final used = code['used_by'] != null;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        IconButton(
          icon: Icon(Icons.copy_rounded, size: 18, color: cs.primary),
          tooltip: 'Copy',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code['code'] ?? ''));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)));
          },
        ),
        if (!used) IconButton(
          icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
          tooltip: 'Delete',
          onPressed: () => _deleteCode(code['code']),
        ),
      ]),
    );
  }

  Widget _buildList(ColorScheme cs) {
    return ListView.builder(
      padding: EdgeInsets.all(R.padding(context)),
      itemCount: _codes.length,
      itemBuilder: (context, i) {
        final c = _codes[i];
        final used = c['used_by'] != null;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: used ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(used ? Icons.lock_outline : Icons.vpn_key, color: used ? Colors.orange : Colors.green, size: 20),
            ),
            title: Text(c['code'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace', fontSize: 16)),
            subtitle: Text(used ? 'Used' : 'Available', style: TextStyle(color: used ? Colors.orange : Colors.green, fontSize: 12)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: Icon(Icons.copy_rounded, size: 18, color: cs.primary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: c['code'] ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)));
                },
              ),
              if (!used) IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                onPressed: () => _deleteCode(c['code']),
              ),
            ]),
          ),
        );
      },
    );
  }

  String _formatDate(dynamic v) {
    if (v == null) return '-';
    final d = DateTime.parse(v.toString()).toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }
}
