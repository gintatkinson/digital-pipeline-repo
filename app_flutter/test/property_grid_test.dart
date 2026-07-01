import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/properties/property_grid.dart';

void main() {
  /// Returns true when [w] is a [Text] widget whose data equals [text].
  bool _isTextWithData(Widget w, String text) =>
      w is Text && w.data == text;

  /// Returns the label [Text] widget from the first child of [col], which is
  /// either a plain [Text] or a [Row] whose last child is the label [Text].
  Text? _findLabelTextInColumn(Column col, String labelText) {
    if (col.children.isEmpty) return null;
    final first = col.children.first;
    if (first is Text && first.data == labelText) return first;
    if (first is Row) {
      for (final c in first.children) {
        if (_isTextWithData(c, labelText)) return c as Text;
      }
    }
    return null;
  }

  Finder findTextFieldByLabel(String labelText) {
    final Finder columnFinder = find.byWidgetPredicate((Widget widget) {
      return widget is Column && _findLabelTextInColumn(widget, labelText) != null;
    });
    return find.descendant(
      of: columnFinder,
      matching: find.byType(TextField),
    );
  }

  Finder findDropdownByLabel(String labelText) {
    final Finder columnFinder = find.byWidgetPredicate((Widget widget) {
      return widget is Column && _findLabelTextInColumn(widget, labelText) != null;
    });
    return find.descendant(
      of: columnFinder,
      matching: find.byType(DropdownButtonFormField<String>),
    );
  }

  testWidgets('Highlights first section when activeView matches section label',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Primary',
            fields: const [
              FieldDescriptor(
                  key: 'f1',
                  label: 'Field 1',
                  type: 'string',
                  sectionLabel: 'Primary',
                  sectionOrder: 0),
              FieldDescriptor(
                  key: 'f2',
                  label: 'Field 2',
                  type: 'string',
                  sectionLabel: 'Secondary',
                  sectionOrder: 0),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Active Reference'), findsOneWidget);

    final List<Opacity> opacities =
        tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(opacities[0].opacity, 1.0);
    expect(opacities[1].opacity, 0.65);
  });

  testWidgets('Highlights first section when activeView is root',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'root',
            fields: const [
              FieldDescriptor(
                  key: 'f1',
                  label: 'Field 1',
                  type: 'string',
                  sectionLabel: 'Alpha',
                  sectionOrder: 0),
              FieldDescriptor(
                  key: 'f2',
                  label: 'Field 2',
                  type: 'string',
                  sectionLabel: 'Beta',
                  sectionOrder: 0),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Active Reference'), findsOneWidget);

    final List<Opacity> opacities =
        tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(opacities[0].opacity, 1.0);
    expect(opacities[1].opacity, 0.65);
  });

  testWidgets('Performs pattern validation on blur',
      (WidgetTester tester) async {
    Map<String, dynamic>? savedData;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'root',
            fields: const [
              FieldDescriptor(
                  key: 'code',
                  label: 'Code',
                  type: 'string',
                  pattern: r'^[A-Z]{2}$',
                  inputFormatters: ['uppercase', 'maxLength:2']),
            ],
            onSave: (data) async {
              savedData = data;
            },
          ),
        ),
      ),
    );

    final Finder codeField = findTextFieldByLabel('Code');
    expect(codeField, findsOneWidget);

    await tester.enterText(codeField, 'U1');
    await tester.pumpAndSettle();

    expect(savedData, isNull);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Invalid format'), findsOneWidget);
    expect(savedData, isNull);

    await tester.enterText(codeField, 'FI');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Invalid format'), findsNothing);
    // Blur does NOT call onSave
    expect(savedData, isNull);

    // Tap Save to commit
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedData, isNotNull);
    expect(savedData!['code'], 'FI');
  });

  testWidgets('Performs numeric min/max validation',
      (WidgetTester tester) async {
    Map<String, dynamic>? savedData;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'root',
            fields: const [
              FieldDescriptor(
                  key: 'value',
                  label: 'Value',
                  type: 'int',
                  minValue: 0,
                  maxValue: 100),
            ],
            onSave: (data) async {
              savedData = data;
            },
          ),
        ),
      ),
    );

    final Finder valueField = findTextFieldByLabel('Value');
    expect(valueField, findsOneWidget);

    await tester.enterText(valueField, '-1');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Value cannot be less than 0'), findsOneWidget);
    expect(savedData, isNull);

    await tester.enterText(valueField, '50');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Value cannot be less than 0'), findsNothing);
    // Blur does NOT call onSave
    expect(savedData, isNull);

    // Tap Save to commit
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedData!['value'], 50);

    await tester.enterText(valueField, '101');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Value cannot be greater than 100'), findsOneWidget);

    await tester.enterText(valueField, '100');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Value cannot be greater than 100'), findsNothing);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedData!['value'], 100);
  });

  testWidgets('Enum dropdown renders and commits on save',
      (WidgetTester tester) async {
    Map<String, dynamic>? savedData;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'root',
            fields: const [
              FieldDescriptor(
                  key: 'type',
                  label: 'Type',
                  type: 'enum',
                  enumOptions: ['a', 'b', 'c'],
                  enumDisplayNames: ['Option A', 'Option B', 'Option C']),
            ],
            onSave: (data) async {
              savedData = data;
            },
          ),
        ),
      ),
    );

    final Finder dropdownFinder = findDropdownByLabel('Type');
    expect(dropdownFinder, findsOneWidget);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Option C').last);
    await tester.pumpAndSettle();

    // Dropdown change does NOT call onSave
    expect(savedData, isNull);

    // Tap Save to commit
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedData, isNotNull);
    expect(savedData!['type'], 'c');
  });

  testWidgets('Tracks dirty state across text and enum edits',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            fields: const [
              FieldDescriptor(key: 'name', label: 'Name', type: 'string'),
              FieldDescriptor(
                  key: 'status',
                  label: 'Status',
                  type: 'enum',
                  enumOptions: ['active', 'inactive']),
            ],
            initialValues: {'name': 'Initial', 'status': 'active'},
          ),
        ),
      ),
    );

    final state = tester.state(find.byType(PropertyGrid)) as dynamic;

    expect(state.isDirty, isFalse);

    await tester.enterText(findTextFieldByLabel('Name'), 'Changed');
    await tester.pumpAndSettle();
    expect(state.isDirty, isTrue);

    await tester.enterText(findTextFieldByLabel('Name'), 'Initial');
    await tester.pumpAndSettle();
    expect(state.isDirty, isFalse);

    // Change enum → committedData NOT updated on blur, so field stays dirty
    await tester.tap(find.text('active'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('inactive').last);
    await tester.pumpAndSettle();
    expect(state.isDirty, isTrue);

    // Tap Save to commit → isDirty false
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(state.isDirty, isFalse);

    // Change enum back → dirty again
    await tester.tap(find.text('inactive').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('active').last);
    await tester.pumpAndSettle();
    expect(state.isDirty, isTrue);

    // Save again
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(state.isDirty, isFalse);
  });

  testWidgets('Save button fires onSave once with dirty fields',
      (WidgetTester tester) async {
    int saveCallCount = 0;
    Map<String, dynamic>? lastSaved;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            onSave: (data) async {
              saveCallCount++;
              lastSaved = Map<String, dynamic>.from(data);
            },
            fields: const [
              FieldDescriptor(
                  key: 'a',
                  label: 'A',
                  type: 'string',
                  sectionLabel: 'S',
                  sectionOrder: 0),
              FieldDescriptor(
                  key: 'b',
                  label: 'B',
                  type: 'string',
                  sectionLabel: 'S',
                  sectionOrder: 1),
            ],
          ),
        ),
      ),
    );

    // Edit field A
    await tester.enterText(findTextFieldByLabel('A'), 'valA');
    await tester.pumpAndSettle();

    // Unfocus A → triggers rebuild, validates, leaves committedData unchanged
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(saveCallCount, 0);

    // Edit field B (focuses B, text entered)
    await tester.enterText(findTextFieldByLabel('B'), 'valB');
    await tester.pumpAndSettle();

    // Tap Save once → onSave fires once with both fields
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saveCallCount, 1);
    expect(lastSaved!['a'], 'valA');
    expect(lastSaved!['b'], 'valB');
  });

  testWidgets('Blur validates but does not call onSave', (tester) async {
    Map<String, dynamic>? savedData;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            fields: const [
              FieldDescriptor(
                  key: 'code',
                  label: 'Code',
                  type: 'string',
                  pattern: r'^[A-Z]{2}$'),
            ],
            onSave: (data) async {
              savedData = data;
            },
          ),
        ),
      ),
    );

    final Finder codeField = findTextFieldByLabel('Code');

    await tester.enterText(codeField, 'ABC');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Invalid format'), findsOneWidget);
    expect(savedData, isNull);

    await tester.enterText(codeField, 'AB');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Invalid format'), findsNothing);
    expect(savedData, isNull);
  });

  testWidgets('Save button fires onSave with only dirty fields',
      (WidgetTester tester) async {
    Map<String, dynamic>? savedData;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            fields: const [
              FieldDescriptor(key: 'a', label: 'A', type: 'string'),
              FieldDescriptor(key: 'b', label: 'B', type: 'string'),
              FieldDescriptor(key: 'c', label: 'C', type: 'string'),
            ],
            initialValues: {'a': '1', 'b': '2', 'c': '3'},
            onSave: (data) async {
              savedData = data;
            },
          ),
        ),
      ),
    );

    final Finder fieldB = findTextFieldByLabel('B');
    await tester.enterText(fieldB, 'edited');
    await tester.pumpAndSettle();

    // Unfocus to trigger rebuild (blur validates but doesn't clear dirty)
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedData, hasLength(1));
    expect(savedData!['b'], 'edited');
  });

  testWidgets('Cancel reverts all edits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            fields: const [
              FieldDescriptor(key: 'name', label: 'Name', type: 'string'),
            ],
            initialValues: {'name': 'Original'},
          ),
        ),
      ),
    );

    final Finder nameField = findTextFieldByLabel('Name');
    await tester.enterText(nameField, 'Edited');
    await tester.pumpAndSettle();

    // Unfocus to trigger rebuild (blur validates but doesn't clear dirty)
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(PropertyGrid)) as dynamic;
    expect(state.isDirty, isTrue);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(nameField);
    expect(textField.controller!.text, 'Original');
    expect(state.isDirty, isFalse);
  });

  testWidgets('Save button not visible when not dirty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            fields: const [
              FieldDescriptor(key: 'name', label: 'Name', type: 'string'),
            ],
            initialValues: {'name': 'Same'},
          ),
        ),
      ),
    );

    expect(find.text('Save'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('PopScope blocks back navigation when dirty', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => navigatorKey.currentState!.push<void>(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: PropertyGrid(
                      fields: const [
                        FieldDescriptor(
                            key: 'name', label: 'Name', type: 'string'),
                      ],
                      initialValues: {'name': 'Original'},
                    ),
                  ),
                ),
              ),
              child: const Text('Open Grid'),
            ),
          ),
        ),
      ),
    );

    // Navigate to PropertyGrid
    await tester.tap(find.text('Open Grid'));
    await tester.pumpAndSettle();

    expect(find.byType(PropertyGrid), findsOneWidget);

    // Edit a field to make it dirty
    await tester.enterText(findTextFieldByLabel('Name'), 'Edited');
    await tester.pumpAndSettle();

    // Trigger back navigation — dialog should appear
    await navigatorKey.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(find.text('Discard unsaved changes?'), findsOneWidget);

    // Tap Cancel in the AlertDialog — stays on PropertyGrid
    final cancelInDialog = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Cancel'),
    );
    await tester.tap(cancelInDialog);
    await tester.pumpAndSettle();

    expect(find.byType(PropertyGrid), findsOneWidget);

    // Trigger back again
    await navigatorKey.currentState!.maybePop();
    await tester.pumpAndSettle();

    // Tap Discard — navigates away
    final discardBtn = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Discard'),
    );
    await tester.tap(discardBtn);
    await tester.pumpAndSettle();

    expect(find.byType(PropertyGrid), findsNothing);
    expect(find.text('Open Grid'), findsOneWidget);
  });

  testWidgets('readOnly mode disables all fields and hides Save/Cancel', (tester) async {
    final fields = [
      FieldDescriptor(key: 'name', label: 'Name', type: 'string'),
      FieldDescriptor(key: 'type', label: 'Type', type: 'enum', enumOptions: ['a', 'b']),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PropertyGrid(
        activeView: 'test',
        fields: fields,
        initialValues: {'name': 'hello', 'type': 'a'},
        readOnly: true,
      )),
    ));

    final textField = tester.widget<TextField>(find.byType(TextField).first);
    expect(textField.enabled, isFalse);

    expect(find.text('Save'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('refType field renders as clickable link', (tester) async {
    String? capturedRefType;
    String? capturedId;
    final fields = [
      FieldDescriptor(key: 'parent', label: 'Parent', type: 'string', refType: 'rack'),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PropertyGrid(
        activeView: 'test',
        fields: fields,
        initialValues: {'parent': 'rack-07'},
        readOnly: true,
        onViewSelected: (refType, id) { capturedRefType = refType; capturedId = id; },
      )),
    ));

    await tester.tap(find.text('rack-07'));
    expect(capturedRefType, equals('rack'));
    expect(capturedId, equals('rack-07'));
  });

  testWidgets('non-refType field renders normal text field', (tester) async {
    final fields = [
      FieldDescriptor(key: 'name', label: 'Name', type: 'string'),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PropertyGrid(
        activeView: 'test',
        fields: fields,
        initialValues: {'name': 'hello'},
      )),
    ));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('Dirty indicator appears next to edited fields',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            fields: const [
              FieldDescriptor(key: 'name', label: 'Name', type: 'string'),
              FieldDescriptor(key: 'status', label: 'Status', type: 'string'),
            ],
            initialValues: {'name': 'Original', 'status': 'OK'},
          ),
        ),
      ),
    );

    // Helper: finds the dirty indicator dot (Container with circle decoration).
    bool isDirtyDot(Widget w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).shape == BoxShape.circle;

    // No indicators when pristine.
    expect(find.byWidgetPredicate(isDirtyDot), findsNothing);

    // Edit one field.
    await tester.enterText(findTextFieldByLabel('Name'), 'Edited');
    await tester.pumpAndSettle();

    // Dirty dot appears.
    expect(find.byWidgetPredicate(isDirtyDot), findsOneWidget);

    // Save clears the indicator.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate(isDirtyDot), findsNothing);
  });
}
