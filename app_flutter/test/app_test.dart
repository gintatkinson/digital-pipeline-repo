import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pipeline_app/app.dart';
import 'package:pipeline_app/core/theme_controller.dart';
import 'package:pipeline_app/core/text_scaler.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';
import 'package:pipeline_app/features/tree/tree_view_model.dart';

class _FakeRepo implements Repository {
  @override
  Future<List<TypeDescriptor>> discoverTypes() async => [
    TypeDescriptor(typeName: 'Type0', displayName: 'Type 0', iconName: 'data_object'),
    TypeDescriptor(typeName: 'Type1', displayName: 'Type 1', iconName: 'data_object'),
  ];
  @override
  Future<TypeDescriptor?> typeFor(String typeName) async => null;
  @override
  Future<List<InstanceDescriptor>> discoverInstances() async => [
    InstanceDescriptor(nodeId: 'Type0-000', typeName: 'Type0', displayLabel: 'Type 0 Type0-000'),
    InstanceDescriptor(nodeId: 'Type0-001', typeName: 'Type0', displayLabel: 'Type 0 Type0-001'),
    InstanceDescriptor(nodeId: 'Type0-002', typeName: 'Type0', displayLabel: 'Type 0 Type0-002'),
  ];
  @override
  Future<Map<String, dynamic>?> fetchProperties(String nodeId) async => null;
  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}
  @override
  Future<List<Map<String, dynamic>>> fetchChildren(String nodeId, String relationName) async => [];
  @override
  void close() {}
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('PipelineApp renders sidebar with seeded data', (tester) async {
    final repo = _FakeRepo();
    final tvm = TreeViewModel(repo);
    await tvm.load();
    final prefs = await SharedPreferences.getInstance();
    final tc = ThemeController(prefs);
    final tsc = TextScaleController();

    await tester.pumpWidget(PipelineApp(repository: repo, treeViewModel: tvm, themeController: tc, textScaleController: tsc));
    await tester.pump();
    expect(find.text('Type 0 Type0-000'), findsOneWidget);
  });
}
