import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/domain/column_model.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';
import 'package:app_flutter/features/tables/table_view_widget.dart';

/// A test subclass that exposes setter methods for overriding internal state.
class _TestTablesViewModel extends TablesViewModel {
  _TestTablesViewModel(super.dataSource, super.activeView);

  @override
  List<String> get headers => _overrideHeaders;
  List<String> _overrideHeaders = [];

  @override
  List<ColumnModel> get columnModels => _overrideColumnModels;
  List<ColumnModel> _overrideColumnModels = [];

  @override
  List<List<String>> get rows => _overrideRows;
  List<List<String>> _overrideRows = [];

  @override
  bool get loading => _overrideLoading;
  bool _overrideLoading = false;

  void setState({
    List<String>? headers,
    List<ColumnModel>? columnModels,
    List<List<String>>? rows,
    bool? loading,
  }) {
    if (headers != null) _overrideHeaders = headers;
    if (columnModels != null) _overrideColumnModels = columnModels;
    if (rows != null) _overrideRows = rows;
    if (loading != null) _overrideLoading = loading;
    notifyListeners();
  }
}

class _MockDataSource implements DataSource {
  _MockDataSource({this.fields = const []});

  final List<FieldDescriptor> fields;

  @override
  String get name => 'mock';

  @override
  Future<List<TypeDescriptor>> discoverTypes() async => [];

  @override
  Future<TypeDescriptor?> typeFor(String typeName) async => null;

  @override
  Future<List<(String, String)>> discoverHierarchy() async => [];

  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* { yield {}; }

  @override
  Future<List<Map<String, dynamic>>> fetchElements(String parentNodeId) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchAlarms(String parentNodeId) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchEvents(String parentNodeId) async => [];
}

Widget buildTableWithModel({
  required List<String> headers,
  required List<ColumnModel> columnModels,
  List<List<String>> rows = const [],
}) {
  final viewModel = _TestTablesViewModel(_MockDataSource(), 'Root');
  viewModel.setState(
    headers: headers,
    columnModels: columnModels,
    rows: rows,
    loading: false,
  );

  return MaterialApp(
    home: ChangeNotifierProvider<TablesViewModel>.value(
      value: viewModel,
      child: const TableViewWidget(),
    ),
  );
}

void main() {
  group('TableViewWidget header rendering', () {
    testWidgets('renders labels from ColumnModel when available', (tester) async {
      await tester.pumpWidget(buildTableWithModel(
        headers: ['Alpha', 'Beta', 'Gamma'],
        columnModels: [
          const ColumnModel(key: 'a', label: 'Alpha', type: 'string'),
          const ColumnModel(key: 'b', label: 'Beta', type: 'string'),
          const ColumnModel(key: 'c', label: 'Gamma', type: 'string'),
        ],
      ));

      await tester.pump();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('falls back to raw headers when ColumnModel is empty', (tester) async {
      await tester.pumpWidget(buildTableWithModel(
        headers: ['Alpha', 'Beta', 'Gamma'],
        columnModels: [],
      ));

      await tester.pump();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('column count matches FieldDescriptor count', (tester) async {
      await tester.pumpWidget(buildTableWithModel(
        headers: ['Alpha', 'Beta', 'Gamma'],
        columnModels: [
          const ColumnModel(key: 'a', label: 'Alpha', type: 'string'),
          const ColumnModel(key: 'b', label: 'Beta', type: 'string'),
          const ColumnModel(key: 'c', label: 'Gamma', type: 'string'),
        ],
        rows: [
          ['v1', 'v2', 'v3'],
        ],
      ));

      await tester.pump();

      // 3 header cells + 3 data cells = 6 total Text widgets expected
      expect(find.byType(Text), findsNWidgets(6));
    });

    testWidgets('falls back per-column when columnModels has fewer entries than headers', (tester) async {
      await tester.pumpWidget(buildTableWithModel(
        headers: ['Alpha', 'Beta', 'Gamma'],
        columnModels: [
          const ColumnModel(key: 'a', label: 'Custom A', type: 'string'),
        ],
      ));

      await tester.pump();

      expect(find.text('Custom A'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });
  });

  group('TableViewWidget cell type rendering', () {
    testWidgets('renders string cells as plain Text', (tester) async {
      await tester.pumpWidget(buildTableWithModel(
        headers: ['Name'],
        columnModels: [
          const ColumnModel(key: 'name', label: 'Name', type: 'string'),
        ],
        rows: [
          ['Alice'],
        ],
      ));

      await tester.pump();

      final textWidget = tester.widget<Text>(find.text('Alice'));
      expect(textWidget.textAlign, isNull);
    });

    testWidgets('renders int cells right-aligned with monospace font', (tester) async {
      await tester.pumpWidget(buildTableWithModel(
        headers: ['Name', 'Count'],
        columnModels: [
          const ColumnModel(key: 'name', label: 'Name', type: 'string'),
          const ColumnModel(key: 'count', label: 'Count', type: 'int'),
        ],
        rows: [
          ['Foo', '42'],
        ],
      ));

      await tester.pump();

      final countText = tester.widget<Text>(find.text('42'));
      expect(countText.textAlign, TextAlign.right);
      expect(countText.style?.fontFamily, 'monospace');
    });

    testWidgets('renders double cells right-aligned with monospace font', (tester) async {
      await tester.pumpWidget(buildTableWithModel(
        headers: ['Value'],
        columnModels: [
          const ColumnModel(key: 'val', label: 'Value', type: 'double'),
        ],
        rows: [
          ['3.14'],
        ],
      ));

      await tester.pump();

      final valText = tester.widget<Text>(find.text('3.14'));
      expect(valText.textAlign, TextAlign.right);
      expect(valText.style?.fontFamily, 'monospace');
    });

    testWidgets('renders enum-type cells as chips', (tester) async {
      await tester.pumpWidget(buildTableWithModel(
        headers: ['Status'],
        columnModels: [
          const ColumnModel(key: 'status', label: 'Status', type: 'enum'),
        ],
        rows: [
          ['Active'],
        ],
      ));

      await tester.pump();

      final textFinder = find.text('Active');
      final ancestorContainer = find.ancestor(
        of: textFinder,
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(ancestorContainer.first);
      expect(container.decoration, isNotNull);
    });

    testWidgets('renders date-type cells formatted', (tester) async {
      await tester.pumpWidget(buildTableWithModel(
        headers: ['Date'],
        columnModels: [
          const ColumnModel(key: 'date', label: 'Date', type: 'date'),
        ],
        rows: [
          ['2024-01-15T00:00:00'],
        ],
      ));

      await tester.pump();

      expect(find.text('2024-01-15'), findsOneWidget);
    });
  });
}
