# Implementation Plan - Issue Frontmatter Resolution Variations

This plan details the steps to modify the frontmatter file resolve logic in `reconcile_backlog.py` and verify it with a new regression unit test in `tests/test_linter_reliability.py`.

## User Review Required

> [!IMPORTANT]
> **Plan Approval**: As required by project guidelines, this plan must be approved before executing codebase modifications or git operations.

## Proposed Changes

### Phase 1: Codebase Modification
1. **File**: `skills/spec-orchestrator/scripts/reconcile_backlog.py`
2. **Change**: Locate `resolve_issue_ids_in_file` (approx line 393). Replace:
   ```python
   if not title and "issue_id:" in line:
       title = extract_title(filepath)
   ```
   with:
   ```python
   if (not title or not title.strip()) and re.search(r'issue[\s\-_]*id\s*:', line, re.IGNORECASE):
       title = extract_title(filepath)
   ```

### Phase 2: Regression Unit Test
1. **File**: `tests/test_linter_reliability.py`
2. **Change**: Append a new unit test function named `test_reconcile_backlog_frontmatter_resolution_variations(tmp_path, base_config)` at the end of the file.
3. **Details**:
   The test will:
   - Create a temporary workspace layout with a features directory.
   - Generate test files containing frontmatter variations:
     - `issue-id: #[IssueID]`
     - `issueid: #[IssueID]`
     - `Issue-Id: #[IssueID]`
     - `issue_id: #[IssueID]`
   - Call `resolve_issue_ids_in_file` assuming `feature_titles={'geolocation': 42}`.
   - Assert that each variation is correctly resolved to `#42`.

### Phase 3: Verification & Execution
1. Run the test suite:
   ```bash
   python3 -m pytest tests/test_linter_reliability.py
   ```
2. Run model coverage checking script:
   ```bash
   python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
   ```
3. Run the backlog reconciliation script:
   ```bash
   python3 skills/spec-orchestrator/scripts/reconcile_backlog.py
   ```

### Phase 4: Remote Synchronization
1. Stage and commit changes with message:
   `fix: support frontmatter issue-id variations and add regression test`
2. Push changes to remote tracking branch `feat/58-63-linter-fixes`.
3. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
