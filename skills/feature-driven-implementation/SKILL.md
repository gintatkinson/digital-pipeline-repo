<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

---
name: feature-driven-implementation
description: "Implements Agile features using serial, subagent-driven, TDD-disciplined execution with two-stage review gates. Use when you need to implement a feature from a GitHub backlog with micro-task decomposition, RED-GREEN-REFACTOR cycles, and automated Epic closure."
compatibility: "Requires git and configured issue tracker. Works with major agent orchestrators."
metadata:
  risk: low
  source: custom
  version: "2.0"
---

# Feature-Driven Autonomous Delivery & Closure

Use this skill to execute the end-to-end implementation lifecycle for prioritized Agile features and ensure complete automated closure of feature issues, walkthrough updates, and parent Epics.

This skill integrates subagent-driven development, TDD execution discipline, two-stage review gates, micro-task decomposition, systematic debugging, and verification-before-completion — ensuring that agents cannot drift, falsely report success, or skip quality gates.

## Core Mandates

1. **Serial Execution:** Strictly implement **one feature at a time**. Do not start feature N+1 until feature N is completely verified, merged, documented, and closed.
2. **The Grill Approval:** Create an implementation plan and obtain explicit human approval BEFORE modifying any source files.
3. **Traceability:** All closed issues MUST have a closing comment referencing the relative path or GitHub URL of the committed solution walkthrough.
4. **Agentic Epic Closure:** When all constituent features of an Epic are closed, the agent must check off the items in the local Epic markdown, update the Epic issue's body on GitHub, and close the Epic issue itself.
5. **No Browser Automation:** All web UI verification must be performed manually unless the project explicitly uses automated E2E testing. Do not use automated browser subagents or headless testing for UI verification unless the project's test suite mandates it.
6. **Issue Tracker as Source of Truth:** Do not rely on local files or checklist documentation for feature definitions or backlog status as they may be contaminated or contain broken links. Always query the official issue tracker provider as the canonical source of truth.
7. **Cumulative Walkthroughs & Document Integrity:** When writing or updating living artifacts (such as implementation plans, task lists, and verification walkthroughs), you MUST NOT perform destructive overwrites. Always read the existing file first. Append or merge new details so the historical record remains fully intact.
8. **Validation Isolation & Separate Subagent Audit:** The primary agent MUST NOT self-verify database changes or documentation links without a strict checklist. Dispatch a separate **Validator Subagent** if available. In single-agent contexts, perform a strict, isolated self-audit (Step 4.4 fallback) verifying that every structural identifier and link target referenced in the walkthrough resolves and exists in the unified data repository.
9. **Test-Driven Development (TDD):** All implementation MUST follow the RED-GREEN-REFACTOR cycle. Write a failing test FIRST, verify it fails, write minimal code to pass, verify it passes, then refactor. Code written before its corresponding test must be deleted and re-implemented after the test.
10. **Micro-Task Decomposition:** Break every approved implementation plan into micro-tasks of 2-5 minutes each. Each micro-task must have: exact file paths, expected changes, a driving test, and a verification step. Never execute more than one micro-task without verification.
11. **Subagent-Driven Development:** Each micro-task SHOULD be dispatched to a fresh subagent with isolated context. The coordinator provides only the task text, relevant file contents, and project conventions — never the full session history. This prevents context drift and confirmation bias. See Step 3 for runtime-specific dispatch instructions.
12. **Two-Stage Review:** After each micro-task's implementation, two reviews MUST occur in order: (1) **Spec Compliance Review** — does the code match the approved plan and RFC/spec requirements? (2) **Code Quality Review** — is the code well-structured, typed, tested, and maintainable? Both must pass before proceeding to the next task.
13. **Verification-Before-Completion:** Before declaring any task, micro-task, or feature complete, the agent MUST provide concrete proof of correctness (raw test output, build output, or explicit file-content verification). Assertions like "it works" or "tests pass" without pasted evidence are forbidden.
14. **Inter-Task Code Review:** After each micro-task, diff the changes against the approved plan. Log deviations. Critical deviations block progress until resolved with the user.

