---
title: "Implementation Profile — React Platform"
project: "Digital Systems Engineering Pipeline"
tier: implementation
platform: "react"
version: "1.0.0"
created: "2026-06-16"
created_time: "2026-06-16T09:40:52Z"
last_updated: "2026-06-17"
last_updated_time: "2026-06-17T01:00:00+08:00"
---

# Implementation Profile: React Platform

> This document governs feature implementation and builds for both local and hosted React environments.
> Read alongside `.pipeline/constitution.md` (functional layer).

## 1. Platform & Stack
- **Framework & Version:** React 18, Vite
- **Language & Version:** TypeScript 5.x (strict mode)
- **Persistence Architecture:** Modular Repository/Adapter pattern.
  - Direct database/API SDK imports are forbidden in React components.
  - Components must depend only on abstract Repository interfaces.
  - Active adapter is injected at application bootstrap based on environment variables.
- **Dependency Injection (DI):** Standardize on React Context Hooks for dependency resolution at the application root.
- **Allowed Adapters by Environment:**
  - **Local Development / Testing:**
    - `FirebaseEmulatorAdapter`: Connects to local Firebase Emulator Suite containing seeded test data.
    - `LocalServiceAdapter`: Connects to local OpenAPI / gRPC database gateway services running on `localhost`.
  - **Hosted Deployment / Staging / Production:**
    - `FirebaseHostedAdapter`: Connects to remote hosted production Firebase.
    - `GrpcAdapter`: Connects to hosted remote gRPC/gRPC-Web backend services.
    - `OpenApiAdapter`: Connects to hosted remote REST/OpenAPI JSON backend services.
- **Environment Selection Keys:**
  - Resolved dynamically from the platform configuration metadata (e.g., config keys specifying the active persistence adapter injected at bootstrap).
- **Dependencies:**
  - Required: `firebase`, `grpc-web`, `@protobuf-ts/grpcweb-transport`, `axios`, `typescript`, `react`, `react-dom`, `@react-three/fiber`, `three`
  - DevDependencies: `firebase-tools`, `vite`, `jest`, `@testing-library/react`, `playwright`

## 2. Coding Standards & UI Patterns
- **Clean Architecture & Decoupling:** Persistence code must be isolated under the designated persistence directory resolved from configuration (e.g., target UI layout configurations):
  - Repository interfaces defining CRUD and domain-specific query interfaces.
  - Concrete adapter implementations.
  - Mock implementations for fast unit testing stubs.
- **Naming Conventions:**
  - PascalCase for React components and class-based Adapters.
  - camelCase for interface declarations and instances.
  - kebab-case for folders and file names.
- **Type Strictness:** Strict null checks enabled; use of `any` is strictly prohibited. Every database model must map to a TypeScript interface.
- **Off-Thread Telemetry Pipeline:**
  - To prevent main-thread UI starvation during high-frequency data streaming, all stream connections, binary packet decoding, and telemetry JSON deserialization MUST execute off-thread inside a background execution context (such as a worker thread or native background context).
  - Pass decoded, normalized domain structures to the main thread via asynchronous message passing or memory buffers.
