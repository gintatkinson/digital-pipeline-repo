class TableViewConfig {
  final String testId;
  final List<String> headers;
  final List<List<String>> rows;

  const TableViewConfig({
    required this.testId,
    required this.headers,
    required this.rows,
  });

  factory TableViewConfig.fromJson(Map<String, dynamic> json) {
    return TableViewConfig(
      testId: json['testId'] as String? ?? 'unknown',
      headers: (json['headers'] as List<dynamic>?)?.cast<String>() ?? [],
      rows: (json['rows'] as List<dynamic>?)
              ?.map((row) => (row as List<dynamic>).cast<String>())
              .toList() ??
          [],
    );
  }
}

const Map<String, TableViewConfig> tableViewRegistry = {
  'sub_elements_table': TableViewConfig(
    testId: 'items-table',
    headers: ['ID', 'Name', 'Type', 'Status'],
    rows: [
      ['ITEM-001', 'Ingestion Pipeline', 'Worker', 'Active'],
      ['ITEM-002', 'Telemetry DB', 'Database', 'Idle'],
      ['ITEM-003', 'Web Console', 'Frontend', 'Active'],
    ],
  ),
  'active_alarms_table': TableViewConfig(
    testId: 'status-table',
    headers: ['Alarm ID', 'Target', 'Severity', 'Timestamp'],
    rows: [
      ['ALARM-101', 'Telemetry DB', 'Critical', '2026-06-23 14:19'],
      ['ALARM-102', 'Ingestion Pipeline', 'Warning', '2026-06-23 14:20'],
    ],
  ),
  'historical_events_table': TableViewConfig(
    testId: 'activity-table',
    headers: ['Event ID', 'Source', 'Message', 'Timestamp'],
    rows: [
      ['EVENT-201', 'System', 'Console initialized', '2026-06-23 14:19'],
      ['EVENT-202', 'Worker', 'Registered off-thread background worker', '2026-06-23 14:19'],
      ['EVENT-203', 'UI', 'Selected panel reflow isolation scope active', '2026-06-23 14:19'],
    ],
  ),
};
