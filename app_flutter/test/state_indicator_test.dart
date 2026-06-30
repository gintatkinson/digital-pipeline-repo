import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/properties/state_indicator.dart';

void main() {
  testWidgets('renders nothing when state is null', (tester) async {
    await tester.pumpWidget(MaterialApp(home: StateIndicator()));
    expect(find.byType(Container), findsNothing);
  });

  testWidgets('renders chip with state label', (tester) async {
    await tester.pumpWidget(MaterialApp(home: StateIndicator(state: LifecycleState.active)));
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('discovered label is correct', (tester) async {
    await tester.pumpWidget(MaterialApp(home: StateIndicator(state: LifecycleState.discovered)));
    expect(find.text('Discovered'), findsOneWidget);
  });

  testWidgets('differs color per state', (tester) async {
    await tester.pumpWidget(MaterialApp(home: StateIndicator(state: LifecycleState.failed)));
    expect(find.text('Failed'), findsOneWidget);
  });
}
