import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';
import 'package:pipeline_app/features/tree/tree_view_model.dart';
import 'package:pipeline_app/features/tree/tree_sidebar.dart';

class _FakeRepo implements Repository {
  final List<InstanceDescriptor> _instances;

  _FakeRepo(this._instances);

  @override
  Future<List<TypeDescriptor>> discoverTypes() async => [
    TypeDescriptor(typeName: 'Type0', displayName: 'Type 0', iconName: 'data_object'),
  ];
  @override
  Future<TypeDescriptor?> typeFor(String typeName) async => null;
  @override
  Future<List<InstanceDescriptor>> discoverInstances() async => _instances;
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
  testWidgets('renders instance list and supports selection', (tester) async {
    final repo = _FakeRepo([
      InstanceDescriptor(nodeId: 'Type0-000', typeName: 'Type0', displayLabel: 'Type 0 Type0-000'),
      InstanceDescriptor(nodeId: 'Type0-001', typeName: 'Type0', displayLabel: 'Type 0 Type0-001'),
    ]);
    final vm = TreeViewModel(repo);
    await vm.load();
    String? selected;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: TreeSidebar(
      viewModel: vm, onNodeSelected: (id) => selected = id, onSettingsPressed: () {},
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Type 0 Type0-000'), findsOneWidget);
    await tester.tap(find.text('Type 0 Type0-000'));
    await tester.pumpAndSettle();
    expect(selected, 'Type0-000');
  });
}
