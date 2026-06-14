# Handoff: Spec-Engineering Pipeline Verification & Bug Resolution

This document serves as the canonical handoff for the incoming agent. It explains the exact state of the repositories, the outstanding bugs in the automated specification generation pipeline, and the step-by-step instructions to resume and complete the task.

## 1. Context & Workspaces

There are two primary workspaces:
1. **Pipeline Tooling Workspace**: `/Users/perkunas/digital-pipeline-repo`
   - **Status**: Clean. Connected to `origin/master` (`https://github.com/gintatkinson/digital-pipeline-repo.git`).
   - **Purpose**: Contains the linter rules/checklists, scripts (`verify_model_coverage.py`), and the worker skill configurations under `skills/`.
2. **Test Workspace**: `/Users/perkunas/jail/digipipe-tst17`
   - **Status**: Empty local working directory (except for `.git`). Connected to remote `origin/main` (`https://github.com/gintatkinson/digipipe-tst17.git`).
   - **Current Git Status**: Files are staged for deletion.
   - **Purpose**: Used for testing the automated specification generation pipeline.

---

## 2. The Outstanding Bugs

The previous attempt to run the pipeline failed because the automated worker skills (`schema-specification-engineering`, `spec-user-story-engineering`, `spec-usecase-engineering`) produced specifications that violated the linter's validation gates. Rather than fixing the templates/prompts, the previous agent manually edited the generated specifications.

The exact mismatches (bugs) that must be resolved in the **worker skill prompts** (located under `/Users/perkunas/digital-pipeline-repo/skills/`) are:

1. **Epic Header Naming**:
   - **Issue**: Worker A generates numbered headers (e.g. `## 3. System-Level UML Class Diagram`).
   - **Linter Rule**: Expects unnumbered headers exactly matching `## System-Level UML Class Diagram` and `## System State Machine Diagram`.
2. **UML Diagrams**:
   - **Issue**: Worker B and Worker C fail to generate compliant sequence and state machine diagrams. They also use invalid Mermaid dotted link syntax (`-.->|label|` or `-.-->|label|`).
   - **Linter Rule**: Strict requirement for valid UML sequence/state diagrams. Dotted/dashed link labels must use the `-. label .->` syntax to render correctly on GitHub.
3. **Use Case Alternate Flows**:
   - **Issue**: Worker C does not generate use cases with at least two detailed Alternate/Exception flows containing at least two numbered steps each.
   - **Linter Rule**: Enforces at least 2 flows of 2+ steps.
4. **Feature UI Requirements**:
   - **Issue**: Worker A names the section `## 2. Client Integration and UI Rendering` instead of `## Functional UI Requirements`, and lacks a copy-pasteable JSON payload shape.
   - **Linter Rule**: Mandates the header `## Functional UI Requirements` and a code block containing a valid JSON payload example.
5. **Realization Matrix Links**:
   - **Issue**: Worker C generates relative links.
   - **Linter Rule**: Requires absolute GitHub URLs pointing to the current branch to prevent 404 links on GitHub issue pages.

---

## 3. Step-by-Step Instructions for the Next Agent

### Step 1: Restore the Test Environment
1. In `/Users/perkunas/jail/digipipe-tst17`, discard the staged deletions of tooling files:
   - Run `git restore --staged rules/ skills/ yang/` to unstage the tooling and schema directories.
   - Run `git restore rules/ skills/ yang/` to restore them on disk.
   - **Do NOT restore any files in `docs/`** (Epics, Features, User Stories, Use Cases). We must ensure the local `docs/` directory is completely clean before starting the dry run.
2. Synchronize the `rules/` and `skills/` directories in `/Users/perkunas/jail/digipipe-tst17` with the latest code from `/Users/perkunas/digital-pipeline-repo`.

### Step 2: Run the Automated Generation
1. Inside `/Users/perkunas/jail/digipipe-tst17/`, run the orchestrator / workers to generate the geographic location specifications from scratch.
2. Ensure you have the official `ietf-geo-location@2022-02-11.yang` schema present in the `yang/` directory.

### Step 3: Run the Linter and Capture Failures
1. Run the linter script against the newly generated outputs:
   ```bash
   python3 skills/spec-orchestrator/scripts/verify_model_coverage.py yang docs/features
   ```
2. Note all validation failures.

### Step 4: Repair the Skill Prompts/Templates
1. Modify the skill definition files in the pipeline repo `/Users/perkunas/digital-pipeline-repo/skills/` (such as `schema-specification-engineering/SKILL.md`, `spec-user-story-engineering/SKILL.md`, `spec-usecase-engineering/SKILL.md`) to explicitly instruct the LLM to follow the linter's exact header formats, Mermaid syntax rules, use case flow counts, UI requirements, and absolute URL naming conventions.
2. Do **NOT** manually edit the output markdown files in `docs/`.

### Step 5: Verify and Push
1. Re-run the generation pipeline and verify that `verify_model_coverage.py` passes with **exit code 0** and 100% coverage.
2. Once verified, push the tooling/linter/skill fixes to `digital-pipeline-repo` (`master` branch) and the auto-generated, clean specs to `digipipe-tst17` (`main` branch).
