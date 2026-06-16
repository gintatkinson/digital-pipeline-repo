---
title: "Implementation Profile — Flutter Platform (Desktop & Web)"
project: "Digital Systems Engineering Pipeline"
tier: implementation
platform: "flutter"
created: "2026-06-16"
last_updated: "2026-06-16"
---

# Implementation Profile: Flutter Platform (Desktop & Web)

> This document governs feature implementation and builds for both local and hosted Flutter Desktop/Web environments.
> Read alongside `.pipeline/constitution.md` (functional layer).

## 1. Platform & Stack
- **Framework & Version:** Flutter SDK 3.x (Dart 3.x)
- **Target Environments:** Desktop (macOS, Windows, Linux) and Web (HTML5/CanvasKit renderer)
- **Persistence Architecture:** Modular Repository/Adapter pattern.
  - Direct database/API SDK imports are forbidden in UI widgets.
  - Widgets must depend only on abstract Repository interfaces.
  - Active adapter is injected at application bootstrap based on environment configuration.
- **Allowed Adapters by Environment:**
  - **Local Development / Testing:**
    - `FirebaseEmulatorAdapter`: Connects to local Firebase Emulator Suite containing seeded test data via `firebase_core` / `cloud_firestore`.
    - `LocalServiceAdapter`: Connects to local OpenAPI / gRPC database gateway services running on `localhost`.
  - **Hosted Deployment / Staging / Production:**
    - `FirebaseHostedAdapter`: Connects to remote hosted production Firebase.
    - `GrpcAdapter`: Connects to hosted remote gRPC/gRPC-Web backend services.
    - `OpenApiAdapter`: Connects to hosted remote REST/OpenAPI JSON backend services.
- **Dependencies:**
  - Required: `firebase_core`, `cloud_firestore`, `firebase_auth`, `grpc` (gRPC Dart), `dio` or `http` (for REST), `get_it` or `provider` (for DI)
  - DevDependencies: `flutter_test`, `integration_test`, `mocktail` or `mockito`, `build_runner` (for code-generation)

## 2. Coding Standards & UI Patterns
- **Clean Architecture & Decoupling:** Persistence code must be isolated under `lib/core/persistence/`:
  - `lib/core/persistence/repository_interface.dart` (defines CRUD and domain-specific query interfaces)
  - `lib/core/persistence/adapters/` (contains concrete implementations: `firebase_emulator_adapter.dart`, `local_service_adapter.dart`, etc.)
- **Naming Conventions:**
  - UpperCamelCase for classes, mixins, extensions, and structs.
  - lowerCamelCase for variables, constants, parameters, and methods.
  - snake_case for directories and file names (Dart convention).
- **Type Strictness:** Enforce `analysis_options.yaml` with strict-casts, strict-inference, and strict-raw-types enabled. Use of `dynamic` is prohibited unless explicitly justified.
- **UI & Design Aesthetics (Google Cloud Console / GKE Standards):**
  - **Visual Identity:** Interfaces must mimic the clean, high-density, professional look of the Google Cloud Console.
  - **Theme Selection:**
    - Must provide a user interface to select between **Light**, **Dark**, and **System** themes, utilizing Flutter's native `ThemeMode` and custom `ThemeData` tokens.
    - Prevent theme flashes on startup by initializing state prior to executing `runApp()`.
  - **Color Palette:** Curated neutral greys, clean white/dark backgrounds, with specific accent colors:
    - Google Blue (`Color(0xFF1A73E8)`) for primary actions, selection states, and navigation highlights.
    - Soft red, yellow, and green status chips for resource health indicators (mimicking GKE cluster health states).
  - **Layout & Structure:**
    - Left-hand collapsible sidebar navigation using a styled `NavigationRail` or custom widget.
    - **Vertical Hierarchy Selector:** A dedicated left-side vertical tree selection panel for managed objects (e.g. using a tree-view package or custom expansion widget), allowing the user to select and drill down through hierarchical parent-child relationships (Folder > Project > Resource) just like the Google Cloud resource hierarchy selector.
    - **Split Workspace Layout:** For each selected managed object, the main workspace area must render two primary panes separated by a slider adjuster (split bar).
      - By default, the panes are stacked vertically (horizontal split). Dragging the slide adjuster vertically must dynamically modify each pane's proportional vertical size.
      - **Reconfigurability:** The positions and orientation of the two primary panes must be reconfigurable by the user (e.g., allowing the user to swap top/bottom positions or switch the layout axis to a vertical split/side-by-side view).
      - **Topographical View Pane (Top/Default Pane):** Displays an interactive topographical map representing the selected managed object's topological relations with other managed objects.
        - Must support **relationship filtering** (filtering which types of relations are displayed).
        - Must support **depth constraints** (e.g. a hop-count selector to limit the degrees of separation shown in the topology).
      - **Details & Relations Pane (Bottom/Default Pane):** Shows all detailed attributes of the selected managed object.
        - Must display lists of contained or related managed objects, with direct navigation shortcuts to select/inspect them.
    - **Ubiquitous Navigation Links:** Whenever the user interface presents a managed object or attribute (e.g., inside tables, lists, text labels, or nodes in the topographical map), it must be rendered as a selectable, clickable link (using styled `InkWell` or `TextButton`) that directly navigates to that item's detail view, configuration window, or focus context.
    - Breadcrumbs at the top of the content area for deep-level navigation tracking.
    - High information-density tables with sortable, filterable columns, row selections, and status badges.
  - **Typography:** Use clean, professional system fonts or Outfit/Roboto.
  - **Interactivity:** Micro-animations for hover states, side-panel slide-outs, loading skeletons, and inline help tooltips.

## 3. Testing Mandates
- **TDD Requirement:** Strict RED-GREEN-REFACTOR cycle. Write a test before writing the code.
- **TDD Loop Speed:** Unit and widget/component tests must execute against isolated, thread-safe in-memory stubs (Mock Repositories) for fast, sub-second feedback.
- **Integration/E2E Test Instances:** All integration and E2E tests must execute against real, local database service instances (local emulators/containers) loaded with seeded test data. In-memory stubs are prohibited for these tiers.
- **E2E Testing:** Executed using the `integration_test` package running against the local emulators/containers during local runs, or targeting a staging/preview deployment URL connected to a staging database environment for hosted runs.
- **Coverage Target:** Minimum 85% statement coverage on core business logic, state management (BLoCs/ChangeNotifiers), validation schemas, and calculation engines. Exclude simple repository wrappers from the generic 85% line-coverage gate (set to 20% smoke-test baseline) to avoid tautological testing.

## 4. Build & Operations
- **Lint Command:** `flutter analyze`
- **Local Dev / Dev Server Command:** `flutter run -d chrome` (web) or `flutter run -d macos` (desktop)
- **Local Emulator Command:** `firebase emulators:start --import=./.firebase_export`
- **Build Command:** `flutter build web --release --web-renderer canvaskit` or `flutter build macos --release`
- **CI/CD Integration:** Triggered on merge to default branch; builds and deploys to Firebase App Hosting, Web servers, or native desktop distribution pipelines.

## 5. Security & Credentials
- **Local Configurations:** API credentials and environment configurations are loaded at build time using `--dart-define` or `--dart-define-from-file` from a git-ignored file. Default mock credentials are used for emulators.
- **Hosted Configurations:** Production API credentials and URLs are compiled into the build using production `--dart-define` parameters managed securely by the CI/CD environment. Keys must never be committed to git.
- **CORS/CSP:** Web builds must configure appropriate CORS headers and Content Security Policies on their web host. HTTPS is mandatory for all network connections. Direct credentials must not be stored in repository files.
