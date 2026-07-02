import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/features/detail/table_panel.dart';

void main() {
  const tabs = ['rel_1', 'rel_2'];
  const data = <String, List<Map<String, dynamic>>>{
    'rel_1': [{'id': 'c1', 'col_0': 'x', 'col_1': 1}],
    'rel_2': [],
  };

  testWidgets('renders tabs and virtualized table', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TablePanel(tabLabels: tabs, tableData: data),
      ),
    ));
    await tester.pump();
    expect(find.text('rel_1'), findsOneWidget);
    expect(find.text('rel_2'), findsOneWidget);
    expect(find.text('col_0'), findsOneWidget);
    expect(find.text('id'), findsOneWidget);
  });
}