---

## Step-by-Step Workflow

### Step 1: Backlog & Dependency Mapping
1. **Read the project constitution** (`.pipeline/constitution.md`) if it exists. This is the **functional layer** — domain rules, agent behavior, universal quality gates.
2. **Read the implementation profile** (`.pipeline/profiles/<target-platform>.md`) for the target platform. This provides platform-specific coding standards, testing mandates, build commands, and deployment config. If no profile exists for the target platform, halt and prompt the human to create one using the `project-constitution` skill.
3. Analyze `docs/epics/` and `docs/features/` to determine feature dependencies.
4. Map the backlog queue in order of base dependencies first.
5. Create a local tracking file (e.g., `task.md`) to manage current tasks.

### Step 1.5: Tech Stack Research (Optional)

If the feature involves unfamiliar frameworks, rapidly-evolving libraries, or new platform capabilities:

1. **Identify research targets:** What specific APIs, libraries, or patterns does this feature require?
2. **Check versions:** Verify the installed/pinned versions of relevant dependencies. Note any breaking changes between the project's current version and the latest.
3. **Document findings:** Create `research.md` on the feature branch with:
   - Framework/library versions being used
   - Relevant API documentation links
   - Known gotchas, migration notes, or deprecation warnings
   - Patterns recommended by official docs
4. **Feed into The Grill:** Reference `research.md` during the plan review to ensure the implementation plan accounts for framework realities.

> Skip this step if the feature uses well-established patterns already documented in the codebase.

### Step 2: Checkout & Plan Review ("The Grill")
1. Checkout a dedicated feature branch from the default branch (e.g., `main` or `master`) using the environment-configured checkout command (e.g., `git checkout -b feat/<N>-<short-description>`):
2. **Platform Scoping:** The feature spec is platform-independent (functional). Apply the target platform from the implementation profile (`.pipeline/profiles/<platform>.md`, loaded in Step 1) to translate functional requirements into platform-specific design decisions. This is where framework components, UI patterns, and test frameworks are chosen — not during spec generation.
3. Create/update `implementation_plan.md` outlining a **complete vertical slice** for the target platform:
   - **Persistence Layer (Test Data):** Specific updates to the unified data persistence repository loaded with test data, including edge cases.
   - **Transformation Layer:** Type definitions, validation schemas, and hooks to wire the transformation logic into the application flow.
   - **Interface Layer:** Platform-specific interface component choices, layout changes, styles, and data bindings to render the new attributes.
   - **Test Plan (TDD):** For each layer, specify the failing tests that will be written BEFORE the implementation code, using the test framework from the implementation profile. Include E2E test specifications where applicable.
   - **Verification Plan:** Detailed manual validation instructions, compiler checks, and tests.
4. **Micro-Task Breakdown:** Decompose the plan into sequential micro-tasks (2-5 min each). Each task must specify:
   - Target file(s) and line ranges
   - What changes
   - The failing test that drives the change
   - How to verify completion
5. Present the plan to the user and wait for explicit approval. Enter "The Grill" — interactive review to challenge design choices, clarify ambiguities, and validate spec/RFC compliance.

### Step 3: Execution & Build (Subagent-Driven TDD Vertical Slice)

Execution follows a **per-task subagent dispatch loop**. The coordinator reads the plan once, extracts all micro-tasks, then dispatches a fresh implementer per task with two-stage review after each.

#### 3.1 Pre-Execution
1. **No Handover Trust:** Never assume previous phases or turns implemented a portion of the code correctly based on summaries. Explicitly open and check the source code files in all relevant directories.
2. **Extract All Tasks:** Read the approved plan. Extract every micro-task with its full text, target files, driving test, and verification step. Create a tracking list (e.g., `task.md` or TodoWrite).

#### 3.2 Per-Task Dispatch Loop

For each micro-task in sequence:

**A. Dispatch Implementer (Fresh Context)**

The implementer receives ONLY:
- The micro-task text (exact scope, target files, expected changes)
- Relevant file contents (read and provided by the coordinator)
- Project conventions (TDD mandate, typing rules, drill-down navigation rule, etc.)
- The driving test specification

