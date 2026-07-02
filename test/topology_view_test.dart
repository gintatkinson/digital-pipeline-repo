import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';
import 'package:pipeline_app/features/detail/topology_view_model.dart';
import 'package:pipeline_app/features/detail/topology_view.dart';

class _FakeRepo implements Repository {
  @override
  Future<List<TypeDescriptor>> discoverTypes() async => [];
  @override
  Future<TypeDescriptor?> typeFor(String typeName) async => null;
  @override
  Future<List<InstanceDescriptor>> discoverInstances() async => [];
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
  testWidgets('renders header and loading text when empty', (tester) async {
    final vm = TopologyViewModel(_FakeRepo());
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: TopologyView(viewModel: vm, onNodeSelected: (_) {}))));
    await tester.pump();
    expect(find.text('Loading...'), findsOneWidget);
  });
}
