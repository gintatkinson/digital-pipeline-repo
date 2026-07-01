import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/domain/column_model.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/action_descriptor.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/tables/cell_renderer.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';
import 'package:app_flutter/features/tables/table_view_widget.dart';

class _TestTablesViewModel extends TablesViewModel {
  _TestTablesViewModel(super.dataSource, super.activeView);

  @override
  List<ColumnModel> get headers => _overrideHeaders;
  List<ColumnModel> _overrideHeaders = [];

  Set<String> _overrideHiddenKeys = {};

  @override
  List<ColumnModel> get visibleColumnModels =>
      _overrideHeaders
          .where((cm) => cm.visible)
          .where((cm) => _overrideHiddenKeys.isEmpty || !_overrideHiddenKeys.contains(cm.key))
          .toList();

  @override
  List<ColumnModel> get columnModels => _overrideColumnModels;
  List<ColumnModel> _overrideColumnModels = [];

  @override
  List<List<String>> get rows => _overrideRows;
  List<List<String>> _overrideRows = [];

  @override
  List<List<String?>> get rawIds => _overrideRawIds;
  List<List<String?>> _overrideRawIds = [];

  @override
  bool get loading => _overrideLoading;
  bool _overrideLoading = false;

  @override
  String? get error => _overrideError;
  String? _overrideError;

  void setState({
    List<ColumnModel>? headers,
    List<ColumnModel>? columnModels,
    List<List<String>>? rows,
    List<List<String?>>? rawIds,
    bool? loading,
    String? error,
    Set<String>? hiddenKeys,
  }) {
    if (headers != null) _overrideHeaders = headers;
    if (columnModels != null) _overrideColumnModels = columnModels;
    if (rows != null) _overrideRows = rows;
    if (rawIds != null) _overrideRawIds = rawIds;
    if (loading != null) _overrideLoading = loading;
    if (error != null) _overrideError = error;
    if (hiddenKeys != null) _overrideHiddenKeys = hiddenKeys;
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

  @override
  Future<String> resolveLabel(String typeName, String id) async => '';
  @override
  Future<List<ActionDescriptor>> getActions(String typeName) async => [];
  @override
  Future<Map<String, dynamic>> invokeAction(String t, String i, String a, Map<String, dynamic> p) async => {};
}

Widget buildTableFromModel({
  required _TestTablesViewModel model,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<TablesViewModel>.value(
      value: model,
      child: const TableViewWidget(),
    ),
  );
}

void main() {
  testWidgets('sort cache eliminates redundant O(n log n) sort in build()', (tester) async {
    final columns = [
      const ColumnModel(key: 'a', label: 'Name', type: 'string', sortable: true),
    ];

    // 1000 rows for a measurable sort time
    final rows = List<List<String>>.generate(
      1000,
      (i) => ['Value_${i.toString().padLeft(4, '0')}'],
    );

    final model = _TestTablesViewModel(_MockDataSource(), 'Root');
    model.setState(
      headers: columns,
      columnModels: columns,
      rows: rows,
      loading: false,
    );

    await tester.pumpWidget(buildTableFromModel(model: model));
    await tester.pump();

    // Activate sort by tapping header
    await tester.tap(find.text('Name'));
    // The first pump after tap processes setState from onSort callback.
    // This is the cold cache build — build() does List.from + sort.
    // We measure this pump time.
    final stopwatchCold = Stopwatch()..start();
    await tester.pump();
    stopwatchCold.stop();
    final coldPumpTime = stopwatchCold.elapsedMicroseconds;
    print('Pump time (cold cache, first sort): ${coldPumpTime}µs');

    // Unrelated notifyListeners() — no sort state change.
    // With the cache, build() skips List.from + sort entirely.
    // This should be faster than the cold cache pump.
    final stopwatchWarm1 = Stopwatch()..start();
    model.notifyListeners();
    await tester.pump();
    stopwatchWarm1.stop();
    final warmPumpTime1 = stopwatchWarm1.elapsedMicroseconds;
    print('Pump time (warm cache, no change):   ${warmPumpTime1}µs');

    // Second unrelated notifyListeners — cache hit again.
    final stopwatchWarm2 = Stopwatch()..start();
    model.notifyListeners();
    await tester.pump();
    stopwatchWarm2.stop();
    final warmPumpTime2 = stopwatchWarm2.elapsedMicroseconds;
    print('Pump time (warm cache, no change):   ${warmPumpTime2}µs');

    // Toggle sort direction — this invalidates the cache.
    await tester.tap(find.textContaining('Name'));
    // Cold cache again for descending sort
    final stopwatchCold2 = Stopwatch()..start();
    await tester.pump();
    stopwatchCold2.stop();
    final coldPumpTime2 = stopwatchCold2.elapsedMicroseconds;
    print('Pump time (cold cache, toggle dir):  ${coldPumpTime2}µs');

    print('');
    print('--- Validation ---');
    print('Cold: ${coldPumpTime}µs, ${coldPumpTime2}µs | Warm: ${warmPumpTime1}µs, ${warmPumpTime2}µs');

    // Warm cache pumps should not be slower than cold cache pumps.
    // (The warm pump skips the O(n log n) sort entirely.)
    expect(warmPumpTime1, lessThanOrEqualTo(coldPumpTime + 100),
      reason: 'Warm cache pump should not be slower than cold cache pump');
    expect(warmPumpTime2, lessThanOrEqualTo(coldPumpTime + 100),
      reason: 'Warm cache pump should not be slower than cold cache pump');
    expect(warmPumpTime1, lessThanOrEqualTo(coldPumpTime2 + 100),
      reason: 'Warm cache pump should not be slower than cold cache pump');
    expect(warmPumpTime2, lessThanOrEqualTo(coldPumpTime2 + 100),
      reason: 'Warm cache pump should not be slower than cold cache pump');

    // Verify correct sort behavior
    model.notifyListeners();
    await tester.pump();
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => t.data != null && t.data!.startsWith('Value_'))
        .map((t) => t.data!)
        .toList();
    expect(texts.length, greaterThan(0));
    // After toggling sort direction (now descending on ascending toggle),
    // the first visible row should be the last value.
    // Since we tapped again after ascending, it's now descending:
    // We started with no sort → tap "Name" → ascending → tap again → descending
    expect(texts.first, 'Value_0999');

    // Now clear sort by tapping unsortable... actually we can disable sort
    // by changing headers. Let's just verify asc/desc correctness.
  });
}
