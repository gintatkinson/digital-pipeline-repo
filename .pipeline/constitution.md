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

## 1. Domain Rules (Network Topology)

### 1.1 Specification Sources
- The primary source is the normative standard defining the network topology.
- The authoritative machine-readable models are the logical schemas defining the network structures (nodes, links, and termination points).

### 1.2 Schema Compliance
- Every network data model constraint in the logical schemas MUST map to at least one Feature's acceptance criteria.
- Specific topology constraints that must be validated:
  - Unique identification keys for networks, nodes, links, and termination points.
  - Source and destination presence constraints for all links.
  - Supporting network, node, and link references for hierarchical layering (virtualization/underlay mappings).

### 1.3 Metamodel Alignment (Abstract Schema to UML Mapping)
To maintain platform independence, the logical schema elements map to UML elements as follows:
- The top-level schema namespaces or modules map to a **UML Component**.
- Entity definitions (e.g., networks, nodes, links) map to a **UML Class**.
- Properties and data fields map to a **UML Attribute** with visibility and multiplicity (e.g., `+attributeName : Type [1]`).
- Logical constraints and conditional rules map to a **UML Constraint** (written in OCL or structured text).

---

## 2. Specification Standards

### 2.1 Epic & Feature Granularity
- Epics represent major functional areas of the topology viewer (e.g., Node Management, Link Mapping, Hierarchical Views).
- Features must be purely functional and contain no framework or implementation language references.

### 2.2 BDD Scenario Format
- All acceptance criteria must use Given-When-Then format.
- Example:
  ```
  Given a network topology with network identifier "backbone"
  When the system receives a new link referencing a source node that does not exist in the network
  Then the system rejects the link payload with a validation error
  ```

---

## 3. Agent Behavior Rules

### 3.1 User Authorization Lock
- **Authorization Lock**: The agent is strictly forbidden from invoking any file-writing tools (`write_to_file`, `replace_file_content`, `multi_replace_file_content`) or terminal execution tools (`run_command`) unless the user's latest message contains the word `PROCEED` (case-insensitive).
- **Mandatory Compliance Check**: Every thought block must begin with the 3-point Karpathy Compliance Check.
