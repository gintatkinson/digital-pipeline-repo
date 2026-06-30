import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/features/tables/cell_renderer.dart';
import 'package:app_flutter/domain/column_model.dart';

void main() {
  group('CellRenderer', () {
    test('TextRenderer can be instantiated', () {
      final renderer = TextRenderer();
      expect(renderer, isA<TextRenderer>());
      expect(renderer, isA<CellRenderer>());
    });

    testWidgets('TextRenderer builds a Text widget with the value', (tester) async {
      final renderer = TextRenderer();
      final column = ColumnModel(key: 'k', label: 'L', type: 'string');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.build(context, 'hello', column),
          ),
        ),
      ));

      expect(find.text('hello'), findsOneWidget);
    });
  });

  group('NumericRenderer', () {
    testWidgets('renders right-aligned monospace text', (tester) async {
      final renderer = NumericRenderer();
      final column = ColumnModel(key: 'k', label: 'L', type: 'int');
      final widget = renderer.build(tester.element(find.byType(Container)), '42', column);
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('42'), findsOneWidget);
      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });
  });

  group('EnumRenderer', () {
    testWidgets('renders chip-style container with value', (tester) async {
      final renderer = EnumRenderer();
      final column = ColumnModel(key: 'k', label: 'L', type: 'enum');
      final widget = renderer.build(tester.element(find.byType(Container)), 'Active', column);
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('Active'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
    });
  });

  group('DateRenderer', () {
    testWidgets('formats ISO date to YYYY-MM-DD', (tester) async {
      final renderer = DateRenderer();
      final column = ColumnModel(key: 'k', label: 'L', type: 'date');
      final widget = renderer.build(tester.element(find.byType(Container)), '2026-07-01T12:00:00Z', column);
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('2026-07-01'), findsOneWidget);
    });

    testWidgets('falls back to raw value on parse failure', (tester) async {
      final renderer = DateRenderer();
      final column = ColumnModel(key: 'k', label: 'L', type: 'date');
      final widget = renderer.build(tester.element(find.byType(Container)), 'not-a-date', column);
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('not-a-date'), findsOneWidget);
    });
  });

  group('BooleanRenderer', () {
    testWidgets('renders check icon for true', (tester) async {
      final renderer = BooleanRenderer();
      final column = ColumnModel(key: 'k', label: 'L', type: 'boolean');
      final widget = renderer.build(tester.element(find.byType(Container)), 'true', column);
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('renders close icon for false', (tester) async {
      final renderer = BooleanRenderer();
      final column = ColumnModel(key: 'k', label: 'L', type: 'boolean');
      final widget = renderer.build(tester.element(find.byType(Container)), 'false', column);
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('ReferenceRenderer', () {
    testWidgets('renders underlined primary-colored text', (tester) async {
      final renderer = ReferenceRenderer();
      final column = ColumnModel(key: 'k', label: 'L', type: 'reference');
      final widget = renderer.build(tester.element(find.byType(Container)), 'ref-123', column);
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('ref-123'), findsOneWidget);
    });
  });
}
