import 'dart:convert';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:app_flutter/main.dart' as app_main;
import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:app_flutter/core/theme/theme_service.dart';
import 'package:app_flutter/core/theme/text_scaler.dart';
import 'package:app_flutter/core/string_resources.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/data_sources/sqlite_data_source.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/tree/tree_node.dart';
import 'package:app_flutter/features/tree/sidebar_tree.dart';
import 'package:app_flutter/features/tree/view_models/tree_view_model.dart';
import 'package:app_flutter/features/properties/view_models/properties_view_model.dart';
import 'package:app_flutter/features/properties/property_grid.dart';

// Helper to sort fields in the same way as PropertyGrid
List<FieldDescriptor> getSortedFields(List<FieldDescriptor> fields) {
  final groups = fields.map((f) => f.sectionLabel ?? 'Other').toSet().toList()..sort();
  final List<FieldDescriptor> sortedFields = [];
  for (final group in groups) {
    final groupFields = fields.where((f) => (f.sectionLabel ?? 'Other') == group).toList()
      ..sort((a, b) => a.sectionOrder.compareTo(b.sectionOrder));
    sortedFields.addAll(groupFields);
  }
  return sortedFields;
}

Future<Database> createTestDatabase() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
  await db.execute('PRAGMA foreign_keys = ON;');

  // Create tables
  await db.execute('CREATE TABLE properties (node_id TEXT PRIMARY KEY, data_json TEXT NOT NULL)');
  await db.execute('CREATE TABLE instances (id TEXT PRIMARY KEY, parent_node_id TEXT NOT NULL, type_name TEXT NOT NULL, data_json TEXT NOT NULL)');
  await db.execute('CREATE TABLE type_definitions (type_name TEXT PRIMARY KEY, display_name TEXT NOT NULL, icon_name TEXT NOT NULL DEFAULT "insert_drive_file")');
  await db.execute('''
    CREATE TABLE type_attributes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type_name TEXT NOT NULL REFERENCES type_definitions(type_name),
      attr_key TEXT NOT NULL,
      label TEXT NOT NULL,
      attr_type TEXT NOT NULL,
      section_label TEXT,
      section_order INTEGER NOT NULL DEFAULT 0,
      is_required INTEGER NOT NULL DEFAULT 0,
      min_value REAL,
      max_value REAL,
      pattern TEXT,
      enum_options TEXT,
      enum_display_names TEXT,
      default_value TEXT,
      input_formatters TEXT,
      UNIQUE(type_name, attr_key)
    )
  ''');
  await db.execute('''
    CREATE TABLE type_relations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      parent_type_name TEXT NOT NULL REFERENCES type_definitions(type_name),
      relation_name TEXT NOT NULL,
      child_type_name TEXT NOT NULL REFERENCES type_definitions(type_name),
      child_label TEXT NOT NULL,
      UNIQUE(parent_type_name, child_type_name)
    )
  ''');

  final batch = db.batch();

  // Seed metadata types
  batch.insert('type_definitions', {'type_name': 'Component', 'display_name': 'Component', 'icon_name': 'widgets'});
  batch.insert('type_definitions', {'type_name': 'RelationA', 'display_name': 'Relation A', 'icon_name': 'warning'});
  batch.insert('type_definitions', {'type_name': 'RelationB', 'display_name': 'Relation B', 'icon_name': 'event'});

  // Attributes for Component
  batch.insert('type_attributes', {'type_name': 'Component', 'attr_key': 'id', 'label': 'ID', 'attr_type': 'string', 'is_required': 1});
  batch.insert('type_attributes', {'type_name': 'Component', 'attr_key': 'name', 'label': 'Name', 'attr_type': 'string', 'is_required': 1});
  batch.insert('type_attributes', {'type_name': 'Component', 'attr_key': 'status', 'label': 'Status', 'attr_type': 'string'});

  // Attributes for RelationA
  batch.insert('type_attributes', {'type_name': 'RelationA', 'attr_key': 'id', 'label': 'ID', 'attr_type': 'string', 'is_required': 1});
  batch.insert('type_attributes', {'type_name': 'RelationA', 'attr_key': 'target', 'label': 'Target', 'attr_type': 'string', 'is_required': 1});
  batch.insert('type_attributes', {'type_name': 'RelationA', 'attr_key': 'severity', 'label': 'Severity', 'attr_type': 'string'});
  batch.insert('type_attributes', {'type_name': 'RelationA', 'attr_key': 'timestamp', 'label': 'Timestamp', 'attr_type': 'string'});

  // Attributes for RelationB
  batch.insert('type_attributes', {'type_name': 'RelationB', 'attr_key': 'id', 'label': 'ID', 'attr_type': 'string', 'is_required': 1});
  batch.insert('type_attributes', {'type_name': 'RelationB', 'attr_key': 'source', 'label': 'Source', 'attr_type': 'string', 'is_required': 1});
  batch.insert('type_attributes', {'type_name': 'RelationB', 'attr_key': 'message', 'label': 'Message', 'attr_type': 'string', 'is_required': 1});
  batch.insert('type_attributes', {'type_name': 'RelationB', 'attr_key': 'timestamp', 'label': 'Timestamp', 'attr_type': 'string'});

  // Custom node types
  final customNodes = ['root', 'Overview', 'Item-1', 'Item-2', 'Item-3'];
  for (final node in customNodes) {
    batch.insert('type_definitions', {'type_name': node, 'display_name': node, 'icon_name': 'folder'});
    // Attributes
    batch.insert('type_attributes', {'type_name': node, 'attr_key': 'name', 'label': 'Name', 'attr_type': 'string', 'is_required': 1});
    batch.insert('type_attributes', {'type_name': node, 'attr_key': 'description', 'label': 'Description', 'attr_type': 'string', 'is_required': 0});
    batch.insert('type_attributes', {'type_name': node, 'attr_key': 'custom_val', 'label': 'Custom Value', 'attr_type': 'string', 'is_required': 0});

    // Relation tabs
    batch.insert('type_relations', {
      'parent_type_name': node,
      'relation_name': 'components_rel',
      'child_type_name': 'Component',
      'child_label': 'Components',
    });
    batch.insert('type_relations', {
      'parent_type_name': node,
      'relation_name': 'relation_a_rel',
      'child_type_name': 'RelationA',
      'child_label': 'Relation A',
    });
    batch.insert('type_relations', {
      'parent_type_name': node,
      'relation_name': 'relation_b_rel',
      'child_type_name': 'RelationB',
      'child_label': 'Relation B',
    });

    // Seed properties
    batch.insert('properties', {
      'node_id': node,
      'data_json': '{"name":"Initial $node","description":"Initial Description","custom_val":"initial"}',
    });

    // Seed instances/rows in tabs
    for (int j = 1; j <= 2; j++) {
      batch.insert('instances', {
        'id': 'elem-$node-$j',
        'parent_node_id': node,
        'type_name': 'Component',
        'data_json': '{"id":"elem-$node-$j","name":"$node Component $j","status":"Active"}',
      });
      batch.insert('instances', {
        'id': 'alarm-$node-$j',
        'parent_node_id': node,
        'type_name': 'RelationA',
        'data_json': '{"id":"alarm-$node-$j","target":"$node Target $j","severity":"Warning","timestamp":"2026-07-02"}',
      });
      batch.insert('instances', {
        'id': 'event-$node-$j',
        'parent_node_id': node,
        'type_name': 'RelationB',
        'data_json': '{"id":"event-$node-$j","source":"System","message":"$node Relation B $j","timestamp":"2026-07-02"}',
      });
    }
  }

  // Hierarchy relations (contains)
  batch.insert('type_relations', {
    'parent_type_name': 'root',
    'relation_name': 'contains',
    'child_type_name': 'Overview',
    'child_label': 'Overview',
  });
  batch.insert('type_relations', {
    'parent_type_name': 'Overview',
    'relation_name': 'contains',
    'child_type_name': 'Item-1',
    'child_label': 'Item-1',
  });
  batch.insert('type_relations', {
    'parent_type_name': 'Overview',
    'relation_name': 'contains',
    'child_type_name': 'Item-2',
    'child_label': 'Item-2',
  });
  batch.insert('type_relations', {
    'parent_type_name': 'Overview',
    'relation_name': 'contains',
    'child_type_name': 'Item-3',
    'child_label': 'Item-3',
  });

  await batch.commit(noResult: true);
  return db;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E integration test: SQLite, properties edits, tabs toggle, settings mode cycles', (WidgetTester tester) async {
    // Set up standard desktop window sizing for macOS (1280x800, pixel ratio 2.0)
    const double width = 1280;
    const double height = 800;
    const double pixelRatio = 2.0;
    tester.view.physicalSize = const Size(width * pixelRatio, height * pixelRatio);
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Load strings
    await StringResources.load();

    // Create and seed test database
    final db = await createTestDatabase();
    addTearDown(() async {
      await db.close();
    });

    final repository = SqliteRepositoryAdapter(db);
    final dataSource = SqliteDataSource(db);

    final themeController = ThemeController(SharedPreferencesThemeService());
    await themeController.loadSettings();

    final textScalerController = TextScalerController();
    await textScalerController.load();

    // Hooks
    app_main.globalThemeController = themeController;
    app_main.globalTextScalerController = textScalerController;

    // Helper to settle frames without looping indefinitely on background animations
    Future<void> settle(WidgetTester t) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await t.pump();
      for (int i = 0; i < 50; i++) {
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await t.pump();
      }
    }

    // Boot application
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AbstractRepository>.value(value: repository),
          Provider<DataSource>.value(value: dataSource),
          ChangeNotifierProvider<ThemeController>.value(value: themeController),
          ChangeNotifierProvider<TextScalerController>.value(value: textScalerController),
        ],
        child: const MyApp(),
      ),
    );

    await settle(tester);

    // Wait for the tree view model to load
    int attempts = 0;
    while (attempts < 20 && find.byKey(const Key('node_root')).evaluate().isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pump();
      attempts++;
    }

    final treeViewModel = tester.element(find.byType(SidebarTree)).read<TreeViewModel>();

    // Define traversal function
    Future<void> traverseTreeAndProcess(TreeNode node, int loopIndex) async {
      final nodeId = node.id;
      final nodeTileFinder = find.byKey(Key('node_$nodeId'));

      await tester.ensureVisible(nodeTileFinder);
      await tester.tap(nodeTileFinder);
      await settle(tester);

      // Enter mock values in every text field
      final propertyGridWidget = tester.widget<PropertyGrid>(find.byType(PropertyGrid));
      final sortedFields = getSortedFields(propertyGridWidget.fields);
      final textFieldsList = sortedFields.where((f) => f.type != 'enum').toList();

      final Map<String, String> expectedValues = {};
      final textFieldsFinder = find.byType(TextField);

      for (int i = 0; i < textFieldsList.length; i++) {
        final field = textFieldsList[i];
        final newValue = 'New-${field.key}-$nodeId-loop$loopIndex';
        expectedValues[field.key] = newValue;

        await tester.enterText(textFieldsFinder.at(i), newValue);
        await tester.pump();
      }

      // Click the "Save" button
      final saveButtonFinder = find.byKey(const Key('save_properties_button'));
      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await settle(tester);

      // Verify direct SQLite DB save mapping
      final dbResult = await db.query(
        'properties',
        where: 'node_id = ?',
        whereArgs: [nodeId],
      );
      expect(dbResult.isNotEmpty, isTrue, reason: 'Properties row for node $nodeId should exist in DB');
      final dataJson = dbResult.first['data_json'] as String;
      final dbData = jsonDecode(dataJson) as Map<String, dynamic>;

      for (final entry in expectedValues.entries) {
        expect(dbData[entry.key], equals(entry.value), reason: 'DB properties mapping mismatch for field ${entry.key}');
      }

      // Assert rendered correctly in the UI grid
      for (final val in expectedValues.values) {
        expect(find.text(val), findsAtLeast(1), reason: 'UI grid should display entered value: $val');
      }

      // Toggle relation tabs (Components, Relation A, Relation B) to ensure data is displayed
      final tabLabels = ['Components', 'Relation A', 'Relation B'];
      for (final label in tabLabels) {
        final tabFinder = find.descendant(
          of: find.byType(TabBar),
          matching: find.text(label),
        );
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.tap(tabFinder);
          await settle(tester);
        }
      }

      // Recurse children
      if (node.children != null) {
        for (final child in node.children!) {
          await traverseTreeAndProcess(child, loopIndex);
        }
      }
    }

    // Repeat traversal 3 times
    for (int loopIndex = 0; loopIndex < 3; loopIndex++) {
      final rootNodes = treeViewModel.treeData;
      for (final rootNode in rootNodes) {
        await traverseTreeAndProcess(rootNode, loopIndex);
      }

      // Once the last node is reached, change theme (light, dark, system) and layout density (text scale)
      if (loopIndex == 0) {
        await themeController.updateThemeMode(ThemeMode.light);
        textScalerController.setScale(1.2);
      } else if (loopIndex == 1) {
        await themeController.updateThemeMode(ThemeMode.dark);
        textScalerController.setScale(0.8);
      } else if (loopIndex == 2) {
        await themeController.updateThemeMode(ThemeMode.system);
        textScalerController.setScale(1.0);
      }
      await settle(tester);
    }
  });
}
