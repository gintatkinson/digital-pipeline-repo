<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

# Feature-Driven Autonomous Delivery Workflow

> **Canonical Skill Definition:** [`skills/feature-driven-implementation/SKILL.md`](../../skills/feature-driven-implementation/SKILL.md)
> This document is a human-readable overview. The SKILL.md is the authoritative, machine-consumable definition with full TDD discipline, subagent dispatch, and two-stage review gates.

This document outlines a high-quality, dependency-driven agentic workflow for serially implementing features based on the project's Epics, Features, and User Stories. It enforces strict serialization, interactive design approval, and end-to-end GitHub lifecycle management.

## 1. Goal Description

To establish a rigorous, serial, and interactive agentic pipeline. Instead of attempting parallel implementation, the AI agent will strictly prioritize work based on architectural dependencies. Each feature undergoes a dedicated lifecycle—from isolated branch creation and interactive design validation to execution, testing, and final release—ensuring maximum alignment with user intent and zero architectural regressions.

## 2. The Agentic Implementation Process

The workflow is broken down into five distinct, sequential phases that govern how every feature is delivered.

### Phase 1: Dependency Mapping & Prioritization (The Backlog)
Before any code is written, the agent analyzes the `docs/` hierarchy (Epics, Features, User Stories) to understand the architectural constraints.
- **Action:** The agent maps the dependency tree (e.g., base node structures must be implemented before link termination endpoints).
- **Output:** A serialized queue of GitHub Issues/Features. 
- **Rule:** We strictly operate on **one feature at a time**. We do not move to feature N+1 until feature N is closed and released.

### Phase 2: Checkout & Design Iteration ("The Grill")
Once a feature reaches the top of the queue, the active implementation cycle begins.
- **Action:** 
  1. **Branching:** The agent autonomously checks out a new feature branch from `<default-branch>` (e.g., `git checkout -b feat/38-node-termination-points`).
  2. **Solution Design:** The agent creates a highly detailed, feature-specific Design & Implementation Plan artifact mapping out exactly what files will change, how the schemas map to the UI, and any trade-offs.
  3. **The Grill:** We enter an interactive review loop. You and I "grill each other" to clarify ambiguities, challenge design choices, and validate adherence to the RFC specifications.
- **Output:** A finalized, mutually approved implementation blueprint. No code is written until absolute consensus is reached.

### Phase 3: Execution & Build
With a finalized plan, the agent moves to execution.
- **Action:** The agent writes the code, updating TypeScript interfaces, mock services, and React components based *only* on the approved plan. 
- **Rule:** If unexpected roadblocks arise during coding, the agent pauses execution and brings the issue back to "The Grill" for resolution.
- **Output:** Working, committed code on the feature branch that builds successfully without linting or compilation errors.

### Phase 4: Testing & Verification
The agent hands the completed build over to you for validation.
- **Action:** The agent starts the local development server (or provides the necessary artifacts) and invites you to test the feature manually in the browser.
- **Feedback Loop:** If there are bugs or UI adjustments needed, the agent applies fixes incrementally and pushes new commits to the branch until you are completely satisfied.
- **Output:** A fully verified and robust feature.

### Phase 5: Release & Closure
The final stage of the feature's lifecycle.
- **Action:** 
  1. Once you explicitly accept the feature, the agent merges the feature branch into `<default-branch>`.
  2. **Solution Document Creation:** The agent commits the final Walkthrough/Solution document to the `docs/designs/` directory.
     * **Strict Naming Constraint:** The file MUST be formatted exactly as `feat-<Issue_Number>-solution.md` or `epic-<Issue_Number>-solution.md`, where `<Issue_Number>` is the unique GitHub Issue Number (e.g., `feat-82-solution.md`). **DO NOT** use the Feature Index number (e.g., Feature 24) if the Issue Number is different.
     * **Zero-Trust Collision Check:** Before creating the file, search the repository and Git history to ensure the filename does not already exist. If it does, halt and resolve the naming conflict.
  3. The agent pushes the changes to `<default-branch>` and uses the `gh` CLI to close the corresponding Issue in GitHub, explicitly embedding a direct URL link to the committed solution document on the remote standard default branch in the closing comment.
  4. The corresponding local Epic markdown file is updated to check off the feature (`[x]`).
  5. The local and remote feature branches are deleted.
  6. **Agentic Epic Closure:** If all constituent features in the local Epic checklist are now completed (`[x]`), the agent must update the Epic issue's body on GitHub and close the Epic issue itself on GitHub using the `gh` CLI with an appropriate summary comment.
- **Output:** A clean, released feature with fully linked documentation, and any completed parent Epics successfully closed on GitHub, readying the agent to pull the next prioritized feature from Phase 1.
