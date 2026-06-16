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
  - `VITE_PERSISTENCE_ADAPTER`: Configures which concrete adapter is injected at bootstrap (e.g. `firebase-emulator`, `grpc`, `openapi`).
- **Dependencies:**
  - Required: `firebase`, `grpc-web`, `@protobuf-ts/grpcweb-transport`, `axios`, `typescript`, `react`, `react-dom`, `@react-three/fiber`, `three`
  - DevDependencies: `firebase-tools`, `vite`, `jest`, `@testing-library/react`, `playwright`

## 2. Coding Standards & UI Patterns
- **Clean Architecture & Decoupling:** Persistence code must be isolated under `src/core/persistence/`:
  - `src/core/persistence/repository.interface.ts` (defines CRUD and domain-specific query interfaces)
  - `src/core/persistence/adapters/` (contains concrete implementations: `firebase-emulator.adapter.ts`, `local-service.adapter.ts`, etc.)
  - `src/core/persistence/testing/` (contains mock implementations for fast unit testing stubs)
- **Naming Conventions:**
  - PascalCase for React components and class-based Adapters.
  - camelCase for interface declarations and instances.
  - kebab-case for folders and file names.
- **Type Strictness:** Strict null checks enabled; use of `any` is strictly prohibited. Every database model must map to a TypeScript interface.
- **Off-Thread Telemetry Pipeline:**
  - To prevent main-thread UI starvation during high-frequency data streaming, all gRPC/WebSocket stream connections, binary packet decoding, and telemetry JSON deserialization MUST execute off-thread inside a background **Web Worker**.
  - Pass decoded, normalized domain structures to the main thread via standard `postMessage` serialization or shared memory buffers.
- **UI & Design Aesthetics (Google Cloud Console / GKE Standards):**
  - **Visual Identity:** Interfaces must mimic the clean, high-density, professional look of the Google Cloud Console.
  - **Theme Selection:**
    - Must provide a user interface to select between **Light**, **Dark**, and **System** (OS/browser default) themes.
    - The application must use CSS custom properties (variables) prefixing color tokens (e.g., `--color-brand-primary`, matching `design-tokens.json` namespaces) to allow dynamic, reload-free theme switching.
    - An in-head script must load the theme preference from `localStorage` or browser defaults and apply it to `<html>` prior to page rendering to avoid a Flash of Unstyled Content (FOUC).
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
      - Virtualized flat-list row rendering for large trees.
      - Accessibility ARIA roles (`role="tree"`, `role="treeitem"`, `aria-level`, `aria-expanded`).
    - **Split Workspace Layout (ResizableSplitter):** The main workspace area renders two primary panes.
      - Default layout: stacked vertically. The user can toggle to side-by-side (vertical split). Clarify alignment: horizontal split cuts horizontally (stacking vertically); vertical split cuts vertically (stacking horizontally).
      - **Performance Optimization:** Dragging the splitter must update local CSS variables directly on the grid container in the DOM (bypassing React component re-renders until drag completion `onResizeEnd`) and leverage CSS `contain: layout paint`.
      - **Snap-to-Edge:** Support snap-to-edge collapse when dragged within 10% of boundaries.
      - **Top Pane (3D/4D Spatial-Temporal Canvas):** Displays an interactive `TopologyMap` representing the selected managed object's relations in 3D coordinate space. Must support dynamic trajectory path lines, orbital projections, volumetric bounding indicators, and a global timeline scrubber with playback controls. Layout physics calculations are offloaded to WebGPU Compute Shaders in VRAM using padded Storage Buffers.
      - **Bottom Pane (Details & Relations Pane):** Displays detailed attributes and related child objects grouped under a `TabbedContainer` holding tabbed `TableView`s (specifically Elements, Alarms, and Events).
    - **PropertyGrid Component:** Key-value attribute grid mapped to a schema. JSON-schemas are compiled *once* at initialization into a flat, typed layout descriptor list to avoid render-cycle parsing lag. Input fields validate on blur and maintain a local change-buffer to block global state re-renders on keystroke.
    - **NavigationBreadcrumbs:** Breadcrumbs at the content area top. Collapse middle segments into an ellipsis (`...`) if the total text width exceeds the available container width.
    - **Ubiquitous Navigation Links:** Whenever the UI presents a managed object or attribute, it must be rendered as a selectable, clickable link that directly navigates to that item.
    - High information-density tables with sortable, filterable columns, row selections, and status badges.
  - **Typography:** Use clean, professional system fonts or Roboto/Outfit.
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
- **Hosted Configurations:** Production API credentials and URLs are compiled into the build using production environment variables (e.g., `VITE_FIREBASE_API_KEY`) at build/deployment time. Keys must never be committed to git.
- **Secrets Scope & Boundaries:**
  - **ONLY public-facing keys** (such as Firebase client keys that have domain/IP origin restrictions configured on the provider console) are permitted to be compiled into client-side bundles.
  - **Administrative secrets** (such as database write passwords, service account private keys, or API private keys) must **never** be compiled into the frontend. They must be managed via a secure backend vault (like GCP Secret Manager) and accessed through secure backend endpoints with proper IAM controls.
- **CORS/CSP:** Hosted deployments must configure strict server CORS headers and Content Security Policies. HTTPS is mandatory for all network connections.
