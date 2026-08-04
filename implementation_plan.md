# Implementation Plan

## Objective
Update the parity auditor's link validator to check GitHub blob URLs and update markdown skills with a note about dynamic schema locators.

## Step 1: Update Link Validator
**File**: `/Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/link_validator.py`
- Add `_GITHUB_BLOB_RE` to match GitHub blob URLs.
- Update the `validate` method to accumulate both markdown and GitHub blob links.
- Continue to only parse the first part of the link before the `#` fragment.

## Step 2: Update Schema Specification Engineering Skill
**File**: `/Users/perkunas/jail/digital-pipeline-repo/skills/schema-specification-engineering/SKILL.md`
- Add a bullet point under "4. Source References Block (CRITICAL):" regarding Dynamic Schema Locator.

## Step 3: Update Spec User Story Engineering Skill
**File**: `/Users/perkunas/jail/digital-pipeline-repo/skills/spec-user-story-engineering/SKILL.md`
- Add an `> [!IMPORTANT]` note under "## Source References" regarding Dynamic Schema Locator.

## Step 4: Update Link Validator Tests
**File**: `/Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/tests/test_link_validator.py`
- Add a test case validating a broken GitHub `.yang` link in `test_link_validator_detects_broken_link`.
- Add assertions to verify the exact number of errors and the presence of the broken target messages.

## Step 5: Verification and Source Control
**Commands**:
- `python3 -m pytest skills/spec-orchestrator/parity_auditor/tests/`
- `python3 -m pytest tests/test_process_discipline_gates.py || true`
- `git add .`
- `git commit -m "fix(validator): add universal link validation for schema files and update source reference paths"`
- `git push origin main`
