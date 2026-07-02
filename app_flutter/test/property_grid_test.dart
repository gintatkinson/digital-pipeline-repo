import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';
import 'package:pipeline_app/features/detail/property_grid.dart';

void main() {
  const fields = [
    FieldDescriptor(key: 'attr_01', label: 'I_01', type: FieldType.int_),
    FieldDescriptor(key: 'attr_02', label: 'S_02', type: FieldType.string, sectionLabel: 'G_01', sectionOrder: 1),
  ];

  testWidgets('renders form fields and save/cancel buttons', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PropertyGrid(
          fields: fields,
          properties: const {'attr_01': 42, 'attr_02': 'hello'},
          onSave: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('I_01'), findsOneWidget);
    expect(find.text('S_02'), findsOneWidget);
    expect(find.text('G_01'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
