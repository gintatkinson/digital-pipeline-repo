import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/domain/design_tokens.dart';
import 'package:app_flutter/components/layout.dart';
import 'package:app_flutter/components/property_grid.dart';

late final SqliteRepositoryAdapter repository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load and parse assets/design-tokens.json
  final tokensJson = await rootBundle.loadString('assets/design-tokens.json');
  final registry = AppDesignTokenRegistry.parse(tokensJson);

  // Initialize SQLite FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Resolve path to database dynamically using path_provider
  final appDir = await getApplicationSupportDirectory();
  final dbPath = p.join(appDir.path, 'properties_db.db');

  // Open database
  final db = await databaseFactory.openDatabase(dbPath);

  // Create table
  await db.execute(
    'CREATE TABLE IF NOT EXISTS properties (node_id TEXT PRIMARY KEY, data_json TEXT NOT NULL);',
  );

  // If the table is empty, pre-seed it
  final List<Map<String, dynamic>> countResult = await db.rawQuery('SELECT COUNT(*) as count FROM properties');
  final int count = countResult.first['count'] as int? ?? 0;
  if (count == 0) {
    // Load and parse assets/logical-layout.json
    final layoutJson = await rootBundle.loadString('assets/logical-layout.json');
    final layoutConfig = jsonDecode(layoutJson) as Map<String, dynamic>;

    // Dynamically extract the node list from the navigation tree/hierarchy inside the layout config
    final layoutMap = layoutConfig['layout'] as Map<String, dynamic>?;
    final rootContainer = layoutMap?['root_container'] as Map<String, dynamic>?;
    final children = rootContainer?['children'] as List<dynamic>?;
    List<dynamic>? hierarchy;
    if (children != null) {
      for (final child in children) {
        if (child is Map<String, dynamic> && child['type'] == 'HierarchyTreeSelector') {
          final props = child['props'] as Map<String, dynamic>?;
          hierarchy = props?['hierarchy'] as List<dynamic>?;
          break;
        }
      }
    }

    final List<String> nodes = [];
    void traverse(List<dynamic>? items) {
      if (items == null) return;
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final id = item['id'];
          if (id is String) {
            nodes.add(id);
          }
          final nested = item['children'];
          if (nested is List<dynamic>) {
            traverse(nested);
          }
        }
      }
    }
    traverse(hierarchy);

    // Dynamically generate the default attribute values from the layout config
    final attributes = layoutConfig['attributes'] as List<dynamic>? ?? [];
    final defaultMap = <String, dynamic>{};
    for (final attr in attributes) {
      if (attr is Map<String, dynamic>) {
        final key = attr['key'] as String?;
        if (key == null) continue;
        final type = attr['type'] as String?;
        final minValue = attr['minValue'];
        final options = attr['options'] as List<dynamic>?;

        dynamic defaultValue;
        if (type == 'int') {
          defaultValue = minValue is num ? minValue.toInt() : 0;
        } else if (type == 'double') {
          defaultValue = minValue is num ? minValue.toDouble() : 0.0;
        } else if (type == 'enumeration' || type == 'enum') {
          if (options != null && options.isNotEmpty) {
            defaultValue = options.first.toString();
          } else {
            defaultValue = '';
          }
        } else {
          defaultValue = '';
        }
        defaultMap[key] = defaultValue;
      }
    }

    final defaultJson = jsonEncode(defaultMap);
    for (final node in nodes) {
      await db.insert('properties', {'node_id': node, 'data_json': defaultJson});
    }
  }

  repository = SqliteRepositoryAdapter(db);

  runApp(MyApp(repository: repository, registry: registry));
}

/// MyApp is the root application widget that initializes the application theme and layout configurations.
class MyApp extends StatefulWidget {
  final AbstractRepository repository;
  final DesignTokenRegistry registry;
  MyApp({
    super.key,
    required this.repository,
    DesignTokenRegistry? registry,
  }) : registry = registry ?? DesignTokenRegistry.defaultRegistry;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateThemeMode(String modeString) {
    setState(() {
      if (modeString == 'light') {
        _themeMode = ThemeMode.light;
      } else if (modeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightPrimary = widget.registry.getColor('alias.color.brand-primary', theme: 'light');
    final lightBg = widget.registry.getColor('alias.color.background', theme: 'light');
    final lightSurface = widget.registry.getColor('alias.color.surface', theme: 'light');
    final lightDivider = widget.registry.getColor('global.color.gray-100');

    final darkPrimary = widget.registry.getColor('alias.color.brand-primary', theme: 'dark');
    final darkBg = widget.registry.getColor('alias.color.background', theme: 'dark');
    final darkSurface = widget.registry.getColor('alias.color.surface', theme: 'dark');
    final darkDivider = widget.registry.getColor('global.color.gray-900');

    // Configure theme data for Light, Dark, and System modes matching the design tokens
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightSurface,
      dividerColor: lightDivider,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightPrimary,
        brightness: Brightness.light,
      ),
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkSurface,
      dividerColor: darkDivider,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimary,
        brightness: Brightness.dark,
      ),
    );

    return DesignTokenProvider(
      registry: widget.registry,
      child: MaterialApp(
        title: 'Antigravity Console',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeMode,
        home: DashboardPage(
          themeMode: _themeMode,
          onThemeModeChange: _updateThemeMode,
          repository: widget.repository,
        ),
      ),
    );
  }
}

/// DashboardPage manages the dashboard view states and loads asset configuration.
class DashboardPage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<String> onThemeModeChange;
  final AbstractRepository repository;

  const DashboardPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChange,
    required this.repository,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Keep track of the activeView selection state (starts at 'Ingestion')
  String _activeView = 'Ingestion';
  late Future<String> _layoutConfigFuture;

  @override
  void initState() {
    super.initState();
    // Load 'assets/logical-layout.json' at startup
    _layoutConfigFuture = rootBundle.loadString('assets/logical-layout.json');
  }

  String _getThemeModeString() {
    switch (widget.themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _layoutConfigFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error loading layout configuration: ${snapshot.error}'),
            ),
          );
        }

        final layoutConfig = snapshot.data;

        // Render the Layout widget, passing the activeView, a callback to update activeView,
        // and nesting the PropertyGrid(activeView: activeView) as the child.
        return Layout(
          activeView: _activeView,
          onViewChange: (newView) {
            setState(() {
              _activeView = newView;
            });
          },
          layoutConfig: layoutConfig,
          themeMode: _getThemeModeString(),
          onThemeModeChange: widget.onThemeModeChange,
          repository: widget.repository,
          child: PropertyGrid(
            activeView: _activeView,
            initialValues: const {},
            onSave: (key, value) {},
          ),
        );
      },
    );
  }
}

