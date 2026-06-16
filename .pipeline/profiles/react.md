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
- **UI & Design Aesthetics (GKE Standards & UI Adapter Pattern):**
  - **The UI Adapter Pattern:** The frontend must not generate raw TSX view files for layouts. Structural layout components (splitter layout, hierarchy tree, topology canvas) are written manually once and optimized. Code generators output static JSON configuration schemas (derived from `.pipeline/logical-ui/logical-layout.json`) which are loaded at runtime.
  - **Design System Tokens:** Style variables (colors, typography, spacing, alarm severities) must be compiled or read directly from `.pipeline/logical-ui/design-tokens.json`, configuring CSS custom properties (variables) on the root `<html>` element.
  - **Event-Echo Guard:** Property setters must not trigger output event callbacks. Event propagation is restricted exclusively to user-initiated clicks or drag gestures, verified via AST checkers, to prevent infinite rendering loops. Additionally, a network-level write lock must be activated on the API gateway client during timeline playback or scrubbing to prevent egress mutations.
  - **Splitter Resizing Optimization:** Resizing drag actions must modify CSS custom variables on the grid container directly in the DOM, bypassing the React rendering loop until `onResizeEnd` is fired, ensuring 60fps interaction.
  - **Real-Time Telemetry & 4D Visualization Pipeline (Web Workers & WebGPU):**
    - Sockets, binary packet parsing (gRPC-Web/WebSockets), and telemetry constraint evaluations must run in a background **Web Worker**.
    - For Web Worker message sharing, if strict COOP/COEP headers are missing (disabling `SharedArrayBuffer`), the system must fall back to zero-copy **Transferable ArrayBuffers** using the transferable list in `postMessage(payload, [buffer])`.
    - **Double-Single (DS-FP) Shaders**: 3D coordinates must be split on the CPU into high/low `float32` variables and uploaded to static VRAM buffers. Shaders must perform relative-to-eye (RTE) calculations using emulated double-precision subtraction to eliminate rendering jitter.
    - **GPGPU Collision Detection**: Group distance/conjunction calculations must utilize **Append Buffers** with GPU atomic counters instead of dense $O(N^2)$ distance matrices, and run a CPU-broadphase (Sweep-and-Prune) / GPU-narrowphase execution split.
    - **Offscreen ID Picking**: Click and hover selection of 3D objects must use an offscreen 1x1 integer framebuffer texture (`r32uint` format) read asynchronously (`mapAsync`) to prevent CPU-GPU pipeline readback stalls.
    - **Visual Depth Resolution**: The 3D viewport must use a **Reversed-Z** projection matrix (mapping depth $1.0 \to 0.0$) coupled with a 32-bit floating-point depth buffer (`depth32float`) to prevent planetary-scale z-fighting.
  - **Ubiquitous Navigation Links:** Every reference to a managed object/attribute must be a selectable link that updates the global React Context selection state, triggering a unidirectional update across the sidebar tree, topology canvas, and detail grids.
  - **FOUC Theme Script:** Prevent hydration flashes by injecting a blocking theme script in the HTML `<head>` prior to rendering DOM elements.


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