The implementer MUST NOT receive the full session history or prior task context.

**Orchestration-Specific Dispatch:**

Configure the dispatch method dynamically based on the current agent orchestrator environment. For example:
- **Native Context-Isolated Agents**: Use native tool-based subagent calls with isolated task payloads.
- **Standard CLI/API Clients**: Execute a dedicated CLI client command or invoke subagent tool interfaces with curated context payloads.
- **Manual/Semi-Autonomous Context Reset**: If operating in environments without native subagent isolation, manually reset context by explicitly reading target files from disk and prefixing instructions to ignore prior task history.

**B. Implementer Executes TDD Cycle**
- **RED:** Write the failing test first. Run it. Confirm it fails with the expected error.
- **GREEN:** Write the minimal code to make the test pass. Run it. Confirm it passes.
- **REFACTOR:** Clean up the code while keeping tests green. Run tests again.
- **COMMIT:** Commit the passing micro-task with a descriptive message.
- **SELF-REVIEW:** Implementer reviews own changes before handing back.

**C. Handle Implementer Status**
- **DONE:** Proceed to two-stage review (Step 3.3).
- **DONE_WITH_CONCERNS:** Read concerns. If correctness/scope issue, address before review. If observational, note and proceed.
- **NEEDS_CONTEXT:** Coordinator provides missing context and re-dispatches.
- **BLOCKED:** Assess blocker: (1) context problem → provide more context, (2) task too complex → break into smaller pieces, (3) plan is wrong → escalate to human via "The Grill."

#### 3.3 Two-Stage Review Gate

After each micro-task's implementation, two reviews MUST occur **in this order**:

**Stage 1: Spec Compliance Review**
- Does the code match the approved plan exactly?
- Does it comply with the RFC/spec requirements from `docs/features/` and `docs/user-stories/`?
- Is anything missing from the spec? Is anything extra (not requested)?
- **If issues found:** Implementer fixes → re-review. Do NOT proceed to Stage 2 until Stage 1 passes.

**Stage 2: Code Quality Review**
- Is the code well-structured and idiomatic?
- Are types correct and strict (no `any` unless justified)?
- Are tests meaningful (not smoke-only)?
- Does it follow project conventions (drill-down navigation, domain-driven design, etc.)?
- **If issues found:** Implementer fixes → re-review. Do NOT proceed to next task until Stage 2 passes.

**Orchestration-Specific Review:**

Configure the review method dynamically based on the current agent orchestrator environment. For example:
- **Multi-Agent Environments**: Dispatch separate spec compliance and code quality reviewer subagents with the diff and specification documents.
- **Single-Agent Fallback**: The coordinator agent performs both reviews as explicit, sequential self-audit steps: (1) re-read the spec, diff the changes, check compliance point-by-point, and (2) re-read the code, checking design tokens, standards, and conventions. Document all findings in the local tracking checklist before proceeding.

#### 3.4 Data Flow Slicing Order
- **1. Persistence Layer:** Write test for expected data shape or schema -> implement data persistence logic.
- **2. Transformation Layer:** Write test for parsing, validation, or state logic -> implement transformations.
- **3. Interface Layer:** Write test for user interface presentation -> implement components or layout bindings.

#### 3.5 Inter-Task Continuation
- After both reviews pass, mark task complete in tracking list.
- **Do not pause to ask "Should I continue?"** — execute all tasks continuously unless BLOCKED.
- If deviation from plan is critical (architectural change, missing spec compliance), STOP and return to "The Grill."

#### 3.6 Code Presence Verification
Before proceeding to Step 4, perform explicit grep or file-reading checks of all modified files to guarantee that all implementation code actually exists in the files. Do not trust summaries.

#### 3.7 Invariants
- Maintain strong typing, domain-driven design conventions, and strict schema compliance.
- Ensure no linting, type-checking, or compilation errors at any point.
- Never dispatch multiple implementer subagents in parallel on the same feature (conflicts).
- Never start code quality review before spec compliance is approved (wrong order).
- Never skip the re-review loop (reviewer found issues = implementer fixes = review again).

