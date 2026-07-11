# Implementation Plan: Downstream Code & Skill Back-Propagation

This plan details the changes required to back-propagate features and skills from downstream repositories.

---

## Proposed Changes

### 1. Import `adversarial-code-auditor` Skill
- **Action**: Copy the `./scratch/3dgs-ion/skills/adversarial-code-auditor/` directory containing `SKILL.md` to `./skills/adversarial-code-auditor/`.
- **Target File**: `skills/adversarial-code-auditor/SKILL.md`

### 2. Make React Rules and React Target Directory Optional in Parity Auditor Models
- **Target File**: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/core/models.py`
- **Action**:
  - Update `TargetDirectories` class to define `react` as `Optional[str] = None`.
  - Update `CodebaseRules` class to define `react_rules` as `Optional[ReactRules] = None`.
  - Update `load_from_dict` to check if `react_rules` is present in `data`, defaulting to `None` if missing.

### 3. Add CLI Argument `--allow-missing-specs` in Parity Auditor
- **Target File**: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/cli.py`
- **Action**:
  - Add `--allow-missing-specs` boolean argument to the CLI argument parser.
  - Skip exiting with code 1 if the option is set when there are missing local specification files for open feature issues.
  - Guard accesses to `rules.react_rules` and `rules.target_directories.react` in `cli.py` against `None` values.

### 4. Handle Optional React Rules and React Target Directory in Parity Auditor Validators
- **Target File**: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/codebase.py`
- **Action**: Guard codebase validation logic so it skips React check steps and does not crash when `react_rules` or `target_directories.react` is `None`.
- **Target File**: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/profile_scoping_validator.py`
- **Action**: Guard profile scoping checks to avoid crashing and skip react source files validation when `react_rules` is `None`.
- **Target File**: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/schema_mapping_validator.py`
- **Action**: Guard schema mapping checks to skip react files when `react_rules` is `None`.

### 5. Document Back-propagation of Downstream Changes
- **Target File**: `docs/designs/feat-backprop-downstream-changes.md`
- **Action**: Create a solution walkthrough detailing the modified files (`models.py`, `cli.py`, `codebase.py`, `profile_scoping_validator.py`, `schema_mapping_validator.py`), the new file (`skills/adversarial-code-auditor/SKILL.md`), and the rationale behind making React rules optional and adding `--allow-missing-specs`.

---

## Verification Plan

### Step 1: Run Validation Checks
Run the following validation checks to ensure the rules parsing and validation logic works correctly:
- `./skills/spec-orchestrator/scripts/verify_model_coverage.py schema docs/features`
- `./skills/spec-orchestrator/scripts/reconcile_backlog.py`

### Step 2: Git Verification & Commit
- Verify `git status` shows the correct files are added/modified.
- Create and write the solution walkthrough document at `docs/designs/feat-backprop-downstream-changes.md`.
- Commit all changes to the active branch `feat/backprop-application-changes` with the commit message:
  `feat: import adversarial-code-auditor and make react rules optional in parity auditor` and then commit the walkthrough document.
- Push the branch to `origin`.
- Confirm that `git diff origin/feat/backprop-application-changes` is empty.

