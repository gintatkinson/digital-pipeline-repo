---
title: "Implementation Profile — React"
project: "Digital Systems Engineering Pipeline"
tier: implementation
platform: "react"
created: "2026-06-15"
last_updated: "2026-06-15"
---

# Implementation Profile: React Multi-Deployment Profile

> This document governs feature implementation on the React platform.
> Read alongside the functional layer constitution in `.pipeline/constitution.md` (file:///Users/perkunas/digital-pipeline-repo/.pipeline/constitution.md).

---

## 1. Platform & Stack Constraints

### 1.1 Core Technologies
- **Frontend Framework**: React 19.0.x (functional components, Hooks, and Suspense)
- **Programming Language**: TypeScript 5.8+ (Strict Mode enabled)
- **Build Tool / Bundler**: Vite 6.x
- **Styling**: Tailwind CSS v4 (using `@tailwindcss/vite` compiler integration)
- **Router**: React Router v7 (SPA routing with trailing slash normalization)

### 1.2 Multi-Deployment Wrappers
- **Standalone Desktop Archetype**: Tauri v2.x (Rust runtime core with native system webview bindings)
- **Hosted Cloud / Web Archetype**: Express v4.x embedded static server serving `dist/` with SPA fallback routing.
- **Database Framework**: Firebase / Cloud Firestore Web SDK v12.x.

### 1.3 Forbidden Dependencies
- Do NOT use Electron, NW.js, or other thick-browser wrapper runtimes.
- Do NOT import Node-specific built-ins (`fs`, `path`, `child_process`) directly in React components. System actions must go through the Tauri IPC bridge or HTTP APIs.
- Do NOT install TailwindCSS v3 or legacy PostCSS configuration scripts.

---

## 2. Coding Standards & Architecture

### 2.1 Hexagonal Architecture (Ports & Adapters)
All database, networking, and authentication logic must be defined as abstract interfaces ("Ports") implemented by environment-specific modules ("Adapters").

```
[React Component] ──> [Custom Hook / Port Interface] ──> [Firestore SDK Adapter / Tauri Mock Adapter]
```

- **Ports**: Reside under `src/services/interfaces/` (e.g., `IDatabaseService.ts`).
- **Adapters**: Reside under `src/services/firestore/` or `src/services/mock/`.

### 2.2 Firestore Model Typing
All documents read from or written to Firestore must be mapped using standard TypeScript type guards and validators conforming to `firestore.rules`.
- Every Firestore entity must extend a base `FirestoreDocument` type:
  ```typescript
  export interface FirestoreDocument {
    id: string;
    uid: string; // Owner ID
    createdAt: Date | any; // Firestore Timestamp
  }
  ```
- Use type-assertions when deserializing:
  ```typescript
  import { DocumentData, QueryDocumentSnapshot } from 'firebase/firestore';
  
  export function toNode(doc: QueryDocumentSnapshot<DocumentData>): Node {
    const data = doc.data();
    return {
      id: doc.id,
      label: data.label || '',
      domainId: data.domainId || '',
      layer: data.layer || '',
      x: Number(data.x) || 0,
      y: Number(data.y) || 0,
      uid: data.uid || '',
    };
  }
  ```

### 2.3 Local Offline Persistence
Every deployment of the React platform targeting standalone mode must enable offline persistent cache:
```typescript
import { initializeFirestore, persistentLocalCache, persistentMultipleTabManager } from 'firebase/firestore';

export const db = initializeFirestore(app, {
  localCache: persistentLocalCache({
    tabManager: persistentMultipleTabManager()
  })
});
```

---

## 3. Testing Mandates

### 3.1 Frameworks & Coverage
- **Unit & Integration Testing**: Vitest with React Testing Library.
- **E2E Testing (Desktop/Web)**: Playwright (for Web UI verification) and WebdriverIO/Tauri-driver (for Tauri automation).
- **Coverage Thresholds**:
  - Statements: 80% minimum.
  - Branches: 75% minimum.
  - Functions: 80% minimum.

### 3.2 Offline Testing requirement
- Test suites validating database logic must include test scenarios verifying that queries and writes succeed while the network state is mocked as offline, confirming proper cache hit behaviors.

---

## 4. Build & Deployment Configurations

### 4.1 Development Mode
Run local server with Vite HMR middleware:
```bash
npm run dev
# Launches: tsx server.ts (starts Express server wrapping Vite)
```

### 4.2 Standalone Desktop Build (Tauri)
To package the app as a native macOS/Windows application:
```bash
npm run tauri build
# Triggers: vite build && tauri bundler
```

### 4.3 Containerized Cloud Build (Docker)
Web server instances are deployed as Docker containers running Node alpine:
```dockerfile
# Multi-stage production build
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server.ts ./server.ts
COPY --from=builder /app/tsconfig.json ./tsconfig.json
EXPOSE 3000
CMD ["npx", "tsx", "server.ts"]
```

---

## 5. Security & Operations

### 5.1 Environment Variables
All secret keys and API credentials must be injected at build/launch time using environment variables.
- **Required Environment Variables**:
  - `VITE_FIREBASE_API_KEY`: Firebase API Key.
  - `VITE_FIREBASE_PROJECT_ID`: Firebase project identifier.
  - `VITE_USE_EMULATOR`: Set to `true` to force redirect connection to the local emulator suite.
- Hardcoded production keys in the codebase are forbidden.

### 5.2 Local Developer Sandbox
For offline development without cloud costs:
1. Run `firebase emulators:start` in your workspace.
2. Ensure your dev config automatically redirects connection ports (Firestore: 8080, Auth: 9099).
