import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/components/layout.dart';
import 'package:app_flutter/components/property_grid.dart';

late final SqliteRepositoryAdapter repository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Open database
  final db = await databaseFactory.openDatabase('properties_db.db');

  // Create table
  await db.execute(
    'CREATE TABLE IF NOT EXISTS properties (node_id TEXT PRIMARY KEY, data_json TEXT NOT NULL);',
  );

  // If the table is empty, pre-seed it
  final List<Map<String, dynamic>> countResult = await db.rawQuery('SELECT COUNT(*) as count FROM properties');
  final int count = countResult.first['count'] as int? ?? 0;
  if (count == 0) {
    final defaultMap = {
      "latitude": 37.7749,
      "longitude": -122.4194,
      "altitude": 10.0,
      "roomName": "Main-Data-Room",
      "gridRow": 12,
      "gridColumn": 4,
      "maxVoltage": 240.0,
      "maxAllocatedPower": 15000.0,
      "countryCode": "US",
      "locationType": "room"
    };
    final defaultJson = jsonEncode(defaultMap);
    final List<String> nodes = ['Ingestion', 'Metrics', 'Location', 'Chassis', 'Epics', 'Traceability'];
    for (final node in nodes) {
      await db.insert('properties', {'node_id': node, 'data_json': defaultJson});
    }
  }

  repository = SqliteRepositoryAdapter(db);

  runApp(MyApp(repository: repository));
}

/// MyApp is the root application widget that initializes the application theme and layout configurations.
class MyApp extends StatefulWidget {
  final AbstractRepository repository;
  const MyApp({super.key, required this.repository});

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
    // Configure theme data for Light, Dark, and System modes matching the design tokens
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1A73E8),
      scaffoldBackgroundColor: Colors.white,
      cardColor: const Color(0xFFF1F3F4),
      dividerColor: const Color(0xFFDADCE0),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A73E8),
        brightness: Brightness.light,
      ),
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1A73E8),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF202124),
      dividerColor: const Color(0xFF3C4043),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A73E8),
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Antigravity Console',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: DashboardPage(
        themeMode: _themeMode,
        onThemeModeChange: _updateThemeMode,
        repository: widget.repository,
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
          ),
        );
      },
    );
  }
}