- **UI & Design Aesthetics (Professional High-Density Console Standards):**
  - **Visual Identity:** Interfaces must mimic a clean, high-density, professional management console.
  - **Theme Selection:**
    - Must provide a user interface to select from the dynamic list of theme modes defined in the runtime configuration (Tier 2).
    - The application must map styling parameters dynamically to color tokens matching the active design token namespaces resolved from the loaded configuration to allow dynamic, reload-free theme switching.
    - The theme preference must be loaded dynamically. The application must defer initial rendering until dynamic theme parameters are fully resolved to prevent visual flashes (FOUC).
  - **Dynamic Design Tokens & Alarm Mappings:**
    - Hardcoding visual parameters (e.g., hex colors, margins) or standard-specific mappings (e.g., specific alarm severities or colors) is strictly forbidden.
    - All status colors, brand palettes, and component styles must be loaded dynamically from the active design tokens configuration resolved at runtime.
    - At startup, the application loader must dynamically resolve and apply styling tokens parsed from the configuration while deferring rendering until resolution is complete to prevent flashes.
    - Status visualizations, node borders, and alarm indicators must resolve their colors and severity levels dynamically via a metadata-driven UI registry loaded at runtime.
  - **Layout & Structure:**
    - Navigation architecture aligned with hierarchical layout slot containers.
    - **Hierarchy Navigation Component:** (e.g. hierarchy tree or navigation slot resolved from configuration). Exposes a primary navigation slot. Must support:
      - Mapping physical inputs to logical action bindings (such as `NAVIGATE_NEXT`, `NAVIGATE_PREVIOUS`, `EXPAND_NODE`, `COLLAPSE_NODE`) dynamically.
      - Virtualized list row rendering.
      - Dynamic accessibility semantic injection.
    - **Resizable Splitter Component:** The main workspace area renders pane slots dynamically populated with child components resolved from the runtime layout configuration registry.
      - Default layout: stacked along a configurable split axis. The user can toggle split directions.
      - **Performance Optimization:** Dragging the splitter must update layout variables directly in the configuration and leverage rendering/paint boundaries.
      - **Snap-to-Edge:** Support snap-to-edge collapse when dragged within the configured threshold boundaries.
      - Child components resolved from the layout configuration (such as the topology map, tabbed views, or details tables) are dynamically rendered inside the workspace containers.
    - **Property Grid Component:** Key-value attribute grid mapped to a schema. JSON-schemas are compiled *once* at initialization into a flat, typed layout descriptor list to avoid render-cycle parsing lag. Input fields validate upon focus loss or edit completion and maintain a local change-buffer to block global state re-renders on keystroke.
    - **Navigation Breadcrumbs Component:** Exposes a breadcrumb path resolved from the current selection. Collapses middle segments dynamically when the path length exceeds available container space.
    - **Ubiquitous Navigation Links:** Whenever the UI presents a managed object or attribute, it must be rendered as a selectable, clickable link that directly navigates to that item.
    - **Density Table Component:** High information-density tables with sortable, filterable columns, row selections, and status badges.
  - **Typography:** Resolved dynamically from the typography design tokens.
  - **Interactivity:** Micro-animations for hover states, side-panel slide-outs, loading skeletons, and inline help tooltips.

## 3. Testing Mandates
- **TDD Requirement:** Strict RED-GREEN-REFACTOR cycle. Write a test before writing the code.
- **TDD Loop Speed:** Unit and widget/component tests must execute against isolated, thread-safe in-memory stubs (Mock Repositories) for fast, sub-second feedback.
- **Integration/E2E Test Instances:** All integration and E2E tests must execute against real, local database service instances (local emulators/containers) loaded with seeded test data. In-memory stubs are prohibited for these tiers.
- **E2E Testing:** Playwright E2E tests running against the Vite local dev server and the Local Firebase Emulator Suite (Firestore, Auth) or local API containers during local runs, or targeting a staging/preview deployment URL connected to a staging database environment for hosted runs.
- **Test Code Statement Coverage Target:** Minimum 85% statement coverage on core business logic, validation schemas, and calculation engines. Exclude simple repository wrappers from the generic 85% line-coverage gate (set to 20% smoke-test baseline) to avoid tautological testing.

## 4. Build & Operations
- **Lint Command:** `npm run lint` / `npx tsc --noEmit`
- **Local Dev / Dev Server Command:** `npm run dev`
- **Local Emulator Command:** `firebase emulators:start --import=./.firebase_export`
- **Build Command:** `npm run build` (outputs optimized production bundle in `/dist` directory)
- **CI/CD Integration:** Triggered on merge to default branch; builds and deploys to Firebase App Hosting, Vercel, or Docker-based private server. Dockerfiles must run as a non-root user.

## 5. Security & Credentials
- **Local Configurations:** API credentials and environment configurations are loaded from a secure, local, git-ignored `.env.local` file. Default mock credentials are used for emulators.
- **Hosted Configurations:** Production API credentials and URLs are compiled into the build using production environment variables at build/deployment time. Keys must never be committed to git.
- **Secrets Scope & Boundaries:**
  - **ONLY public-facing keys** (such as Firebase client keys that have domain/IP origin restrictions configured on the provider console) are permitted to be compiled into client-side bundles.
  - **Administrative secrets** (such as database write passwords, service account private keys, or API private keys) must **never** be compiled into the frontend. They must be managed via a secure backend vault (like GCP Secret Manager) and accessed through secure backend endpoints with proper IAM controls.
- **CORS/CSP:** Hosted deployments must configure strict server CORS headers and Content Security Policies. HTTPS is mandatory for all network connections.
