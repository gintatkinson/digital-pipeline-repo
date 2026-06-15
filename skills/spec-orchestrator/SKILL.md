<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

---
name: spec-orchestrator
description: "Orchestrates end-to-end multi-agent protocol specification engineering. Use when you need to transform a protocol standard (IETF, 3GPP, IEEE, CAMARA) into a complete GitHub-tracked Agile backlog of Epics, Features, User Stories, and Use Cases."
compatibility: "Requires gh CLI and git. Works with Claude Code, Gemini CLI, Cursor, Copilot, Cascade."
metadata:
  title: "Autonomous Specification Orchestrator (Master Command)"
  category: orchestration
  risk: medium
  source: custom
  version: "2.0"
---

# Autonomous Specification Orchestrator (Master Command)

This skill enables you to act as the **Master Orchestrator Agent**. You are responsible for executing an end-to-end "Digital Engineering Pipeline" that systematically transforms a protocol standard (e.g., IETF, 3GPP, IEEE, CAMARA) into a deterministic GitHub repository matrix using UML OOA/OOD methodologies.

You will accomplish this by coordinating the sequential execution of three specialized Worker skills.

> [!NOTE]
> This orchestrator handles **specification generation** (Phases 1-5). For **feature implementation**, use the separate `feature-driven-implementation` skill which provides subagent-driven TDD execution discipline.

## Error Recovery
If any phase fails (worker error, GitHub API failure, validation gate failure):
1. **Do not proceed** to the next phase.
2. **Log the exact error** (stderr, exit code, GitHub API response).
3. **Attempt remediation:** Re-run the failed step once. If it fails again, escalate to the user with the full error context.
4. **Never skip a validation gate.** If a gate cannot be satisfied, the pipeline is halted until manually resolved.

## Pre-Flight Checklist
Before beginning orchestration, verify you have:
1. The target specification identifier (e.g., RFC 8345, 3GPP TS 23.501).
2. The path(s) to the associated structural schemas (e.g., `*.yang`, `*.yaml`, `*.proto`).
3. *(Optional)* A project constitution at `.pipeline/constitution.md`. If present, read it and apply platform/domain constraints to all worker dispatches.

## Parallel Dispatch Convention

Phases marked with **`[P]`** may be dispatched in parallel when:
- The runtime supports parallel subagent dispatch (Claude Code, Gemini CLI)
- There are no data dependencies between the parallel phases
- Each parallel worker operates on independent schema modules

Phases NOT marked `[P]` are strictly sequential — the validation gate of phase N must pass before phase N+1 begins.

> **Single-agent runtimes (Cascade/Windsurf/Devin):** Ignore `[P]` markers and execute all phases sequentially.

## Phase 1: Structural Extraction (Worker A)
1. **Trigger**: Initialize the execution of the `schema-specification-engineering` skill.
2. **Context**: Pass the path to the target structural schema files.
3. **Execution**: Allow the worker logic to computationally extract EVERY structural element in the schema without abbreviation.
4. **Validation Gate**: You MUST wait for the Phase 1 execution to fully complete. The agent must successfully create all Feature issues FIRST, capture their IDs, inject them into the Epic markdown, and then create the Epic issue. Query GitHub (`gh issue list --state "open"`) to verify the new Epics and Features exist and are properly interlinked. Do not proceed to Phase 2 until the structural foundation is verified.

## Phase 2 `[P]`: Behavioral Extraction - User Stories (Worker B)
1. **Trigger**: Initialize the execution of the `spec-user-story-engineering` skill.
2. **Context**: Pass the text/path of the target specification document.
3. **Execution**: Allow the worker logic to parse the operational scenarios, extract the OOA/OOD User Stories, and query the GitHub repository to build the Cross-Cutting Matrix linking to the Phase 1 features.
4. **Validation Gate**: Verify that the `user-story` issues have been created in GitHub and that their tasklists successfully render the intersecting `#IssueID`s generated during Phase 1.

## Phase 3 `[P]`: System Interaction Extraction - UML Use Cases (Worker C)
1. **Trigger**: Initialize the execution of the `spec-usecase-engineering` skill.
2. **Context**: Pass the text/path of the target specification document.
3. **Execution**: Allow the worker logic to extract formal UML System Use Cases (Actors, Preconditions, Flow, Postconditions) and map them down to the User Stories from Phase 2 and Features from Phase 1.
4. **Validation Gate**: Verify that the `use-case` issues have been created in GitHub and that the Realization Matrix successfully links back to User Stories and Features.

> **`[P]` Note:** Phases 2 and 3 are marked parallel-capable because Worker C queries GitHub for User Story Issue IDs (created by Worker B) via `gh issue list`. If both are dispatched simultaneously, Worker C will find the User Story issues as soon as Worker B creates them. On single-agent runtimes, execute Phase 2 first, then Phase 3.

## Phase 4: Reconciliation & Automated Verification (Worker D & Coverage Check)
1. **Trigger Backlog Reconciliation**: Run the automated backlog reconciliation script:
   ```bash
   ./skills/spec-orchestrator/scripts/reconcile_backlog.py
   ```
2. **Trigger Model Coverage & UML Conformance Verification**: Run the automated UML compliance and coverage linter tool:
   ```bash
   ./skills/spec-orchestrator/scripts/verify_model_coverage.py [yang_dir] [features_dir]
   ```
   If `yang_dir` and `features_dir` are omitted, the script defaults to `$YANG_DIR` / `$FEATURES_DIR` environment variables, or `<repo_root>/yang` and `<repo_root>/docs/features`.
3. **Execution**: 
   - The backlog script parses frontmatter using PyYAML to prevent block erasure, performs dependency issue hallucination checks, queries GitHub issues, syncs checkbox states in local markdown, and automatically closes completed Epics, User Stories, and Use Cases.
   - The coverage linter parses raw YANG schemas, builds class/sequence/use-case diagram symbol tables from Mermaid blocks, verifies 100% schema coverage within those class diagrams, and validates OMG UML 2.5.1 metamodel conformance and cross-view semantic rules (isolated classes, standard primitives, lifeline aliases, open return arrow assignments, system boundary use cases, undirected actor links, correct extend arrow directionality, etc.).
4. **Validation Gate**: Both scripts must execute successfully with exit code 0. Ensure that all completed tasks have been correctly updated/synced to GitHub, all UML diagrams are validated as fully compliant, and the overall model coverage is verified at exactly 100%.

## Phase 5: Final Reporting
1. Summarize the end-to-end pipeline execution for the user.
2. Provide direct links to the generated Epics, Features, User Stories, and Use Case tracking matrices.
3. Declare the protocol module "Fully Specification-Engineered and Verified."
