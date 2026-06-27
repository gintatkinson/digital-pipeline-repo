# Implementation Plan - Issue #69 Design Tokens Integration

This plan details copying, registering, parsing, and resolving the design tokens from logical-ui to the app_flutter codebase, replacing all hardcoded color references.

## Proposed Changes

### 1. Copy `design-tokens.json`
- Copy `.pipeline/logical-ui/design-tokens.json` to `app_flutter/assets/design-tokens.json`.

### 2. Update `app_flutter/pubspec.yaml`
- Register `assets/design-tokens.json` under the `assets:` section.

### 3. Create `app_flutter/lib/domain/design_tokens.dart`
- Implement `DesignTokenRegistry` interface and a concrete implementation class.
- Support recursive alias syntax parsing (e.g. `{global.color.blue-500}`).
- Support theme-dependent values (`light` and `dark`).
- Support parsing dimensions (e.g., "16px" -> 16.0) and colors (e.g., "#1a73e8" -> 0xFF1A73E8).

### 4. Update `app_flutter/lib/main.dart`
- Load `design-tokens.json` asynchronously on startup inside `main()`.
- Initialize `DesignTokenRegistry` with the loaded JSON.
- Provide the registry to the widget tree using an InheritedWidget or similar state provider.
- Dynamically resolve ThemeData using the design tokens.
- Replace all hardcoded colors with registry-resolved values.

### 5. Update `app_flutter/lib/components/layout.dart`
- Retrieve `DesignTokenRegistry` from context.
- Update layout sizing (sidebar width, splitter min size) and all hardcoded color values to be resolved dynamically.

### 6. Update `app_flutter/lib/components/breadcrumbs.dart`
- Retrieve `DesignTokenRegistry` from context.
- Resolve breadcrumb colors dynamically.

### 7. Update `app_flutter/lib/components/property_grid.dart`
- Retrieve `DesignTokenRegistry` from context.
- Resolve property grid colors dynamically.

## Verification Plan

### Automated Verification Steps
1. Run `flutter analyze` inside `app_flutter/` to verify zero static analysis warnings.
2. Run `flutter test` inside `app_flutter/` to verify all tests pass.
3. Verify remote push and branch synchronization.
