# Implementation Plan: Integrate Intermediate Validation Loops in Specification Engineering Skills

This plan details the updates to enforce a mandatory local validation gate using the `verify_model_coverage.py` script across all specification extraction phases.

## Proposed Changes

### [skills/spec-orchestrator]

#### [MODIFY] [SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/SKILL.md)
* In Phase 1, Phase 2, and Phase 3, add the requirement for the worker subagents to run the local validation check (`./skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only --allow-missing-specs`) before committing, pushing, or creating issues.
* Mandate fixing all validation errors until the linter passes with exit code 0.

### [skills/schema-specification-engineering]

#### [MODIFY] [SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/schema-specification-engineering/SKILL.md)
* Insert a new section `## Step 5: Local Validation & Backlog Synchronization` at line 271 (before tracker label bootstrapping).
* Define Step 1 as a mandatory local validation gate using `./skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only --allow-missing-specs`.
* Require parsing errors, correcting generated epic and feature files, and re-running until the linter passes.
* Adjust numbering of subsequent steps (Tracker Label Bootstrapping, Duplicate Detection, etc.) to follow this first step.

### [skills/spec-user-story-engineering]

#### [MODIFY] [SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-user-story-engineering/SKILL.md)
* Under `## Step 5: Zero-Fault Backlog Synchronization`, modify step 1 to enforce the mandatory validation gate (`./skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only --allow-missing-specs`) and correction loop before committing or pushing user stories.

### [skills/spec-usecase-engineering]

#### [MODIFY] [SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-usecase-engineering/SKILL.md)
* Under `## Step 5: Zero-Fault Backlog Synchronization`, modify step 1 to enforce the mandatory validation gate (`./skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only --allow-missing-specs`) and correction loop before committing or pushing use cases.

---

## Verification Plan

### Automated Verification
* Run the verification command:
  ```bash
  python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
  ```
* Ensure it returns an exit code of 0.
* Inspect `git diff` to verify only the requested changes have been made.
