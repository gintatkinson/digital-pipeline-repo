# Clean out all React

We will completely remove all React-related profiles and validation configurations from the repository.

## Proposed Changes

### Spec Orchestrator Configuration

#### [DELETE] [react.md](file:///Users/perkunas/jail/digital-pipeline-repo/.pipeline/profiles/react.md)
- Delete the React profile document.

#### [MODIFY] [docs.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/docs.py)
- Remove `".pipeline/profiles/react.md"` from `doc_files` validation list.

## Verification Plan

### Automated Tests
- Run the python test suite to verify that removing the React profile and updating the docs validator does not break the test suite:
  ```bash
  PYTHONPATH=skills/spec-orchestrator/parity_auditor/src python3 -m pytest
  ```
- Run the parity auditor locally to verify it executes successfully:
  ```bash
  PYTHONPATH=skills/spec-orchestrator/parity_auditor/src python3 -m parity_auditor.cli --spec-only
  ```
