import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pipeline_app/app.dart';
import 'package:pipeline_app/core/theme_controller.dart';
import 'package:pipeline_app/core/text_scaler.dart';
import 'package:pipeline_app/domain/repository_resolver.dart';
import 'package:pipeline_app/features/tree/tree_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (repository, _) = await RepositoryResolver.resolve(dataSourceType: 'sqlite');

  final sharedPrefs = await SharedPreferences.getInstance();
  final themeController = ThemeController(sharedPrefs);
  themeController.loadSettings();

  final textScaleController = TextScaleController();
  await textScaleController.load();

  final treeViewModel = TreeViewModel(repository);
  await treeViewModel.load();

  runApp(PipelineApp(
    repository: repository,
    treeViewModel: treeViewModel,
    themeController: themeController,
    textScaleController: textScaleController,
  ));
}
