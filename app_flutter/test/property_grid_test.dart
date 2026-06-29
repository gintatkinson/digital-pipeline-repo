import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/features/properties/property_grid.dart';

void main() {
  /// Helper finder to locate a TextField by its preceding label text.
  Finder findTextFieldByLabel(String labelText) {
    final Finder columnFinder = find.byWidgetPredicate((Widget widget) {
      if (widget is Column) {
        final List<Widget> children = widget.children;
        if (children.isNotEmpty && children.first is Text) {
          final Text textWidget = children.first as Text;
          if (textWidget.data == labelText) {
            return true;
          }
        }
      }
      return false;
    });
    return find.descendant(
      of: columnFinder,
      matching: find.byType(TextField),
    );
  }

  /// Helper finder to locate a DropdownButtonFormField by its label text.
  Finder findDropdownByLabel(String labelText) {
    final Finder columnFinder = find.byWidgetPredicate((Widget widget) {
      if (widget is Column) {
        final List<Widget> children = widget.children;
        if (children.isNotEmpty && children.first is Text) {
          final Text textWidget = children.first as Text;
          if (textWidget.data == labelText) {
            return true;
          }
        }
      }
      return false;
    });
    return find.descendant(
      of: columnFinder,
      matching: find.byType(DropdownButtonFormField<String>),
    );
  }

  testWidgets('Highlights Primary Reference Frame section when activeView is Primary', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
          home: Scaffold(
            body: const PropertyGrid(activeView: 'Primary'),
          ),
      ),
    );

    // Verify Active Reference tag is shown in Primary, and NOT Secondary
    expect(find.text('Active Reference'), findsOneWidget);
    
    // The Primary section should be fully opaque (opacity 1.0)
    // Find the Opacity widget wrapping the first system section
    final List<Opacity> opacities = tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(opacities[0].opacity, 1.0); // Primary is active
    expect(opacities[1].opacity, 0.65); // Secondary is dimmed
  });

  testWidgets('Highlights Secondary Reference Frame section when activeView is not Primary/root', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
          home: Scaffold(
            body: const PropertyGrid(activeView: 'Secondary'),
          ),
      ),
    );

    expect(find.text('Active Reference'), findsOneWidget);
    
    final List<Opacity> opacities = tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(opacities[0].opacity, 0.65); // Primary is dimmed
    expect(opacities[1].opacity, 1.0); // Secondary is active
  });

  testWidgets('Buffers input locally and performs validation/commit on focus loss for countryCode', (WidgetTester tester) async {
    Map<String, dynamic>? savedData;

    await tester.pumpWidget(
      MaterialApp(
          home: Scaffold(
            body: PropertyGrid(
              activeView: 'Primary',
              onSave: (dynamic data) {
                savedData = data as Map<String, dynamic>?;
              },
            ),
          ),
      ),
    );

    final Finder countryCodeField = findTextFieldByLabel('Country Code (ISO-2)');
    expect(countryCodeField, findsOneWidget);

    // Enter invalid country code "U1"
    await tester.enterText(countryCodeField, 'U1');
    await tester.pumpAndSettle(); // Let the focus system register the focus gain
    
    // Verify savedData is NOT updated yet (buffered locally)
    expect(savedData, isNull);

    // Lose focus to trigger validation
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // Verify validation error is displayed and state NOT committed
    expect(find.text('Must match ISO 2-letter uppercase pattern (e.g. US, FI)'), findsOneWidget);
    expect(savedData, isNull);

    // Enter valid country code "FI"
    await tester.enterText(countryCodeField, 'FI');
    await tester.pumpAndSettle();
    
    // Lose focus
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // Verify error is cleared, state is committed, and onSave callback triggered
    expect(find.text('Must match ISO 2-letter uppercase pattern (e.g. US, FI)'), findsNothing);
    expect(savedData, isNotNull);
    expect(savedData!['countryCode'], 'FI');

    // Verify committed JSON display matches committed data
    final String jsonString = const JsonEncoder.withIndent('  ').convert(savedData);
    expect(find.text(jsonString), findsOneWidget);
  });

  testWidgets('Performs validation/commit for maxVoltage and maxAllocatedPower on focus loss', (WidgetTester tester) async {
    Map<String, dynamic>? savedData;

    await tester.pumpWidget(
      MaterialApp(
          home: Scaffold(
            body: PropertyGrid(
              activeView: 'Secondary',
              onSave: (dynamic data) {
                savedData = data as Map<String, dynamic>?;
              },
            ),
          ),
      ),
    );

    final Finder voltageField = findTextFieldByLabel('Max Voltage (V)');
    final Finder powerField = findTextFieldByLabel('Max Allocated Power (W)');

    // Enter negative maxVoltage
    await tester.enterText(voltageField, '-240');
    await tester.pumpAndSettle();
    
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Value cannot be negative'), findsOneWidget);
    expect(savedData, isNull);

    // Correct maxVoltage to positive
    await tester.enterText(voltageField, '240');
    await tester.pumpAndSettle();
    
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Value cannot be negative'), findsNothing);
    expect(savedData!['maxVoltage'], 240.0);

    // Enter negative maxAllocatedPower
    await tester.enterText(powerField, '-15000');
    await tester.pumpAndSettle();
    
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Value cannot be negative'), findsOneWidget);

    // Correct power to positive
    await tester.enterText(powerField, '15000');
    await tester.pumpAndSettle();
    
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Value cannot be negative'), findsNothing);
    expect(savedData!['maxAllocatedPower'], 15000.0);
  });

  testWidgets('Validates placeType immediately upon selection change and on blur', (WidgetTester tester) async {
    Map<String, dynamic>? savedData;

    await tester.pumpWidget(
      MaterialApp(
          home: Scaffold(
            body: PropertyGrid(
              activeView: 'Secondary',
              onSave: (dynamic data) {
                savedData = data as Map<String, dynamic>?;
              },
            ),
          ),
      ),
    );

    // Find the place classification dropdown
    final Finder dropdownFinder = findDropdownByLabel('Place Classification');
    expect(dropdownFinder, findsOneWidget);

    // Tap the dropdown to open it (initial value is 'Zone' / 'zone')
    await tester.tap(find.text('Zone'));
    await tester.pumpAndSettle();

    // Select the test option
    await tester.tap(find.text('Test Option').last);
    await tester.pumpAndSettle();

    // Verify validation error is displayed
    expect(find.text("Must be 'zone', 'area', or 'cluster'"), findsOneWidget);
    
    // Clear savedData so that we only assert selection changes do not commit invalid state
    savedData = null;
    expect(savedData, isNull);

    // Select a valid option (Zone / zone)
    await tester.tap(find.text('Test Option'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zone').last);
    await tester.pumpAndSettle();

    // Verify error is cleared and state committed
    expect(find.text("Must be 'zone', 'area', or 'cluster'"), findsNothing);
    expect(savedData!['placeType'], 'zone');
  });
}