### Step 3.8: Systematic Debugging (When Tests Fail Unexpectedly)

If a test fails with an unexpected error during Step 3, follow the 4-phase debugging protocol:

1. **Reproduce:** Isolate the failure. Run the single failing test in isolation. Record exact error output.
2. **Diagnose:** Trace the root cause. Do NOT guess — read the stack trace, add targeted logging, check variable state. Identify the exact line and condition causing failure.
3. **Fix:** Apply the minimal upstream fix. Prefer single-line changes. Do not add workarounds downstream. Do not "fix" by weakening or deleting the test.
4. **Verify:** Run the full test suite (not just the fixed test) to confirm no regressions. Only proceed when all tests pass.

### Step 4: Verification & Testing (Human & Assertion-Based Verification)
1. **Assertion-Based Automation:** When writing or updating widget/unit tests, do not rely on basic smoke tests that only verify the app launches. Add explicit assertions that query the rendering tree for the presence of the new fields or text tokens.
2. Run local tests or build checks using the environment-configured commands.
3. **Evidence of Completion:** Paste actual raw test output / build output as proof. Do not summarize — show the raw output.
4. Provide **precise, step-by-step human manual testing instructions** in the verification section. The instructions must guide the user on exactly what commands/actions to run, which interface element to navigate to, what actions to perform, and what visual output to inspect to verify that the implementation is 100% correct.
5. **Independent Subagent Validation Check (or Single-Agent Fallback Self-Audit):**
   - **Multi-Agent Mode:** Dispatch a separate **Validator Subagent** to read the draft walkthrough and cross-reference every referenced structural identifier and link target. The Validator subagent must independently locate these elements in the unified data repository to confirm they exist and match the interface navigation targets. Fail the validation step if there is any mismatch.
   - **Single-Agent Fallback:** The agent must step out of the implementation context and systematically audit its own draft walkthrough. Perform exact search lookups to verify that every single structural identifier and link target referenced in the walkthrough exists verbatim in the data repository. Document the results of this check explicitly before requesting user approval.
6. Apply any feedback iteratively on the feature branch.

### Step 5: Release & Closure (CRITICAL)
1. Merge the feature branch into the default branch (e.g. `main` or `master`) using the configured merge command template.
2. Create or update a cumulative solution walkthrough document under the configured design directory (e.g. `docs/designs/feat-<Issue_Number>-solution.md`) summarizing the changes, testing, and validations. This document must include a Code Realization Table that explicitly maps each feature and its attributes to the implemented source files, classes, methods, and functions. Do not delete or overwrite sections for previously implemented sub-features or related components. Ensure the document is a cumulative record of all changes.
   > [!IMPORTANT]
   > **DO NOT USE THE FEATURE INDEX NUMBER** in the solution filename if the tracker issue number is different. The solution filename MUST strictly use the tracker issue number (e.g., `feat-<Issue_Number>-solution.md`).
   >
   > **ZERO-TRUST COLLISION CHECK:** Before updating or creating this file, search the repository and history for the target filename to check its existing content. If it exists, read it first and append/merge the new changes rather than overwriting. If there is a filename mismatch or conflict, alert the user and resolve the naming conflict immediately.
3. Commit and push the solution document using the configured commit command template.
4. Close the feature issue on the active issue tracker provider, embedding a comment pointing to the committed solution document, dynamically constructing the URL using `meta.upstream_repository` from configuration.
5. Update the local parent Epic checklist:
   - Mark the completed feature as completed (`[x]`).
   - Commit and push the updated Epic checklist file.

### Step 6: Agentic Epic Closure (CRITICAL)
1. Inspect the local Epic checklist.
2. If **all** features listed in the Epic checklist are checked off (`[x]`):
   - Update the Epic issue body on the active tracker provider with the completed task list.
   - Close the Epic issue on the active tracker provider, embedding a comment indicating successful completion.
3. Delete the feature branch locally and remotely using the configured branch cleanup commands.
