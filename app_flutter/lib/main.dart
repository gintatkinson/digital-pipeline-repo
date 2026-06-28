import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:app_flutter/core/design_tokens.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/domain/repository_resolver.dart';
import 'package:app_flutter/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final tokensJson = await rootBundle.loadString('assets/design-tokens.json');
    final registry = AppDesignTokenRegistry.parse(tokensJson);

    final repository = await RepositoryResolver.resolve();

    runApp(
      Provider<AbstractRepository>.value(
        value: repository,
        child: MyApp(registry: registry),
      ),
    );
  } catch (e, st) {
    debugPrint('FATAL ERROR in main(): $e\n$st');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Startup error:\n$e'),
          ),
        ),
      ),
    );
  }
}
