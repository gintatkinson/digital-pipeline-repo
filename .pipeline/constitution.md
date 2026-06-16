<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

---
title: "Project Constitution -- Functional Layer"
project: "Network Topology Viewer"
tier: functional
created: "2026-06-16"
last_updated: "2026-06-16"
---

# Project Constitution: Network Topology Viewer

> This document governs specification generation and is platform-independent.
> All agents MUST read this file before beginning any pipeline execution.
> For platform-specific rules, see `.pipeline/profiles/<platform>.md`.

---

## 1. Domain Rules (IETF RFC 8345 - YANG Network Topology)

### 1.1 Specification Sources
- The primary source is the normative standard: **IETF RFC 8345** ("A YANG Data Model for Network Topologies").
- The authoritative machine-readable models are the constituent YANG schemas:
  - `ietf-network` (defines the network and node structures)
  - `ietf-network-topology` (defines link and termination-point structures)

### 1.2 Schema Compliance
- Every network data model constraint in the schemas MUST map to at least one Feature's acceptance criteria.
- Specific RFC 8345 constraints that must be validated:
  - Unique keys: `network-id` (network), `node-id` (node), `link-id` (link), and `tp-id` (termination-point).
  - Source (`source-node`, `source-tp`) and destination (`dest-node`, `dest-tp`) existence constraints.
  - Supporting network, node, and link references for hierarchical layering (virtualization/underlay topology mappings).

### 1.3 Metamodel Alignment (YANG to UML Profile Mapping)
To maintain platform independence, the YANG elements of RFC 8345 map to UML elements as follows:
- **YANG Module** (`ietf-network`, `ietf-network-topology`) maps to a **UML Component**.
- **YANG list** (`network`, `node`, `link`, `termination-point`) maps to a **UML Class**.
- **YANG leaf / leaf-list** (e.g., `network-id`, `server-provided`) maps to a **UML Attribute** with visibility and multiplicity (e.g. `+networkId : String [1]`).
- **YANG leafref / constraints** (`must`, `when`) map to a **UML Constraint** (written in OCL or structured text).
- **YANG grouping** maps to a **UML Class**.

---

## 2. Specification Standards

### 2.1 Epic & Feature Granularity
- Epics represent major functional areas of RFC 8345 (e.g., `Network Inventory`, `Topology Link Mapping`, `Hierarchical Networks`).
- Features must be purely functional (e.g., "Display Node Details," "Verify Uniqueness of Link Keys") and contain no React or TypeScript references.

### 2.2 BDD Scenario Format
- All acceptance criteria must use Given-When-Then format.
- Example:
  ```
  Given a network topology with network-id "optical-core"
  When the system receives a new link-id "link-101" referencing source-node "node-99" (which does not exist in the network)
  Then the system rejects the link payload with a source validation error
  ```

---

## 3. Agent Behavior Rules

### 3.1 User Authorization Lock
- **Authorization Lock**: The agent is strictly forbidden from invoking any file-writing tools (`write_to_file`, `replace_file_content`, `multi_replace_file_content`) or terminal execution tools (`run_command`) unless the user's latest message contains the word `PROCEED` (case-insensitive).
- **Mandatory Compliance Check**: Every thought block must begin with the 3-point Karpathy Compliance Check.
