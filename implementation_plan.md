# Delete React Configurations from Codebase Rules

We will remove all React-related rules and directory configurations from the pipeline rules (`codebase_rules.json`) to completely clean up the React configuration since the React application is deleted.

## Proposed Changes

### Spec Orchestrator Configuration

#### [MODIFY] [codebase_rules.json](file:///Users/perkunas/jail/digital-pipeline-repo/.pipeline/logical-ui/codebase_rules.json)
- Set `"react"` to `null` in `target_directories`.
- Remove `"react_rules"` block completely.

## Verification Plan

### Automated Tests
- Run the python test suite to verify that removing the React configuration does not break the linter validators:
  ```bash
  PYTHONPATH=skills/spec-orchestrator/parity_auditor/src python3 -m pytest
  ```
- Run the parity auditor locally to verify it executes successfully:
  ```bash
  PYTHONPATH=skills/spec-orchestrator/parity_auditor/src python3 -m parity_auditor.cli --spec-only
  ```
