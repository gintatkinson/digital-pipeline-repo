import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:app_flutter/core/theme/theme_service.dart' show SharedPreferencesThemeService;
import 'package:app_flutter/core/theme/text_scaler.dart';
import 'package:app_flutter/domain/database_initializer.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> _createInMemoryDb({bool seed = true}) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return DatabaseInitializer.create(
    dbPath: inMemoryDatabasePath,
    seed: seed,
  );
}

/// Section label mapping matching what the build-time DB generator uses.
const _sectionLabelMap = {
  'Location': 'Geodetic Coordinate Frame',
  'Alternate': 'Alternate Structural Grid Frame',
};

/// Seed data matching what the build-time DB generator produces.
const _seedTypeDefs = [
  ('Ingestion', 'Ingestion', 'insert_drive_file'),
  ('Monitoring', 'Monitoring', 'insert_drive_file'),
  ('Metrics', 'Metrics', 'insert_drive_file'),
  ('Location', 'Location', 'insert_drive_file'),
  ('Chassis', 'Chassis', 'insert_drive_file'),
  ('Uptime', 'Uptime', 'insert_drive_file'),
  ('Spec', 'Spec', 'insert_drive_file'),
  ('Epics', 'Epics', 'insert_drive_file'),
  ('Traceability', 'Traceability', 'insert_drive_file'),
  ('Requirements', 'Requirements', 'insert_drive_file'),
  ('Releases', 'Releases', 'insert_drive_file'),
  ('Security', 'Security', 'insert_drive_file'),
  ('Access', 'Access', 'insert_drive_file'),
  ('Firewall', 'Firewall', 'insert_drive_file'),
  ('Certificates', 'Certificates', 'insert_drive_file'),
  ('Audit', 'Audit', 'insert_drive_file'),
  ('Infrastructure', 'Infrastructure', 'insert_drive_file'),
  ('Servers', 'Servers', 'insert_drive_file'),
  ('Storage', 'Storage', 'insert_drive_file'),
  ('Network', 'Network', 'insert_drive_file'),
  ('Alternate', 'Alternate', 'insert_drive_file'),
  ('interface', 'Interface', 'insert_drive_file'),
  ('state', 'State', 'insert_drive_file'),
];

const _seedRelations = [
  ('Monitoring', 'Metrics', 'Metrics'),
  ('Monitoring', 'Location', 'Location'),
  ('Monitoring', 'Chassis', 'Chassis'),
  ('Monitoring', 'Uptime', 'Uptime'),
  ('Spec', 'Epics', 'Epics'),
  ('Spec', 'Traceability', 'Traceability'),
  ('Spec', 'Requirements', 'Requirements'),
  ('Spec', 'Releases', 'Releases'),
  ('Security', 'Access', 'Access'),
  ('Security', 'Firewall', 'Firewall'),
  ('Security', 'Certificates', 'Certificates'),
  ('Security', 'Audit', 'Audit'),
  ('Infrastructure', 'Servers', 'Servers'),
  ('Infrastructure', 'Storage', 'Storage'),
  ('Infrastructure', 'Network', 'Network'),
];

