---
title: "Implementation Profile — Flutter Platform (Desktop & Web)"
project: "Digital Systems Engineering Pipeline"
tier: implementation
platform: "flutter"
version: "1.0.0"
created: "2026-06-16"
created_time: "2026-06-16T09:52:35Z"
last_updated: "2026-06-17"
last_updated_time: "2026-06-17T01:00:00+08:00"
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
- **Dependency Injection (DI) & State Management:**
  - Standardize on `flutter_bloc` (BLoCs) for core business logic state management.
  - Standardize on `provider` (or `get_it`) strictly for Dependency Injection of repositories and service locators.
- **Allowed Adapters by Environment:**
  - **Local Development / Testing:**
    - `FirebaseEmulatorAdapter`: Connects to local Firebase Emulator Suite containing seeded test data via `firebase_core` / `cloud_firestore`.
    - `LocalServiceAdapter`: Connects to local OpenAPI / gRPC database gateway services running on `localhost`.
  - **Hosted Deployment / Staging / Production:**
    - `FirebaseHostedAdapter`: Connects to remote hosted production Firebase.
    - `GrpcAdapter`: Connects to hosted remote gRPC/gRPC-Web backend services.
    - `OpenApiAdapter`: Connects to hosted remote REST/OpenAPI JSON backend services.
- **Dependencies:**
  - Required: `firebase_core`, `cloud_firestore`, `firebase_auth`, `grpc`, `dio`, `get_it`, `provider`, `flutter_bloc`
  - DevDependencies: `flutter_test`, `integration_test`, `mocktail` or `mockito`, `build_runner`

## 2. Coding Standards & UI Patterns
- **Clean Architecture & Decoupling:** Persistence code must be isolated under `lib/core/persistence/`:
  - `lib/core/persistence/repository_interface.dart` (defines CRUD and domain-specific query interfaces)
  - `lib/core/persistence/adapters/` (contains concrete implementations: `firebase_emulator_adapter.dart`, `local_service_adapter.dart`, etc.)
  - `lib/core/domain/entities/` (defines platform-independent domain model models; adapters must parse dynamic JSON/SDK types and translate/map them into these entities before passing to BLoCs/Widgets)
- **Naming Conventions:**
  - UpperCamelCase for classes, mixins, extensions, and structs.
  - lowerCamelCase for variables, constants, parameters, and methods.
  - snake_case for directories and file names (Dart convention).
- **Type Strictness:** Enforce `analysis_options.yaml` (strict-casts, strict-inference, and strict-raw-types enabled). Use of `dynamic` is prohibited in application code. For Firebase (`DocumentSnapshot.data()`) and JSON decoding (`jsonDecode`) which yield dynamic data, developers MUST write typed parsing/mapping functions immediately at the adapter boundaries.
- **Off-Thread Telemetry Pipeline:**
  - WebSocket/gRPC streams and binary telemetry packet parsing MUST run in a background **Dart Isolate** to prevent blocking the main UI thread.
  - Implement a double-buffered atomic pointer swap protocol using 256-byte aligned allocations via Dart FFI for sharing coordinates between background isolates and the main UI thread.
