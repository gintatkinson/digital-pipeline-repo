---
title: "Implementation Profile — React Platform"
project: "Network Topology Viewer"
tier: implementation
platform: "react"
created: "2026-06-16"
last_updated: "2026-06-16"
---

# Implementation Profile: React Platform (Network Topology Viewer)

> This document governs feature implementation for the React frontend of the Network Topology Viewer.
> Read alongside `.pipeline/constitution.md` (functional layer).

## 1. Platform & Stack
- **Framework & Version:** React 18, Vite
- **Language & Version:** TypeScript 5.x (strict mode)
- **State Management:** Unidirectional React Context (to manage active selection of networks, nodes, and links).
- **Dependencies:**
  - Required: `react`, `react-dom`, `typescript`
  - DevDependencies: `vite`, `jest`, `@testing-library/react`

## 2. Coding Standards & UI Patterns
- **Clean Decoupling (Repository Pattern):**
  - React view components must never fetch data directly.
  - Data loading from YANG-derived JSON files or backend APIs must be encapsulated in an abstract repository class (`TopologyRepository`).
- **Typing Rules:**
  - Strict null checks enabled.
  - All properties mapped from the YANG schema (e.g., `network-id`, `source-node`) must map to strict TypeScript interfaces.
- **Component Styling:**
  - Use Vanilla CSS modules for layout styling to ensure platform independence and clean scope.

## 3. Testing Mandates
- **TDD Requirement:** Strict RED-GREEN-REFACTOR cycle. Write a unit test verifying component data mapping before implementing the render code.
- **Coverage Target:** Minimum 85% statement coverage on data adapters and coordinate parsing classes.

## 4. Build & Operations
- **Lint Command:** `npm run lint`
- **Dev Server Command:** `npm run dev`
- **Build Command:** `npm run build`
