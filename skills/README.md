# Digital Systems Engineering Pipeline (Builders Project)

Welcome to the Digital Systems Engineering Pipeline. This repository contains a suite of autonomous AI Agent "Skills" designed to:

1. **Reverse-engineer protocol standards** (IETF, 3GPP, CAMARA, IEEE) into deterministic, behavior-driven Agile tracking matrices in GitHub.
2. **Implement features** from those backlogs using subagent-driven TDD execution discipline with two-stage review gates.

By feeding these agents a Structural Schema (e.g., YANG, OpenAPI, Protobuf) and its associated Normative Specification Document (e.g., an RFC or Technical Specification), the agents will automatically build your Epics, Features, User Stories, and UML Use Cases, ensuring a 100% mathematically bounded requirements pipeline mapped via UML OOA/OOD methodologies.

---

## 🏗️ The Agent Architecture

This toolchain operates on a **Master-Worker architecture** with two distinct pipelines:

### Pipeline 1: Specification Generation (Orchestrator + Workers A-D)

#### `spec-orchestrator` (The Master)
The overarching command-and-control skill. It triggers workers in sequence, enforces strict validation gates between phases, and includes error recovery (halt-and-escalate on failure). See `skills/spec-orchestrator/SKILL.md`.

#### `schema-specification-engineering` (Worker A: Structure)
Parses raw schemas (e.g., `*.yang`, `*.yaml`). Breaks down structural models into **Epics** and **Features** with exhaustive Given-When-Then acceptance criteria, platform scoping, and verbatim spec context injection. Includes duplicate detection to ensure idempotent re-runs. See `skills/schema-specification-engineering/SKILL.md`.

#### `spec-user-story-engineering` (Worker B: Behavior)
Parses operational/deployment chapters. Extracts BDD **User Stories** modeled on UML OOA/OOD principles. Builds a "Cross-Cutting Matrix" linking scenarios to Features from Worker A. Includes duplicate detection. See `skills/spec-user-story-engineering/SKILL.md`.

#### `spec-usecase-engineering` (Worker C: System Interaction)
Extracts formal **UML System Use Cases** (Actors, Preconditions, Main Success Scenarios, Alternate Flows, Postconditions) and maps them to User Stories and Features in a Realization Matrix. Includes duplicate detection. See `skills/spec-usecase-engineering/SKILL.md`.

#### Pipeline Utilities (Worker D & Coverage Check)
* **`reconcile_backlog.py`**: Zero-trust consistency audit. Queries GitHub, syncs checkbox states in local markdown, auto-closes completed Epics/Stories/Use Cases.
* **`verify_model_coverage.py`**: Parses YANG schemas and mathematically verifies 100% model coverage in feature specs. Supports CLI args: `verify_model_coverage.py [yang_dir] [features_dir]`.

### Pipeline 2: Feature Implementation

#### `feature-driven-implementation` (v2.0 — Subagent-Driven TDD Delivery)
The execution engine. Implements features from the backlog using a disciplined, verifiable process. See `skills/feature-driven-implementation/SKILL.md`.

**Core execution discipline (14 mandates):**

| # | Mandate | Purpose |
|---|---|---|
| 1 | Serial Execution | One feature at a time, fully closed before next |
| 2 | The Grill Approval | Interactive design review before any code |
| 3 | Traceability | Closing comments link to solution walkthroughs |
| 4 | Agentic Epic Closure | Auto-close Epics when all features complete |
| 5 | No Browser Automation | Manual UI verification (unless project uses Playwright) |
| 6 | GitHub as Source of Truth | `gh` CLI, never trust local state |
| 7 | Cumulative Walkthroughs | Append/merge, never destructive overwrite |
| 8 | Validation Isolation | Separate subagent audit or strict self-audit fallback |
| 9 | **TDD (RED-GREEN-REFACTOR)** | Failing test before code, always |
| 10 | **Micro-Task Decomposition** | 2-5 min tasks with driving test + verification |
| 11 | **Subagent-Driven Development** | Fresh isolated context per micro-task |
| 12 | **Two-Stage Review** | Spec compliance → Code quality, both must pass |
| 13 | **Verification-Before-Completion** | Raw proof (test output) required, no assertions |
| 14 | **Inter-Task Code Review** | Diff against plan, log deviations |

