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
  - Active adapter is resolved and injected dynamically at application bootstrap based on environment variables or runtime configurations.
- **Dependency Injection (DI) & State Management:**
  - Standardize on dynamic state management models (such as BLoCs) for core business logic.
  - Resolve dependencies/repositories via an abstract service locator or pure constructor injection in widgets, avoiding direct widget-tree coupling to specific third-party provider libraries.
- **Environment Selection Keys:**
  - `PERSISTENCE_ADAPTER`: Configures which concrete adapter is injected at bootstrap (e.g., emulator-based, RPC-based, REST-based).
- **Dependencies:**
  - Required: `dio`, `typescript_equivalent_dart_packages` (standard packages listed in configuration).
  - DevDependencies: `flutter_test`, `integration_test`, `mocktail` or `mockito`, `build_runner`

## 2. Coding Standards & UI Patterns
- **Clean Architecture & Decoupling:** Persistence code must be isolated under `lib/core/persistence/`:
  - `lib/core/persistence/repository_interface.dart` (defines CRUD and domain-specific query interfaces)
  - `lib/core/persistence/adapters/` (contains concrete implementations resolved at runtime)
  - `lib/core/domain/entities/` (defines platform-independent domain models; adapters must parse dynamic JSON/SDK types and translate/map them into these entities before passing to logic/widgets)
- **Naming Conventions:**
  - UpperCamelCase for classes, mixins, extensions, and structs.
  - lowerCamelCase for variables, constants, parameters, and methods.
  - snake_case for directories and file names (Dart convention).
- **Type Strictness:** Enforce `analysis_options.yaml` (strict-casts, strict-inference, and strict-raw-types enabled). Use of `dynamic` is prohibited in application code. Developers MUST write typed parsing/mapping functions immediately at the adapter boundaries.
- **Off-Thread Telemetry Pipeline:**
  - Stream connections and binary telemetry packet parsing MUST run in a background execution context (such as a background Dart Isolate) to prevent blocking the main UI thread.
  - Pass decoded, normalized domain structures to the main thread via asynchronous message passing or memory buffers.
- **Off-Thread FFI Memory Safety & Hardware Alignment:**
  - **Memory Safety**: Direct off-thread C-heap allocations shared with the UI thread must be managed using a `NativeFinalizer` to ensure that native buffers are properly released when their Dart wrappers are garbage collected.
  - **Memory Alignment**: All shared memory coordinate pointer allocations MUST be aligned to 256-byte boundaries (using standard alignment allocators such as `posix_memalign` on POSIX or `_aligned_malloc` on Windows) to prevent GPU driver validation crashes in native rendering pipelines (such as Impeller's Metal/Vulkan backends).
  - **Double-Buffering & Mutexes**: Coordinate buffers must use double-buffering and explicit synchronization fences (mutexes/atomic flags) to prevent data tearing between background writers and UI render cycles.
- **UI & Design Aesthetics (Professional High-Density Console Standards):**
  - **Visual Identity:** Interfaces must mimic a clean, high-density, professional management console.
  - **Theme Selection:**
    - Must provide a user interface to select from the dynamic list of theme modes defined in the runtime configuration (Tier 2).
    - Configure dynamic `ThemeData` tokens at startup using primary, background, and status colors.
    - Prevent theme flashes during initialization by maintaining a matching splash screen theme setup in native platforms (checking configuration settings prior to the initial frame load).
  - **Dynamic Theme & Alarm Mappings:**
    - Hardcoding colors, brand palettes, or standard-specific severity strings is strictly prohibited.
    - All status colors, brand palettes, and spacing attributes must map back to variables loaded dynamically from the design tokens configuration resolved at runtime.
    - The application must resolve the design tokens at startup and serve them dynamically by subclassing Flutter's native `ThemeExtension` for status colors lookup at runtime.
    - Component layouts and widgets must be mapped dynamically via a Widget registry that resolves types and schemas from the runtime configuration.
  - **Layout & Structure:**
    - Navigation architecture aligned with hierarchical layout slot containers.
    - **HierarchyTree:** Exposes a primary navigation slot. Must support:
      - Mapping physical inputs to logical action bindings (such as `NAVIGATE_NEXT`, `NAVIGATE_PREVIOUS`, `EXPAND_NODE`, `COLLAPSE_NODE`) dynamically.
      - Virtualized list row rendering.
      - Accessibility Semantics (wrap items in widgets configuring logical tree-view roles).
    - **ResizableSplitter:** The main workspace area renders pane slots dynamically populated with child widgets resolved from the configuration.
      - **Paint Isolation:** Wrap child views inside the split panes in repaint boundaries to isolate painting boundaries and ensure smooth resizing.
      - **State Preservation:** Leverage state retention on child widgets to prevent widget state destruction when resizing split panes.
      - Child widgets resolved from layout schemas (such as the topology map, tabbed views, or details tables) are dynamically rendered inside the Split Workspace containers.
    - **PropertyGrid:** Key-value attribute grid mapped to a schema. JSON-schemas are compiled *once* at initialization into a flat, typed layout descriptor list to avoid render-cycle parsing lag. Input fields validate upon focus loss or edit completion and maintain a local change-buffer to block global state re-renders on keystroke.
    - **NavigationBreadcrumbs:** Breadcrumbs at the content area top. Collapse middle segments into an ellipsis (`...`) if the total text width exceeds the available container width.
    - **Ubiquitous Navigation Links:** Whenever the UI presents a managed object or attribute, it must be rendered as a selectable, clickable link that directly navigates to that item.
    - High information-density tables with sortable, filterable columns, row selections, and status badges.
    - **Event-Echo Guard**: Property setters must modify selections silently without firing callback events to prevent infinite selection loops.
  - **Typography:** Resolved dynamically from the typography design tokens.
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
- **CI/CD Integration:** Triggered on merge to default branch; builds and deploys to App Hosting, Web servers, or native desktop distribution pipelines. Dockerfiles must run as a non-root user.

## 5. Security & Credentials
- **Local Configurations:** API credentials and environment configurations are loaded at build time using `--dart-define-from-file` from a secure, local, git-ignored JSON configuration file. Default mock credentials are used for emulators. Raw command-line `--dart-define=KEY=VAL` arguments for sensitive credentials are prohibited to prevent leakage in process tables.
- **Hosted Configurations:** Production API credentials and URLs are compiled into the build using production `--dart-define-from-file` parameters compiled securely by the CI/CD environment. Keys must never be committed to git.
- **Secrets Scope & Boundaries:**
  - **ONLY public-facing keys** (such as Firebase client keys that have domain/IP origin restrictions configured on the provider console) are permitted to be compiled into client-side bundles.
  - **Administrative secrets** (such as database write passwords, service account private keys, or API private keys) must **never** be compiled into the frontend. They must be managed via a secure backend vault (like GCP Secret Manager) and accessed through secure backend endpoints with proper IAM controls.
- **CORS/CSP:** Web builds must configure appropriate CORS headers and Content Security Policies on their web host. HTTPS is mandatory for all network connections. Direct credentials must not be stored in repository files.
