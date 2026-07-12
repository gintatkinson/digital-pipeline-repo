# Delete All React Logic and References

We will completely clean out all React-specific dead code from the validators, downstream scripts, and rewrite the React linter reliability tests to use Flutter/Dart.

## Proposed Changes

### Spec Orchestrator Validators

#### [MODIFY] [codebase.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/codebase.py)
- Remove the "1. React Web Codebase Compliance" block.
- Remove references to `react_rules` and `react_dir`.

#### [MODIFY] [profile_scoping_validator.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/profile_scoping_validator.py)
- Remove React-specific checks and file lists.

#### [MODIFY] [schema_mapping_validator.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/schema_mapping_validator.py)
- Remove React file collection and React exclusions/rules checks.

### Linter Reliability Tests

#### [MODIFY] [test_linter_reliability.py](file:///Users/perkunas/jail/digital-pipeline-repo/tests/test_linter_reliability.py)
- Update mock `base_config` to remove `react_rules` and `react` targets.
- Rewrite `test_comment_only_bypass`, `test_unrelated_variable_bypass`, and `test_regex_parser_features_and_duplicates` to use Flutter/Dart (`app_flutter/` and `.dart` files) instead of React.

### Downstream Utility Scripts

#### [MODIFY] [verify_downstream_baseline.py](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/verify_downstream_baseline.py)
- Remove the `"react"` platform choice and React verification logic.

#### [MODIFY] [bootstrap_downstream.py](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/bootstrap_downstream.py)
- Remove the `"react"` platform choice and React bootstrap logic.

## Verification Plan

### Automated Tests
- Run the python test suite to verify that the updated tests pass:
  ```bash
  PYTHONPATH=skills/spec-orchestrator/parity_auditor/src python3 -m pytest
  ```
- Run the local linter tool:
  ```bash
  PYTHONPATH=skills/spec-orchestrator/parity_auditor/src python3 -m parity_auditor.cli --spec-only
  ```
