---
title: "Implementation Profile — Flutter Platform (Desktop & Web)"
project: "Digital Systems Engineering Pipeline"
tier: implementation
platform: "flutter"
version: "1.0.0"
created: "2026-06-16"
created_time: "2026-06-16T09:52:35Z"
last_updated: "2026-06-20"
last_updated_time: "2026-06-20T13:13:00+08:00"
---

# Implementation Profile: Flutter Platform (Desktop & Web)

> This document governs feature implementation and builds for both local and hosted Flutter Desktop/Web environments.
> Read alongside `.pipeline/constitution.md` (functional layer).

## 1. Platform & Stack
- **Framework & Version:** Flutter SDK (as resolved from environment configuration)
- **Target Environments:** Desktop (macOS, Windows, Linux) and Web (HTML5/CanvasKit renderer)
- **Persistence Architecture:** Modular Repository/Adapter pattern.
  - Direct database/API SDK imports (such as `cloud_firestore`) are forbidden in UI widgets.
  - Widgets must depend only on abstract Repository interfaces.
  - Active adapter is resolved and injected dynamically at application bootstrap based on environment variables or runtime configurations (`config.json`).
  - For the Firebase profile, the abstract repository resolves dynamically to the concrete `FirestoreRepositoryAdapter` in Flutter.
- **Allowed Adapters:**
  - Transport and database adapters must register themselves dynamically at application bootstrap. The platform profile does not restrict the allowed adapter types; any class implementing the target Repository interface is permitted, enabling dynamic runtime resolution of any protocol or database client (e.g. REST, gRPC, WebSocket, GraphQL, or local storage).
- **Dependency Injection (DI) & State Management:**
  - Standardize on dynamic state management models (such as BLoCs) for core business logic.
  - Explicitly restrict coupling UI views directly to state provider packages, enforcing abstract constructor parameters or dynamic service locators instead to avoid direct widget-tree coupling to specific third-party provider libraries.
- **Environment Selection Keys:**
  - Resolved dynamically from the platform configuration metadata (e.g., config keys specifying the active persistence adapter injected at bootstrap).
- **Dependencies:**
  - Required: Resolved dynamically from the platform configuration file (e.g., libraries parsed from the package dependencies config block).
  - DevDependencies: Resolved dynamically from the platform configuration file.

## 2. Coding Standards & UI Patterns
- **Clean Architecture & Decoupling:** Persistence code must be isolated under the designated persistence directory resolved from configuration:
  - Repository interfaces defining CRUD and domain-specific query interfaces.
  - Concrete adapter implementations resolved at runtime.
  - Platform-independent domain models (adapters must parse dynamic JSON/SDK types and translate/map them into these entities before passing to logic/widgets).
- **Naming Conventions:**
  - UpperCamelCase for classes, mixins, extensions, and structs.
  - lowerCamelCase for variables, constants, parameters, and methods.
  - snake_case for directories and file names (Dart convention).
- **Type Strictness:** Enforce `analysis_options.yaml` (strict-casts, strict-inference, and strict-raw-types enabled). Use of `dynamic` is prohibited in application code. Developers MUST write typed parsing/mapping functions immediately at the adapter boundaries.
- **Off-Thread Processing:**
  - To prevent main-thread UI starvation during high-frequency data streaming or heavy parsing, all intensive computation and data deserialization MUST execute off the main thread inside a background execution context (such as background Dart Isolates or Web Workers).
  - Pass normalized domain structures to the main thread via asynchronous message passing.
