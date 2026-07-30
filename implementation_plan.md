# Implementation Plan

## Architectural Layers
- **Testing Layer**: Adding unit tests for the CLI module (`parity_auditor/src/parity_auditor/cli.py`), specifically the `get_open_feature_issues` function. We will use `pytest` and `unittest.mock.patch` for mocking `subprocess.run`.

## Micro-Tasks

### Task 1: Add `TestGetOpenFeatureIssues` with success and filtering test
- **Target File**: `/Users/perkunas/jail/digital-pipeline-repo/.agents/skills/spec-orchestrator/parity_auditor/tests/test_cli.py`
- **Expected Changes**: 
  - Add a class `TestGetOpenFeatureIssues`.
  - Add `test_returns_filtered_issues_on_success` method. It should mock `subprocess.run` to return a valid JSON payload containing a mix of valid feature issues and issues with titles containing "defect", "bug", "repro", "tooling". It should assert that only the clean feature issues are returned.
- **Driving Test**: This is a test file, so the test itself drives the change. We will ensure the test runs and passes.
- **Verification**: Run `python -m pytest /Users/perkunas/jail/digital-pipeline-repo/.agents/skills/spec-orchestrator/parity_auditor/tests/test_cli.py::TestGetOpenFeatureIssues::test_returns_filtered_issues_on_success`.

### Task 2: Add failure and exception handling tests
- **Target File**: `/Users/perkunas/jail/digital-pipeline-repo/.agents/skills/spec-orchestrator/parity_auditor/tests/test_cli.py`
- **Expected Changes**: 
  - Add `test_returns_none_on_subprocess_failure` (mock `returncode=1`).
  - Add `test_returns_none_on_timeout` (mock side effect `subprocess.TimeoutExpired`).
  - Add `test_returns_none_on_exception` (mock side effect generic `Exception`).
- **Driving Test**: Execution of these new tests.
- **Verification**: Run `python -m pytest /Users/perkunas/jail/digital-pipeline-repo/.agents/skills/spec-orchestrator/parity_auditor/tests/test_cli.py::TestGetOpenFeatureIssues` and ensure all tests pass.
