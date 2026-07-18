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

  bool _isExpired(Map<String, dynamic> code) {
    final expires = code['expires_at'];
    if (expires == null) return false;
    return DateTime.parse(expires.toString()).isBefore(DateTime.now());
  }

  Future<void> _createCode() async {
    final controller = TextEditingController();
    int selectedMonths = 12;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Promo Code'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
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
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: selectedMonths,
              decoration: const InputDecoration(labelText: 'Expires in', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 3, child: Text('3 Months')),
                DropdownMenuItem(value: 6, child: Text('6 Months')),
                DropdownMenuItem(value: 12, child: Text('1 Year')),
              ],
              onChanged: (v) { if (v != null) setDialogState(() => selectedMonths = v); },
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.pop(ctx, {'code': controller.text.trim().toUpperCase(), 'months': selectedMonths});
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
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
        SnackBar(content: Text('Code "$code" created (expires in $months months)'), backgroundColor: AppColors.primary));
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

  String _statusText(Map<String, dynamic> code) {
    if (code['used_by'] != null) return 'Used';
    if (_isExpired(code)) return 'Expired';
    return 'Available';
  }

  Color _statusColor(Map<String, dynamic> code) {
    if (code['used_by'] != null) return Colors.orange;
    if (_isExpired(code)) return Colors.red;
    return Colors.green;
  }

  IconData _statusIcon(Map<String, dynamic> code) {
    if (code['used_by'] != null) return Icons.lock_outline;
    if (_isExpired(code)) return Icons.timer_off_outlined;
    return Icons.vpn_key;
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
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1.5), 4: FlexColumnWidth(1)},
          children: [
            TableRow(decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              children: [_th('Code', cs), _th('Status', cs), _th('Created', cs), _th('Expires', cs), _th('', cs)]),
            for (int i = 0; i < _codes.length; i++)
              TableRow(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
                borderRadius: i == _codes.length - 1 ? const BorderRadius.vertical(bottom: Radius.circular(16)) : null),
                children: [
                  _td(_codes[i]['code'] ?? '', cs, bold: true),
                  _td(_statusText(_codes[i]), cs, color: _statusColor(_codes[i])),
                  _td(_formatDate(_codes[i]['created_at']), cs),
                  _td(_formatDate(_codes[i]['expires_at']), cs),
                  _tdAction(_codes[i], cs),
                ]),
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
    final canDelete = code['used_by'] == null;
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
        if (canDelete) IconButton(
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
        final status = _statusText(c);
        final color = _statusColor(c);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(_statusIcon(c), color: color, size: 20),
            ),
            title: Text(c['code'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace', fontSize: 16)),
            subtitle: Text('$status • expires ${_formatDate(c['expires_at'])}', style: TextStyle(color: color, fontSize: 12)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: Icon(Icons.copy_rounded, size: 18, color: cs.primary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: c['code'] ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)));
                },
              ),
              if (c['used_by'] == null) IconButton(
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