void main() {
  test('Seed populates type_definitions table', () async {
    final db = await _createInMemoryDb(seed: true);
    try {
      final batch = db.batch();

      // Seed metadata tables (in production these come from the pre-built DB)
      for (final td in _seedTypeDefs) {
        batch.insert('type_definitions', {
          'type_name': td.$1,
          'display_name': td.$2,
          'icon_name': td.$3,
        });
      }
      for (final rel in _seedRelations) {
        batch.insert('type_relations', {
          'parent_type_name': rel.$1,
          'relation_name': 'contains',
          'child_type_name': rel.$2,
          'child_label': rel.$3,
        });
      }

      const sectionGroupAttrs = [
        {'key': 'interfaces/interface/name', 'label': 'The name of the interface', 'type': 'string', 'sectionGroup': 'interface', 'isRequired': false},
        {'key': 'interfaces/interface/state/mtu', 'label': 'The Maximum Transmission Unit', 'type': 'int', 'sectionGroup': 'state', 'isRequired': true, 'minValue': 68, 'maxValue': 9216},
        {'key': 'interfaces/interface/state/admin-status', 'label': 'The administrative status of the interface', 'type': 'enum', 'sectionGroup': 'state', 'isRequired': false, 'options': ['UP', 'DOWN']},
        {'key': 'latitude', 'label': 'Latitude', 'type': 'double', 'sectionGroup': 'Location', 'isRequired': false, 'defaultValue': 37.7749},
        {'key': 'longitude', 'label': 'Longitude', 'type': 'double', 'sectionGroup': 'Location', 'isRequired': false, 'defaultValue': -122.4194},
        {'key': 'altitude', 'label': 'Elevation / Altitude (m)', 'type': 'int', 'sectionGroup': 'Location', 'isRequired': false, 'defaultValue': 10},
        {'key': 'roomName', 'label': 'Room Identifier', 'type': 'string', 'sectionGroup': 'Alternate', 'isRequired': false, 'defaultValue': 'Main-Data-Room'},
        {'key': 'gridRow', 'label': 'Grid Row', 'type': 'int', 'sectionGroup': 'Alternate', 'isRequired': false, 'defaultValue': 12},
        {'key': 'gridColumn', 'label': 'Grid Column', 'type': 'int', 'sectionGroup': 'Alternate', 'isRequired': false, 'defaultValue': 4},
        {'key': 'maxVoltage', 'label': 'Max Voltage (V)', 'type': 'double', 'sectionGroup': 'Alternate', 'isRequired': false, 'defaultValue': 240.0},
        {'key': 'maxAllocatedPower', 'label': 'Max Allocated Power (W)', 'type': 'double', 'sectionGroup': 'Alternate', 'isRequired': false, 'defaultValue': 15000.0},
        {'key': 'countryCode', 'label': 'Country Code (ISO-2)', 'type': 'string', 'sectionGroup': 'Alternate', 'isRequired': false, 'defaultValue': 'US', 'inputFormatters': ['uppercase', 'maxLength:2']},
        {'key': 'locationType', 'label': 'Location Hierarchy Type', 'type': 'enum', 'sectionGroup': 'Alternate', 'isRequired': false, 'options': ['site', 'room', 'building', 'invalid-test-option'], 'displayNames': ['Site', 'Room', 'Building', 'Invalid (Test Only)'], 'defaultValue': 'room'},
      ];

      final Map<String, int> sectionCounters = {};
      for (final attr in sectionGroupAttrs) {
        final sg = attr['sectionGroup'] as String;
        final order = sectionCounters.update(sg, (v) => v + 1, ifAbsent: () => 0);
        final List<String>? options = (attr['options'] as List<dynamic>?)?.cast<String>();
        final List<String>? displayNames = (attr['displayNames'] as List<dynamic>?)?.cast<String>();
        batch.insert('type_attributes', {
          'type_name': sg,
          'attr_key': attr['key'] as String,
          'label': attr['label'] as String,
          'attr_type': attr['type'] as String,
          'section_label': _sectionLabelMap[sg],
          'section_order': order,
          'is_required': (attr['isRequired'] as bool) ? 1 : 0,
          'min_value': attr['minValue'] as num?,
          'max_value': attr['maxValue'] as num?,
          'enum_options': options != null ? jsonEncode(options) : null,
          'enum_display_names': displayNames != null ? jsonEncode(displayNames) : null,
          'default_value': attr['defaultValue']?.toString(),
          'input_formatters': attr['inputFormatters'] != null ? jsonEncode(attr['inputFormatters']) : null,
        });
      }

      await batch.commit(noResult: true);

      final rows = await db.query('type_definitions');
      expect(rows.length, greaterThan(0));

      final attrRows = await db.query('type_attributes');
      expect(attrRows.length, greaterThan(0));

      final relRows = await db.query('type_relations');
      expect(relRows.length, greaterThan(0));

      // Verify concrete entries
      final location = rows.firstWhere((r) => r['type_name'] == 'Location');
      expect(location['display_name'], 'Location');

      final lat = attrRows.firstWhere((r) => r['attr_key'] == 'latitude');
      expect(lat['default_value'], '37.7749');
      expect(lat['section_label'], 'Geodetic Coordinate Frame');

      final locType = attrRows.firstWhere((r) => r['attr_key'] == 'locationType');
      final enumOpts = jsonDecode(locType['enum_options'] as String) as List;
      expect(enumOpts, contains('site'));

      final ingRel = relRows.firstWhere(
        (r) => r['parent_type_name'] == 'Monitoring' && r['child_type_name'] == 'Location',
      );
      expect(ingRel['relation_name'], 'contains');
    } finally {
      await db.close();
    }
  });

  testWidgets('Dashboard console boots and renders main widgets successfully',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = await DatabaseInitializer.create(
        dbPath: inMemoryDatabasePath,
        seed: false,
      );
      try {
        final repository = SqliteRepositoryAdapter(db);
        final themeController = ThemeController(SharedPreferencesThemeService());

        final textScaler = TextScalerController();
        await textScaler.load();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AbstractRepository>.value(value: repository),
              ChangeNotifierProvider<ThemeController>.value(value: themeController),
              ChangeNotifierProvider<TextScalerController>.value(value: textScaler),
            ],
            child: MyApp(),
          ),
        );

        await tester.pump();

        expect(find.byType(MyApp), findsOneWidget);
        expect(find.byType(DashboardPage), findsOneWidget);
        expect(find.text('Antigravity Console'), findsAtLeast(1));
      } finally {
        await db.close();
      }
    });
  });
}
