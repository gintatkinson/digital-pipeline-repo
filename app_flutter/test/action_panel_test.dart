import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/action_descriptor.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/properties/action_panel.dart';

void main() {
  group('ActionPanel', () {
    testWidgets('Empty actions list renders nothing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: [],
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, _, __) async => const {'success': true, 'message': ''},
            ),
          ),
        ),
      );

      expect(find.byType(ActionPanel), findsOneWidget);
      expect(find.text('Actions'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('Actions render as buttons with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: const [
                ActionDescriptor(name: 'reboot', label: 'Reboot', iconName: 'refresh'),
                ActionDescriptor(name: 'deploy', label: 'Deploy', iconName: 'cloud_upload'),
              ],
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, _, __) async => const {'success': true, 'message': ''},
            ),
          ),
        ),
      );

      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Reboot'), findsOneWidget);
      expect(find.text('Deploy'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('Destructive action shows confirmation dialog', (WidgetTester tester) async {
      final invoked = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: const [
                ActionDescriptor(name: 'delete', label: 'Delete', iconName: 'delete', destructive: true),
              ],
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, name, __) async {
                invoked.add(name);
                return const {'success': true, 'message': ''};
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.textContaining('side effects'), findsOneWidget);

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(invoked, isEmpty);
    });

    testWidgets('Non-destructive action without confirmation fires directly', (WidgetTester tester) async {
      final invoked = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: const [
                ActionDescriptor(name: 'reboot', label: 'Reboot', iconName: 'refresh'),
              ],
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, name, __) async {
                invoked.add(name);
                return const {'success': true, 'message': 'Reboot completed'};
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reboot'));
      await tester.pumpAndSettle();

      expect(invoked, contains('reboot'));
    });

    testWidgets('Provisioning state disables all buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: const [
                ActionDescriptor(name: 'reboot', label: 'Reboot', iconName: 'refresh'),
                ActionDescriptor(name: 'delete', label: 'Delete', iconName: 'delete', destructive: true),
              ],
              lifecycleState: LifecycleState.provisioning,
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, _, __) async => const {'success': true, 'message': ''},
            ),
          ),
        ),
      );

      final buttons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      for (final button in buttons) {
        expect(button.onPressed, isNull);
      }
    });

    testWidgets('Failed state disables destructive but enables non-destructive',
        (WidgetTester tester) async {
      final invoked = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: const [
                ActionDescriptor(name: 'reboot', label: 'Reboot', iconName: 'refresh'),
                ActionDescriptor(name: 'delete', label: 'Delete', iconName: 'delete', destructive: true),
              ],
              lifecycleState: LifecycleState.failed,
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, name, __) async {
                invoked.add(name);
                return const {'success': true, 'message': ''};
              },
            ),
          ),
        ),
      );

      final rebootButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Reboot'),
      );
      final deleteButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Delete'),
      );

      expect(rebootButton.onPressed, isNotNull);
      expect(deleteButton.onPressed, isNull);

      await tester.tap(find.text('Reboot'));
      await tester.pumpAndSettle();
      expect(invoked, contains('reboot'));
    });

    testWidgets('Successful invocation shows SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: const [
                ActionDescriptor(name: 'reboot', label: 'Reboot', iconName: 'refresh'),
              ],
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, _, __) async => const {'success': true, 'message': 'Device rebooted'},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reboot'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Device rebooted'), findsOneWidget);
    });

    testWidgets('Failed invocation shows error SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: const [
                ActionDescriptor(name: 'reboot', label: 'Reboot', iconName: 'refresh'),
              ],
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, _, __) async => const {'success': false, 'message': 'Timeout error'},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reboot'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Timeout error'), findsOneWidget);
    });

    testWidgets('Parameter dialog creates and disposes controllers on cancel',
        (WidgetTester tester) async {
      final invoked = <String, dynamic>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: const [
                ActionDescriptor(
                  name: 'compute',
                  label: 'Compute',
                  iconName: 'calculate',
                  parameters: [
                    ActionParameterDescriptor(
                      key: 'input',
                      label: 'Input',
                      type: 'string',
                      required: true,
                    ),
                  ],
                ),
              ],
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, name, params) async {
                invoked[name] = params;
                return const {'success': true, 'message': ''};
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Compute'));
      await tester.pumpAndSettle();

      expect(find.text('Compute Parameters'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Compute Parameters'), findsNothing);
      expect(invoked, isEmpty);
    });

    testWidgets('Parameter dialog invokes action with entered values',
        (WidgetTester tester) async {
      final invoked = <String, dynamic>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPanel(
              actions: const [
                ActionDescriptor(
                  name: 'compute',
                  label: 'Compute',
                  iconName: 'calculate',
                  parameters: [
                    ActionParameterDescriptor(
                      key: 'input',
                      label: 'Input',
                      type: 'string',
                      required: true,
                    ),
                  ],
                ),
              ],
              typeName: 'device',
              nodeId: 'node-1',
              onInvoke: (_, _, name, params) async {
                invoked[name] = params;
                return const {'success': true, 'message': 'Computed'};
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Compute'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test-input');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invoke'));
      await tester.pumpAndSettle();

      expect(invoked, containsPair('compute', {'input': 'test-input'}));
    });
  });
}
