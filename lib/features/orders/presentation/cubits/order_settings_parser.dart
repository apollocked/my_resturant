/// Parsed app_settings snapshot feeding [OrderState].
typedef AppSettingsSnapshot = ({
  int tableCount,
  Map<int, String> tableNames,
  Set<int> clearedTables,
  Map<int, DateTime> cleaningRequests,
});

/// Turns the raw `app_settings` key/value map (shared across devices via
/// realtime) into table layout + cleaning state the order cubit can use.
AppSettingsSnapshot parseAppSettings(Map<String, String> settings) {
  final tableCount = int.tryParse(settings['tableCount'] ?? '10') ?? 10;
  final names = <int, String>{};
  final cleared = <int>{};
  final requests = <int, DateTime>{};
  for (final e in settings.entries) {
    if (e.key.startsWith('tableName_')) {
      final n = int.tryParse(e.key.split('_').last);
      if (n != null) names[n] = e.value;
    }
    if (e.key.startsWith('cleared_') && e.value == 'true') {
      final n = int.tryParse(e.key.split('_').last);
      if (n != null) cleared.add(n);
    }
    if (e.key.startsWith('request_clean_') && e.value.isNotEmpty) {
      final n = int.tryParse(e.key.split('_').last);
      final v = int.tryParse(e.value);
      if (n != null && v != null) {
        requests[n] = DateTime.fromMillisecondsSinceEpoch(v);
      }
    }
  }
  return (
    tableCount: tableCount,
    tableNames: names,
    clearedTables: cleared,
    cleaningRequests: requests,
  );
}