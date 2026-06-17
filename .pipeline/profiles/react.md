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
- **Framework & Version:** React (as resolved from environment configuration)
- **Language & Version:** TypeScript (strict mode enabled)
- **Persistence Architecture:** Modular Repository/Adapter pattern.
  - Direct database/API SDK imports are forbidden in React components.
  - Components must depend only on abstract Repository interfaces.
  - Active adapter is injected at application bootstrap resolved dynamically from the loaded runtime configuration metadata rather than build-time environment variables.
- **Dependency Injection (DI):** Standardize on React Context Hooks for dependency resolution at the application root.
- **Allowed Adapters:**
  - Transport and database adapters must register themselves dynamically at application bootstrap. The platform profile does not restrict the allowed adapter types; any class implementing the target Repository interface is permitted, enabling dynamic runtime resolution of any protocol or database client (e.g. REST, gRPC, WebSocket, GraphQL, or local storage).
- **Environment Selection Keys:**
  - Resolved dynamically from the platform configuration metadata (e.g., config keys specifying the active persistence adapter injected at bootstrap).
- **Dependencies:**
  - Required: Resolved dynamically from the platform configuration file (parsed from the package dependencies config block).
  - DevDependencies: Resolved dynamically from the platform configuration file.

## 2. Coding Standards & UI Patterns
- **Clean Architecture & Decoupling:** Persistence code must be isolated under the designated persistence directory resolved from configuration (e.g., source persistence adapters directory):
  - Repository interfaces defining CRUD and domain-specific query interfaces.
  - Concrete adapter implementations.
  - Mock implementations for fast unit testing stubs.
- **Naming Conventions:**
  - PascalCase for React components and class-based Adapters.
  - camelCase for interface declarations and instances.
  - kebab-case for folders and file names.
- **Type Strictness:** Strict null checks enabled; use of `any` is strictly prohibited. Every database model must map to a TypeScript interface.
- **Off-Thread Processing:**
  - To prevent main-thread UI starvation during high-frequency data streaming or heavy parsing, all intensive computation and data deserialization MUST execute off the main thread inside a background execution context (such as Web Workers).
  - Pass normalized domain structures to the main thread via asynchronous message passing.
- **Resource Management:**
  - Explicitly manage runtime memory lifecycles for hardware-accelerated viewports or large buffers, releasing memory in component cleanup hooks to prevent leaks.
  - Pre-allocate and reuse memory blocks where possible to avoid continuous runtime memory allocation.
- **UI & Design Aesthetics (Professional High-Density Console Standards):**
  - **Visual Identity:** Interfaces must mimic a clean, high-density, professional management console.
  - **Theme Selection:**
    - Must provide a user interface to select from the dynamic list of theme modes defined in the runtime configuration (Tier 2).
    - The application must map styling parameters dynamically to color tokens matching the active design token namespaces resolved from the loaded configuration to allow dynamic, reload-free theme switching.
    - The theme preference must be resolved dynamically in an SSR-safe and hydration-compatible manner. Visual theme flashes (FOUC) must be prevented using environment-appropriate mechanisms (such as CSS custom properties or native style rules mapped from theme preferences during hydration, or conditional HTML `<head>` theme script injections safely gated checking `typeof window !== 'undefined'` for non-browser/SSR environments) to ensure compatibility with Server-Side Rendering (SSR) environments and headless Node-based unit testing environments.
  - **Dynamic Design Tokens & Alarm Mappings:**
    - Hardcoding visual parameters (e.g., hex colors, margins) or standard-specific mappings (e.g., specific alarm severities or colors) is strictly forbidden.
    - All status colors, brand palettes, and component styles must be loaded dynamically from the active design tokens configuration resolved at runtime.
    - At startup, the application must dynamically resolve and apply styling tokens parsed from the configuration in a testing-safe, headless-compatible manner. The configuration resolution must not rely on blocking head script injection or assume browser-specific DOM API access during startup or unit-test verification loops.
    - Status visualizations, node borders, and alarm indicators must resolve their colors and severity levels dynamically via a metadata-driven UI registry loaded at runtime.
  - **Layout & Structure:**
    - Navigation architecture aligned with hierarchical layout slot containers.
    - **Hierarchy Navigation Component:** (e.g. hierarchy tree or navigation slot resolved from configuration). Exposes a primary navigation slot. Must support:
      - Mapping physical inputs to logical action bindings (such as `NAVIGATE_NEXT`, `NAVIGATE_PREVIOUS`, `EXPAND_NODE`, `COLLAPSE_NODE`) dynamically.
      - Virtualized list row rendering.
      - Dynamic accessibility semantic injection.
    - **Resizable Splitter Component:** The main workspace area renders pane slots dynamically populated with child components resolved from the runtime layout configuration registry.
      - Default layout: stacked along a configurable split axis. The user can toggle split directions.
      - **DOM State Preservation during Reparenting:** Swapping split axis orientations (vertical/horizontal) or changing pane order must preserve component state. The layout must use structural virtual DOM stability (e.g. keeping container elements persistently mounted in a fixed tree structure and using CSS Flexbox/Grid direction variables) rather than conditional JSX element branching/unmounting to prevent DOM state destruction (such as text input focus, active playback state, or embedded frame/iframe contexts).
      - **Isolating Reflows:** All panel containers within resizable splitters must use CSS Container Queries (`@container`) and layout/paint containment (`contain: size layout paint; container-type: inline-size;`) on the splitter containers to isolate layout reflows during active dragging.
      - **Virtual DOM State Resizing:** Resizing interactions must update layout state variables or CSS custom properties managed through React state/context or a decoupled state provider, rather than directly mutating the physical DOM bypassing the React virtual DOM tree, ensuring headless testing compatibility (except during active drag gestures where direct DOM inline custom property mutations are permitted solely for 60fps painting optimization).
      - **Snap-to-Edge:** Support snap-to-edge collapse when dragged within the configured threshold boundaries.
      - Child components resolved from the layout configuration (such as viewports, attribute grids, or lists) are dynamically rendered inside the workspace containers.
    - **Property Grid Component:** Key-value attribute grid mapped to a schema. Validation schemas are compiled *once* at initialization into a flat, typed layout descriptor list to avoid render-cycle parsing lag. Input fields validate upon focus loss or edit completion and maintain a local change-buffer to block global state re-renders on keystroke.
    - **Navigation Breadcrumbs Component:** Exposes a breadcrumb path resolved from the current selection. Collapses middle segments dynamically when the path length exceeds available container space.
    - **Ubiquitous Navigation Links:** Whenever the UI presents a managed object or attribute, it must be rendered as a selectable, clickable link that directly navigates to that item.
    - **Density Table Component:** High information-density tables with sortable, filterable columns, row selections, and status badges.
  - **Typography:** Resolved dynamically from the typography design tokens.
  - **Interactivity:** Micro-animations for hover states, side-panel slide-outs, loading skeletons, and inline help tooltips.