- **UI & Design Aesthetics (Google Cloud Console / GKE Standards):**
  - **Visual Identity:** Interfaces must mimic the clean, high-density, professional look of the Google Cloud Console.
  - **Theme Selection:**
    - Must provide a user interface to select between **Light**, **Dark**, and **System** (OS/browser default) themes.
    - Configure dynamic `ThemeData` tokens at startup using primary, background, and status colors.
    - Prevent theme flashes during CanvasKit engine loading by maintaining a matching splash screen theme setup in native `index.html` (e.g. using a script to query `localStorage` and set `document.documentElement.className` before engine load).
  - **Color Palette & Alarm Severities:**
    - Google Blue (`#1a73e8`) for primary actions and active navigation states.
    - Implement the 5-color **ITU-T X.733 Alarm Severity** model for status displays and node highlight borders:
      - `Critical`: Red (`#d50000`)
      - `Major`: Orange (`#e65100`)
      - `Minor`: Yellow (`#fbc02d`)
      - `Warning`: Cyan/Blue (`#0288d1`)
      - `Cleared`: Green (`#2e7d32`)
  - **Layout & Structure:**
    - Left-hand collapsible sidebar navigation with GKE-style hierarchical nesting.
    - **HierarchyTree (Vertical Hierarchy Selector):** Left-side vertical tree selection panel. Must support:
      - Keyboard navigation (`ArrowUp`/`ArrowDown` focus shift, `ArrowRight` expand, `ArrowLeft` collapse).
      - Virtualized list row rendering.
      - Accessibility Semantics (wrap items in `Semantics` widget configuring tree-view roles).
    - **Split Workspace Layout (ResizableSplitter):** The main workspace area renders two primary panes.
      - **Paint Isolation:** Wrap child views inside the split panes in `RepaintBoundary` to isolate painting boundaries and ensure smooth 60fps+ resize performance.
      - **State Preservation:** Leverage `GlobalKey` state retention on child widgets to prevent widget state destruction when dragging the split bar.
      - **Top Pane (3D/4D Spatial-Temporal Canvas):** Displays an interactive `TopologyMap` representing the selected managed object's relations in 3D coordinate space. Must support dynamic trajectory path lines, orbital projections, volumetric bounding indicators, and a global timeline scrubber with playback controls. Integrate a 2nd-order Phase-Locked Loop (PLL) loop filter with anti-windup clamping to synchronize playheads between background Isolates and the UI thread.
      - **Bottom Pane (Details & Relations Pane):** Displays detailed attributes and related child objects grouped under a `TabbedContainer` holding tabbed `TableView`s (specifically Elements, Alarms, and Events).
    - **PropertyGrid Component:** Key-value attribute grid mapped to a schema. JSON-schemas are compiled *once* at initialization into a flat, typed layout descriptor list to avoid render-cycle parsing lag. Input fields validate on blur and maintain a local change-buffer to block global state re-renders on keystroke.
    - **NavigationBreadcrumbs:** Breadcrumbs at the content area top. Collapse middle segments into an ellipsis (`...`) if the total text width exceeds the available container width.
    - **Ubiquitous Navigation Links:** Whenever the UI presents a managed object or attribute, it must be rendered as a selectable, clickable link that directly navigates to that item.
    - High information-density tables with sortable, filterable columns, row selections, and status badges.
    - **Event-Echo Guard**: Property setters must modify selections silently without firing callback events to prevent infinite selection loops.
  - **Typography:** Use clean, professional system fonts or Roboto/Outfit.
  - **Interactivity:** Micro-animations for hover states, side-panel slide-outs, loading skeletons, and inline help tooltips.

## 3. Testing Mandates
- **TDD Requirement:** Strict RED-GREEN-REFACTOR cycle. Write a test before writing the code.
- **TDD Loop Speed:** Unit and widget/component tests must execute against isolated, thread-safe in-memory stubs (Mock Repositories) for fast, sub-second feedback.
- **Integration/E2E Test Instances:** All integration and E2E tests must execute against real, local database service instances (local emulators/containers) loaded with seeded test data. In-memory stubs are prohibited for these tiers.
- **E2E Testing:** Executed using the `integration_test` package running against the local emulators/containers during local runs, or targeting a staging/preview deployment URL connected to a staging database environment for hosted runs.
- **Test Code Statement Coverage Target:** Minimum 85% statement coverage on core business logic, state management (BLoCs), validation schemas, and calculation engines. Exclude simple repository wrappers from the generic 85% line-coverage gate (set to 20% smoke-test baseline) to avoid tautological testing.

## 4. Build & Operations
- **Lint Command:** `flutter analyze`
- **Local Dev / Dev Server Command:** `flutter run -d chrome` (web) or `flutter run -d macos` (desktop)
- **Local Emulator Command:** `firebase emulators:start --import=./.firebase_export`
- **Build Command:** `flutter build web --release --web-renderer canvaskit` or `flutter build macos --release`
- **CI/CD Integration:** Triggered on merge to default branch; builds and deploys to Firebase App Hosting, Web servers, or native desktop distribution pipelines. Dockerfiles must run as a non-root user.

## 5. Security & Credentials
- **Local Configurations:** API credentials and environment configurations are loaded at build time using `--dart-define-from-file` from a secure, local, git-ignored JSON configuration file. Default mock credentials are used for emulators. Raw command-line `--dart-define=KEY=VAL` arguments for sensitive credentials are prohibited to prevent leakage in process tables.
- **Hosted Configurations:** Production API credentials and URLs are compiled into the build using production `--dart-define-from-file` parameters compiled securely by the CI/CD environment. Keys must never be committed to git.
- **Secrets Scope & Boundaries:**
  - **ONLY public-facing keys** (such as Firebase client keys that have domain/IP origin restrictions configured on the provider console) are permitted to be compiled into client-side bundles.
  - **Administrative secrets** (such as database write passwords, service account private keys, or API private keys) must **never** be compiled into the frontend. They must be managed via a secure backend vault (like GCP Secret Manager) and accessed through secure backend endpoints with proper IAM controls.
- **CORS/CSP:** Web builds must configure appropriate CORS headers and Content Security Policies on their web host. HTTPS is mandatory for all network connections. Direct credentials must not be stored in repository files.
