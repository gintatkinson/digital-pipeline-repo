# Implementation Plan: Hardening Updates in Specification Engineering Skills

This plan details the updates to harden specification engineering processes and validation gates.

## Proposed Changes

### 1. Update `skills/spec-orchestrator/SKILL.md`
- **Target File**: [skills/spec-orchestrator/SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/SKILL.md)
- **Change**: Under Phase 1, Phase 2, and Phase 3, update Step 3 ("Wait & Verify") to add instructions for the Coordinator to:
  a. Query the git diff to identify the generated file paths.
  b. Run a file read check (`view_file`) on a random sample (at least 1-2 files) of the newly generated files to verify formatting compliance (such as BDD syntax, UML diagrams format).
  c. Run the linter locally over the newly added files to double-check that the validation gate is fully satisfied.

### 2. Update `skills/schema-specification-engineering/SKILL.md`
- **Target File**: [skills/schema-specification-engineering/SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/schema-specification-engineering/SKILL.md)
- **Change**: Under Step 2 (Isolated Feature Extraction), sub-section "3. Execution within Subagent Context", insert the mandatory rule:
  - "Before writing the file, you MUST output a structured compliance table checking for standard UML primitives, return multiplicities, no curly braces in Mermaid, and no isolated classes."

### 3. Update `skills/spec-user-story-engineering/SKILL.md`
- **Target File**: [skills/spec-user-story-engineering/SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-user-story-engineering/SKILL.md)
- **Change**: Under Step 2 (Isolated User Story Modeling), sub-section "3. Execution within Subagent Context", insert the mandatory rule:
  - "Before writing the file, you MUST output a structured compliance table checking for lifeline aliasing (e.g. 'actorName : Classifier'), open return arrows ('-->'), return value assignment signatures (no method call format), and Given-When-Then BDD scenarios."

### 4. Update `skills/spec-usecase-engineering/SKILL.md`
- **Target File**: [skills/spec-usecase-engineering/SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-usecase-engineering/SKILL.md)
- **Change**: Under Step 2 (Isolated Use Case Modeling), sub-section "3. Execution within Subagent Context", insert the mandatory rule:
  - "Before writing the file, you MUST output a structured compliance table checking for system boundary subgraphs, external actors, and complete realization matrices."

---

## Verification Plan

### Automated Verification
- Run the verification script locally to ensure compliance:
  ```bash
  python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
  ```
- Verify the exit code is 0.
- Perform a final `git diff` review to verify the accuracy and surgical nature of all modifications.
