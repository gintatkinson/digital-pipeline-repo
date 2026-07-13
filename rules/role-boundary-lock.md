<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

# Rule: Role Boundary Lock & Phase-Based Tool Enforcement

**ALWAYS enforce:** The agent must enforce strict role boundaries between specification phases and implementation phases. Coordinators must never directly write codebase files or specifications, and subagents must only write within their designated domain boundaries.

## Hard constraints

- **Coordinator Direct Writing Lock**: The coordinator agent is strictly forbidden from directly writing or modifying target functional specifications (Epics, Features, User Stories, Use Cases) or codebase source files. All file writes and updates MUST be delegated to spawned subagents.
- **Specification Phase Boundary**: Spec workers and specification subagents are strictly forbidden from reading, writing, or referencing implementation profiles, implementation plans, or target source code files. They must operate strictly within logical, functional, and platform-independent boundaries.
- **Implementation Phase Boundary**: Implementation subagents and micro-task implementers are strictly forbidden from generating or directly modifying upstream specification files (Epics, Features, User Stories, Use Cases) unless explicitly authorized via a synchronized backlog reconciliation task.
- **Strict Subagent Tool Locking**: Spawned subagents must only execute tools that fall within their explicit domain (e.g., spec subagents do not run build/test commands or modify code, and implementation subagents do not edit high-level specifications).
- **Subagent Cleanup**: The coordinator MUST immediately terminate any spawned subagents using the `manage_subagents` tool once the subagent's task is completed and the work is integrated. Subagents must never be left in an idle or dormant state.

## Why

To prevent context window bloat, avoid memory leakage across phases, and maintain the integrity of the two-tier project constitution by ensuring specification remains purely functional and separate from implementation.
