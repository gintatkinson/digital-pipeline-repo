# Implementation Plan: Keyboard Enter-Flight Shortcut and Acceptance Tests

This plan details the steps to implement the Enter-Flight keyboard shortcut in the sidebar tree, add verification test assertions, build the production app, package it, run backlog reconciliation, commit and push the changes.

## 1. Proposed Changes

### Component: Sidebar Tree Focus KeyEvent Handling
* **Action**: Split the key event handling in the `Focus` widget inside `SidebarTree` so that the space key only selects the node, while the enter key both selects the node and triggers the camera flight.
* **Target File**: `app_flutter/lib/features/tree/sidebar_tree.dart`
* **Changes**:
```diff
-                  if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
-                    final currentId = viewModel.currentView;
-                    if (currentId != null) {
-                      viewModel.selectView(currentId);
-                    }
-                    return KeyEventResult.handled;
-                  }
+                  if (key == LogicalKeyboardKey.space) {
+                    final currentId = viewModel.currentView;
+                    if (currentId != null) {
+                      viewModel.selectView(currentId);
+                    }
+                    return KeyEventResult.handled;
+                  }
+                  if (key == LogicalKeyboardKey.enter) {
+                    final currentId = viewModel.currentView;
+                    if (currentId != null) {
+                      viewModel.selectView(currentId);
+                      viewModel.triggerFlight(currentId);
+                    }
+                    return KeyEventResult.handled;
+                  }
```

### Component: Integration / Acceptance Tests
* **Action**: Add a new test case to `double_click_fly_acceptance_test.dart` to simulate focusing the sidebar tree, navigating using arrow keys, and pressing `LogicalKeyboardKey.enter` to verify that both node selection and camera flight are successfully triggered.
* **Target File**: `app_flutter/test/topology/double_click_fly_acceptance_test.dart`
* **Changes**: Add the following test case inside the main `group`:
```dart
    testWidgets(
      'Key event with LogicalKeyboardKey.enter simulated on sidebar tree focus node triggers selection and camera flight',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.runAsync(() async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<DataSource>.value(value: fakeDataSource),
                ChangeNotifierProvider<ThemeController>.value(
                  value: ThemeController(FakeThemeService()),
                ),
              ],
              child: MaterialApp(
                home: Scaffold(
                  body: Layout(
                    activeView: 'NodeA',
                    layoutConfig: testLayoutConfig,
                  ),
                ),
              ),
            ),
          );
          await settle(tester);

          // Verify initial state
          final CameraController controller = findCameraController(tester);
          expect(controller.current.latitude, 35.6);
          expect(controller.current.longitude, 139.7);
          expect(controller.isFlying, isFalse);

          // Focus the tree's focusNode by tapping the sidebar node A
          final nodeAFinder = find.byKey(const Key('node_NodeA'));
          expect(nodeAFinder, findsOneWidget);
          await tester.tap(nodeAFinder);
          await settle(tester);

          // Verify selection is still Node A
          final treeViewModel = tester.element(find.byType(TopographicalView)).read<TreeViewModel>();
          expect(treeViewModel.currentView, 'NodeA');

          // Press ArrowDown to change focused/selected view to NodeB
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await settle(tester);
          expect(treeViewModel.currentView, 'NodeB');
          expect(controller.isFlying, isFalse);

          // Press Enter key to trigger flight
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await settle(tester);

          // Verify that camera flight starts
          expect(controller.isFlying, isTrue, reason: 'Enter key should trigger flight');

          await tester.pump(const Duration(milliseconds: 100));
          expect(controller.current.latitude, greaterThan(35.6));
          expect(controller.current.longitude, isNot(139.7));

          await tester.pumpAndSettle();
          expect(controller.isFlying, isFalse);
          expect(controller.current.latitude, 40.7);
          expect(controller.current.longitude, -74.0);
        });
      },
    );
```

---

## 2. Execution & Verification Steps

### Step 1: Apply Code Changes
* Modify `app_flutter/lib/features/tree/sidebar_tree.dart`.
* Modify `app_flutter/test/topology/double_click_fly_acceptance_test.dart`.

### Step 2: Run Unit and Integration Tests
Run `flutter test` inside the `app_flutter` directory to verify tests pass successfully (Green Phase).

### Step 3: Build macOS Production Release
Run the command inside `app_flutter` directory:
```bash
flutter build macos --release
```

### Step 4: Package App
Run the zip command in `app_flutter/build/macos/Build/Products/Release/`:
```bash
zip -r -y ../../../../../app_flutter_release.zip app_flutter.app
```

### Step 5: Stage and Commit Changes
Run git commands:
```bash
git add app_flutter/lib/features/tree/sidebar_tree.dart app_flutter/test/topology/double_click_fly_acceptance_test.dart
git commit -m "feat: implement enter-flight keyboard shortcut and verify with acceptance test"
```

### Step 6: Backlog Reconciliation
Run backlog reconciliation script:
```bash
python3 skills/spec-orchestrator/scripts/reconcile_backlog.py
```

### Step 7: Push and Launch
* Push changes:
```bash
git push origin feat/58-63-linter-fixes
```
* Launch the updated app:
```bash
open app_flutter/build/macos/Build/Products/Release/app_flutter.app
```
