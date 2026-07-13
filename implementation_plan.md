# Implementation Plan: Implement Logical UI Validator

Implement the `LogicalUiValidator` validation checks and integrate it into the `parity_auditor` CLI.

## Proposed Changes

### [CREATE] [skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/logical_ui_validator.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/logical_ui_validator.py)
- Create the file implementing the `LogicalUiValidator` validation checks.
- Load `logical-layout.json` from `.pipeline/logical-ui/logical-layout.json` (or look under `app_flutter/assets/logical-layout.json` or fallback).
- Traverse the JSON layout structurally to extract all valid component types and container IDs.
- Scan feature files in `docs/features/` to extract `Target LUI Component` and `Target Layout Container ID` from `## 5. Logical UI & Layout Bindings`.
- Validate that components and container IDs (if not `N/A`) exist in the allowed list or `logical-layout.json`.
- Implement geodetic coordinate visual component mapping check.

### [MODIFY] [skills/spec-orchestrator/parity_auditor/src/parity_auditor/cli.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/cli.py)
- Import `LogicalUiValidator` from `.validators.logical_ui_validator`.
- Instantiate and run `logical_ui_validator` in `_main_impl`.
- Append `logical_ui_errors` to the final `all_errors` list.

### [MODIFY] [tests/test_linter_reliability.py](file:///Users/perkunas/jail/digital-pipeline-repo/tests/test_linter_reliability.py)
- Add a test function `test_logical_ui_validator` to verify the functionality of `LogicalUiValidator` under various conditions.

## Verification Plan
- Run the downstream verifier check:
  ```bash
  python3 scripts/verify_downstream_baseline.py app_flutter
  ```
