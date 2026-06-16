---
title: "Implementation Profile — React Platform"
project: "Digital Systems Engineering Pipeline"
tier: implementation
platform: "react"
created: "2026-06-16"
last_updated: "2026-06-16"
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
- **Allowed Adapters by Environment:**
  - **Local Development / Testing:**
    - `FirebaseEmulatorAdapter`: Connects to local Firebase Emulator Suite containing seeded test data.
    - `LocalServiceAdapter`: Connects to local OpenAPI / gRPC database gateway services running on `localhost`.
  - **Hosted Deployment / Staging / Production:**
    - `FirebaseHostedAdapter`: Connects to remote hosted production Firebase.
    - `GrpcAdapter`: Connects to hosted remote gRPC/gRPC-Web backend services.
    - `OpenApiAdapter`: Connects to hosted remote REST/OpenAPI JSON backend services.
- **Dependencies:**
  - Required: `firebase`, `grpc-web`, `@protobuf-ts/grpcweb-transport`, `axios`, `typescript`, `react`, `react-dom`
  - DevDependencies: `firebase-tools`, `vite`, `jest`, `@testing-library/react`, `playwright`

## 2. Coding Standards & UI Patterns
- **Clean Architecture & Decoupling:** Persistence code must be isolated under `src/core/persistence/`:
  - `src/core/persistence/repository.interface.ts` (defines CRUD and domain-specific query interfaces)
  - `src/core/persistence/adapters/` (contains concrete implementations: `firebase-emulator.adapter.ts`, `local-service.adapter.ts`, etc.)
- **Naming Conventions:**
  - PascalCase for React components and class-based Adapters.
  - camelCase for interface declarations and instances.
  - kebab-case for folders and file names.
- **Type Strictness:** Strict null checks enabled; use of `any` is strictly prohibited. Every database model must map to a TypeScript interface.
- **UI & Design Aesthetics (Google Cloud Console / GKE Standards):**
  - **Visual Identity:** Interfaces must mimic the clean, high-density, professional look of the Google Cloud Console.
  - **Theme Selection:**
    - Must provide a user interface to select between **Light**, **Dark**, and **System** (OS/browser default) themes.
    - The application must use CSS custom properties (variables) to define color tokens for all theme styles, ensuring seamless switching without page reload.
    - An in-head script must load the theme preference from `localStorage` or browser defaults and apply it to `<html>` prior to page rendering to avoid a Flash of Unstyled Content (FOUC).
  - **Color Palette:** Curated neutral greys, clean white/dark backgrounds, with specific accent colors:
    - Google Blue (`#1a73e8`) for primary actions and active navigation states.
    - Soft red, yellow, and green status chips for resource health indicators (mimicking GKE cluster health states).
  - **Layout & Structure:**
    - Left-hand collapsible sidebar navigation with GKE-style hierarchical nesting.
    - **Vertical Hierarchy Selector:** A dedicated left-side vertical tree selection panel for managed objects, allowing the user to select and drill down through hierarchical parent-child relationships (e.g., Folder > Project > Resource/Managed Object) just like the Google Cloud resource hierarchy selector.
    - **Split Workspace Layout:** For each selected managed object, the main workspace area must render two primary panes separated by a slider adjuster (split bar).
      - By default, the panes are stacked vertically (horizontal split). Dragging the slide adjuster vertically must dynamically modify each pane's proportional vertical size.
      - **Reconfigurability:** The positions and orientation of the two primary panes must be reconfigurable by the user (e.g., allowing the user to swap top/bottom positions or switch the layout axis to a vertical split/side-by-side view).
      - **Topographical View Pane (Top/Default Pane):** Displays an interactive topographical map representing the selected managed object's topological relations with other managed objects.
        - Must support **relationship filtering** (filtering which types of relations are displayed).
        - Must support **depth constraints** (e.g. a hop-count selector to limit the degrees of separation shown in the topology).
      - **Details & Relations Pane (Bottom/Default Pane):** Shows all detailed attributes of the selected managed object.
        - Must display lists of contained or related managed objects, with direct navigation shortcuts to select/inspect them.
    - **Ubiquitous Navigation Links:** Whenever the user interface presents a managed object or attribute (e.g., inside tables, lists, text labels, or nodes in the topographical map), it must be rendered as a selectable, clickable link that directly navigates to that item's detail view, configuration window, or focus context.
    - Breadcrumbs at the top of the content area for deep-level navigation tracking.
    - High information-density tables with sortable, filterable columns, row selections, and status badges.
  - **Typography:** Use clean, professional system fonts or Roboto/Outfit. Avoid default browser sans-serif styles.
  - **Interactivity:** Micro-animations for hover states, side-panel slide-outs, loading skeletons, and inline help tooltips.

## 3. Testing Mandates
- **TDD Requirement:** Strict RED-GREEN-REFACTOR cycle. Write a test before writing the code.
- **TDD Loop Speed:** Unit and widget tests must execute against isolated, thread-safe in-memory stubs (Mock Repositories) for fast, sub-second feedback.
- **Integration/E2E Test Instances:** All integration and E2E tests must execute against real, local database service instances (local emulators/containers) loaded with seeded test data. In-memory stubs are prohibited for these tiers.
- **E2E Testing:** Playwright E2E tests running against the Vite local dev server and the Local Firebase Emulator Suite (Firestore, Auth) or local API containers during local runs, or targeting a staging/preview deployment URL connected to a staging database environment for hosted runs.
- **Coverage Target:** Minimum 85% statement coverage on core business logic, validation schemas, and calculation engines. Exclude simple repository wrappers from the generic 85% line-coverage gate (set to 20% smoke-test baseline) to avoid tautological testing.

## 4. Build & Operations
- **Lint Command:** `npm run lint` / `npx tsc --noEmit`
- **Local Dev / Dev Server Command:** `npm run dev`
- **Local Emulator Command:** `firebase emulators:start --import=./.firebase_export`
- **Build Command:** `npm run build` (outputs optimized production bundle in `/dist` directory)
- **CI/CD Integration:** Triggered on merge to default branch; builds and deploys to Firebase App Hosting, Vercel, or Docker-based private server.

## 5. Security & Credentials
- **Local Configurations:** API credentials and environment configurations are loaded from a secure, local, git-ignored `.env.local` file. Default mock credentials are used for emulators.
- **Hosted Configurations:** Production API credentials and URLs are loaded strictly via environment variables (e.g., `VITE_FIREBASE_API_KEY`) at build/deployment time. Keys must never be committed to git.
- **CORS/CSP:** Hosted deployments must configure strict server CORS headers and Content Security Policies. HTTPS is mandatory for all network connections.
