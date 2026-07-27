# Implementation Plan - YANG Case/Choice Coverage Linter Fix

This plan covers auditing the model coverage validator for the YANG case/choice coverage gap, filing a formal issue via the adversarial auditor, and resolving it via the debug protocol.

## 1. Context & Goal
The model coverage parity validator (`cli.py`) does not read frontmatter `schema_containers` when validating spec-only model coverage. This causes structural YANG wrapper nodes (like `choice` and `case` nodes: `cartesian`, `ellipsoid`, `velocity`) to be flagged as uncovered gaps because they are forbidden from appearing in UML class diagrams and layout bindings.

We will:
1.  **Audit & File Bug**: Spawn an adversarial auditor subagent to scan `cli.py` under the `Semantic Traceability` pillar and create a GitHub issue on `digital-pipeline-repo`.
2.  **TDD Debug & Fix**: Spawn a debug subagent to:
    *   Add a reproduction test (`test_cli_coverage_choice_case.py`) asserting that mapped frontmatter `schema_containers` nodes are recognized as covered (RED).
    *   Patch `cli.py` to parse frontmatter and include these leaf segments in `spec_elements` (GREEN).
    *   Verify all linter tests pass.
    *   Commit and push changes upstream.

## 2. Proposed Changes

### [MODIFY] [cli.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/cli.py)
Update the specification coverage loop to parse `schema_containers` from the frontmatter of all specs, adding their leaf segments to `spec_elements`.

### [NEW] [test_cli_coverage_choice_case.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/tests/test_cli_coverage_choice_case.py)
Add unit tests verifying that choice/case nodes mapped in frontmatter are correctly marked as covered by the linter.

## 3. Verification Plan
- **Pre-Fix Failure**: Verify the new unit test fails.
- **Post-Fix Success**: Run all 90+ tests to confirm they pass.
- **Downstream Verification**: Run `flutter analyze` and `flutter test` to ensure zero compilation drift.
