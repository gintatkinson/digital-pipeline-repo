import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:app_flutter/domain/database_initializer.dart';
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

  final db = await DatabaseInitializer.create();
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