- **Resource Management:**
  - Explicitly manage runtime memory lifecycles for hardware-accelerated viewports or large buffers, releasing memory in component cleanup hooks to prevent leaks.
  - Pre-allocate and reuse memory blocks where possible to avoid continuous runtime memory allocation.
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
    - **Hierarchy Navigation Widget:** (e.g. hierarchy tree or navigation slot resolved from configuration). Exposes a primary navigation slot. Must support:
      - Mapping physical inputs to logical action bindings (such as `NAVIGATE_NEXT`, `NAVIGATE_PREVIOUS`, `EXPAND_NODE`, `COLLAPSE_NODE`) dynamically.
      - Virtualized list row rendering.
      - Accessibility Semantics (wrap items in widgets configuring logical tree-view roles).
    - **Resizable Splitter Widget:** The main workspace area renders pane slots dynamically populated with child widgets resolved from the configuration.
      - **Paint Isolation & Caching Bypass:** Wrap child views inside the split panes in repaint boundaries to isolate painting boundaries and ensure smooth resizing. Caching on `RepaintBoundary` must be temporarily disabled or bypassed during active resizing drag gestures to prevent frame-by-frame texture invalidations on the GPU (GPU layer thrashing).
      - **State Preservation:** Leverage state retention on child widgets to prevent widget state destruction when resizing split panes.
      - Child widgets resolved from layout schemas (such as viewports, attribute grids, or lists) are dynamically rendered inside the Split Workspace containers.
    - **Property Grid Widget:** Key-value attribute grid mapped to a schema. Validation schemas are compiled *once* at initialization into a flat, typed layout descriptor list to avoid render-cycle parsing lag. Input fields validate upon focus loss or edit completion and maintain a local change-buffer to block global state re-renders on keystroke.
    - **Navigation Breadcrumbs Widget:** Breadcrumbs at the content area top. Collapse middle segments into an ellipsis (`...`) if the total text width exceeds the available container width.
    - **Ubiquitous Navigation Links:** Whenever the UI presents a managed object or attribute, it must be rendered as a selectable, clickable link that directly navigates to that item.
    - **Density Table Component:** High information-density tables with sortable, filterable columns, row selections, and status badges. Table row sizing must use `min-height: 32px` and compact vertical cell padding of `4px` top/bottom to maximize information density while remaining scale-safe.
    - **Event-Echo Guard**: Property setters must modify selections silently without firing callback events to prevent infinite selection loops.
  - **Typography:** Resolved dynamically from the typography design tokens (Roboto, Inter, sans-serif, base text size constrained at `12px`–`13px`, section headings at `13px`–`14px`, page title at `18px` max).
  - **Icons & Vector Graphics:** SVG icons must be outline-only, constrained within a fixed `16px` viewport boundary with a stroke weight of `1.0px`–`1.2px` and a bounding padding of `2px`.
  - **Interactivity:** Micro-animations for hover states, side-panel slide-outs, loading skeletons, and inline help tooltips.
  - **Self-Documenting Code & Documentation Mandates:**
    - **Intention-Revealing Names:** Enforce intention-revealing naming conventions for all variables, properties, methods, classes, and widgets.
    - **Dart Doc Comments:** Require standard Dart Doc (`///`) annotations for all public widgets, classes, methods, and properties (covering purpose, parameters, return values, and exceptions).
    - **UML Traceability:** Enforce UML traceability metadata comment tags (e.g. `@realizes UML::ClassName::operationName`) to link code directly to specification diagrams.
    - **Inline Complexity Comments:** Require detailed inline complexity comments explaining the *why* for non-trivial logic (such as asynchronous isolate messaging or custom painter layouts).
    - **No Placeholders or Dead Code:** Prohibit dead code, commented-out blocks, placeholders, or undocumented stubs in production files.

## 3. Testing Mandates
- **TDD Requirement:** Strict RED-GREEN-REFACTOR cycle. Write a test before writing the code.
- **TDD Loop Speed:** Unit and widget/component tests must execute against isolated, thread-safe in-memory stubs (Mock Repositories) for fast, sub-second feedback.
- **Integration/E2E Test Instances:** All integration and E2E tests must execute against real, local database service instances (local emulators/containers) loaded with seeded test data. In-memory stubs are prohibited for these tiers.
- **E2E Testing:** E2E tests running against the local dev environment/containers during local runs, or targeting a staging/preview deployment URL connected to a staging environment for hosted runs.
- **Test Code Statement Coverage Target:** Minimum statement coverage targets on core business logic, state management, validation schemas, and calculation engines, excluding simple repository wrappers from the generic line-coverage gate, as defined in configuration.

## 4. Build & Operations
- **Lint Command:** Command resolved from environment configurations (e.g. `flutter analyze`)
- **Local Dev / Dev Server Command:** Command resolved from environment configurations (e.g. `flutter run`)
- **Local Emulator Command:** Command resolved from environment configurations (e.g. `npx firebase emulators:start --only firestore`)
- **Build Command:** Command resolved from environment configurations (e.g. `flutter build`)
- **CI/CD Integration:** Triggered on merge to default branch; builds and deploys to App Hosting, Web servers, or native desktop distribution pipelines. Dockerfiles must run as a non-root user.

## 5. Security & Credentials
- **Local Configurations:** API credentials and environment configurations are loaded at build time using `--dart-define-from-file` from a secure, local, git-ignored JSON configuration file. Default mock credentials are used for emulators. Raw command-line `--dart-define=KEY=VAL` arguments for sensitive credentials are prohibited to prevent leakage in process tables.
- **Hosted Configurations:** Production API credentials and URLs are compiled into the build using production `--dart-define-from-file` parameters compiled securely by the CI/CD environment. Keys must never be committed to git.
- **Secrets Scope & Boundaries:**
  - **ONLY public-facing keys** (such as Firebase client keys that have domain/IP origin restrictions configured on the provider console) are permitted to be compiled into client-side bundles.
  - **Administrative secrets** (such as database write passwords, service account private keys, or API private keys) must **never** be compiled into the frontend. They must be managed via a secure backend vault (like GCP Secret Manager) and accessed through secure backend endpoints with proper IAM controls.
- **CORS/CSP:** Web builds must configure appropriate CORS headers and Content Security Policies on their web host. HTTPS is mandatory for all network connections. Direct credentials must not be stored in repository files.