## 3. Testing Mandates
- **TDD Requirement:** Strict RED-GREEN-REFACTOR cycle. Write a test before writing the code.
- **TDD Loop Speed:** Unit and widget/component tests must execute against isolated, thread-safe in-memory stubs (Mock Repositories) for fast, sub-second feedback.
- **Integration/E2E Test Instances:** All integration and E2E tests must execute against real, local database service instances (local emulators/containers) loaded with seeded test data. In-memory stubs are prohibited for these tiers.
- **E2E Testing:** E2E tests running against the local dev server and the configured local emulator/services suite during local runs, or targeting a staging/preview deployment URL connected to a staging database environment for hosted runs.
- **Test Code Statement Coverage Target:** Minimum statement coverage targets on core business logic, validation schemas, and calculation engines, excluding simple repository wrappers from the generic line-coverage gate, as defined in configuration.

## 4. Build & Operations
- **Lint Command:** Commands resolved from environment configurations (e.g. `npm run lint` / `npx tsc --noEmit`)
- **Local Dev / Dev Server Command:** Command resolved from environment configurations (e.g. `npm run dev`)
- **Local Emulator Command:** Command resolved from environment configurations (e.g. `firebase emulators:start --import=./.firebase_export`)
- **Build Command:** Command resolved from environment configurations (outputs optimized production bundle in the configured build output directory, e.g. `/dist`)
- **CI/CD Integration:** Triggered on merge to default branch; builds and deploys to Firebase App Hosting, Vercel, or Docker-based private server. Dockerfiles must run as a non-root user.

## 5. Security & Credentials
- **Local Configurations:** API credentials and environment configurations are loaded from a secure, local, git-ignored `.env.local` file. Default mock credentials are used for emulators.
- **Hosted Configurations:** To support the "Build Once, Deploy Anywhere" pattern, production API credentials and environment configurations must be loaded dynamically at runtime (e.g., via a runtime config JSON file fetch at bootstrap or a dynamic config service endpoint) rather than compiling credentials or backend URLs into the client bundle at build/deployment time. Keys must never be committed to git.
- **Secrets Scope & Boundaries:**
  - **ONLY public-facing keys** (such as Firebase client keys that have domain/IP origin restrictions configured on the provider console) are permitted to be compiled into client-side bundles.
  - **Administrative secrets** (such as database write passwords, service account private keys, or API private keys) must **never** be compiled into the frontend. They must be managed via a secure backend vault (like GCP Secret Manager) and accessed through secure backend endpoints with proper IAM controls.
- **CORS/CSP:** Hosted deployments must configure strict server CORS headers and Content Security Policies. HTTPS is mandatory for all network connections.