**Additional protocols:**
- **Systematic Debugging (4-phase):** Reproduce → Diagnose (stack trace, no guessing) → Fix (minimal upstream) → Verify (full suite)
- **Vertical Slice Order:** Database → Parser/State → UI Components

---

## 🖥️ Supported Runtimes

The skills are runtime-agnostic markdown files. The `feature-driven-implementation` skill includes runtime-specific dispatch instructions:

| Runtime | Subagent Dispatch | Two-Stage Review |
|---|---|---|
| **Claude Code** | `Task("prompt")` — native isolated subagent | Separate reviewer subagents |
| **Gemini CLI** | Subagent tool call with curated context | Separate reviewer subagents |
| **Cascade (Windsurf/Devin)** | Coordinator re-reads files per task to simulate isolation; user opens new chat for true isolation | Explicit self-audit documented in `task.md` |

---

## 🚀 How to Run the Specification Pipeline

**Prerequisites:** AI agent framework capable of reading `.md` skill files + executing CLI commands (`gh`, `git`).

1. Ensure your AI agent has access to this `/skills/` directory.
2. Provide your agent with the following prompt:

> **Specification Generation Prompt:**
>
> "Adopt the `spec-orchestrator` skill. I want to reverse-engineer [Protocol Standard, e.g., RFC 8345].
>
> 1. The structural schemas are located at `[path to schemas]`.
> 2. The normative specification documents are located at `[path to specs]`.
>
> Execute the full digital engineering pipeline."

---

## 🛠️ How to Implement a Feature

> **Feature Implementation Prompt:**
>
> "Adopt the `feature-driven-implementation` skill. I want to implement Feature [Issue Number, e.g., #82] targeting platform [react | flutter].
>
> Execute the full delivery workflow with TDD execution discipline:
> 1. Map dependencies from the backlog (`docs/epics/`, `docs/features/`).
> 2. Draft an implementation plan covering the full vertical slice:
>    - Database Layer (test data with edge cases)
>    - Logic & Parser Layer (types, validation, hooks)
>    - UI & Presentation Layer (components, styles, bindings)
>    - Test Plan (failing tests to write BEFORE implementation)
> 3. Decompose into micro-tasks (2-5 min each, with driving test per task).
> 4. Present the plan for approval (The Grill).
> 5. Execute via subagent-driven TDD loop (RED-GREEN-REFACTOR per task).
> 6. Two-stage review after each task (spec compliance, then code quality).
> 7. Provide raw test/build output as proof of completion.
> 8. Provide step-by-step human manual testing instructions.
> 9. Deliver the cumulative solution walkthrough and close the issue upon human approval."

---

## 📊 Expected Outputs

### Specification Pipeline
A perfectly synchronized taxonomy on your live GitHub board:

1. **Epics (`epic`)**: High-level structural containers.
2. **Features (`feature`)**: Granular technical building blocks with verbatim spec text and dependency links.
3. **User Stories (`user-story`)**: Object-oriented BDD scenarios mapped to required Features.
4. **Use Cases (`use-case`)**: Formal UML system interactions mapped down to User Stories and Features.

### Implementation Pipeline
For each delivered feature:

1. **Solution Walkthrough** (`docs/designs/feat-<Issue_Number>-solution.md`): Cumulative record of changes, testing, and verification.
2. **Passing test suite**: All tests green with raw output as evidence.
3. **Closed GitHub Issue**: With direct link to the committed solution walkthrough.
4. **Updated Epic checklist**: Feature marked `[x]`, Epic auto-closed when all features complete.

*Note: Skills automatically bootstrap repository labels (`epic`, `feature`, `user-story`, `use-case`) via `gh label create --force`.*
