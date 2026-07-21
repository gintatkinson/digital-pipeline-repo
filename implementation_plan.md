# Implementation Plan - Issue #74 Backlog Issue Verification and Body Sync

This plan details the steps to modify the specification engineering guides to prevent stubs in the issue tracker by using `--body-file` and performing immediate body synchronization and post-creation checks.

## User Review Required

> [!IMPORTANT]
> **Plan Approval**: As required by project guidelines, this plan must be approved before executing codebase modifications or git operations.

## Proposed Changes

### Phase 1: Codebase Modifications (Spec Engineering Skills)

1. **File**: `skills/schema-specification-engineering/SKILL.md`
   - **Changes in Step 5.4**:
     - Mandate registering Features using `gh issue create --body-file <local-md-file>`.
     - Mandate executing `gh issue edit <ID> --body-file <local-md-file>` immediately after replacing `#[IssueID]` with the resolved ID in the local file.
     - Mandate running the post-creation body verification check:
       `gh issue view <ID> --json body | python3 -c "import sys,json; b=json.load(sys.stdin)['body']; assert 'Source References' in b or 'References' in b, 'Body is a stub'"`
       and retry/halt if it fails.
   - **Changes in Step 5.6**:
     - Mandate registering Epics using `gh issue create --body-file <local-md-file>`.
     - Mandate executing `gh issue edit <ID> --body-file <local-md-file>` immediately after placeholder resolution.
     - Mandate running the post-creation body verification check.

2. **File**: `skills/spec-user-story-engineering/SKILL.md`
   - **Changes in Step 5.4**:
     - Mandate registering User Stories using `gh issue create --body-file <local-md-file>`.
     - Mandate executing `gh issue edit <ID> --body-file <local-md-file>` immediately after placeholder resolution.
     - Mandate running the post-creation body verification check.

3. **File**: `skills/spec-usecase-engineering/SKILL.md`
   - **Changes in Step 5.4**:
     - Mandate registering Use Cases using `gh issue create --body-file <local-md-file>`.
     - Mandate executing `gh issue edit <ID> --body-file <local-md-file>` immediately after placeholder resolution.
     - Mandate running the post-creation body verification check.

### Phase 2: Verification

1. Run the local linter checks:
   ```bash
   python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
   ```

### Phase 3: Remote Synchronization

1. Stage and commit changes with message:
   `fix: mandate issue body-file creation, immediate edit sync, and post-creation verification in spec skills`
2. Push changes directly to branch `feat/58-63-linter-fixes`.
3. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
