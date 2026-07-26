# Implementation Plan: Enforce TabbedContainer Constraints & Revert Layout

This plan details the steps to find the validation gap using the **`adversarial-code-auditor`** first, file the bug, and then execute the layout de-contamination and linter fix under the **`debug-protocol`**.

---

## 1. Skill Matrix

To execute this plan, we will utilize the following skills:
1.  **`adversarial-code-auditor`** (`.agents/skills/adversarial-code-auditor/SKILL.md`): Used in Phase 1 to audit the validator logic, identify the gap where `TabbedContainer` children type checks are missing, and file a bug issue.
2.  **`debug-protocol`** (`.agents/skills/debug-protocol/SKILL.md`): Used in Phase 2 to guide the subagent's systematic, step-by-step patch of the linter (`logical_ui_validator.py`) to fix the filed bug.
3.  **`schema-specification-engineering`** (`skills/schema-specification-engineering/SKILL.md`): Used in Phase 3 to update the generator guidelines.
4.  **`karpathy-skill`** (`.agents/skills/karpathy-skill/SKILL.md`): Enforces strict engineering guardrails.

---

## 2. Proposed Changes

### Phase 1: Adversarial Code Audit (Find the Bugs)
We will spawn an **Adversarial Auditor subagent** using the `adversarial-code-auditor` skill:
*   **Audit Target**: Check `logical_ui_validator.py` against the constraint that `TabbedContainer` children in `logical-layout.json` are hardcoded to `TableView` components in the application code.
*   **Expected Finding**: Identify that the validator permits non-`TableView` components (like `PropertyGrid`/`properties_view`) inside `TabbedContainer` without raising a compliance error.
*   **Action**: File this bug issue (e.g. "Validator fails to enforce TableView type constraints on TabbedContainer children") upstream on `digital-pipeline-repo` using the `gh` CLI.

### Phase 2: Update Validator Constraints (logical_ui_validator.py)
We will spawn an **Upstream Debugging Specialist subagent** to resolve the filed bug:
*   **Target File**:
    *   [logical_ui_validator.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/logical_ui_validator.py)
*   **Changes**:
    *   Add a validation check that scans the `logical-layout.json` tree. For every `TabbedContainer` component, assert that all of its `children` have a `"type"` equal to `"TableView"`.
    *   If any non-`TableView` child (like `PropertyGrid` or `PropertiesPanel`) is found in the children of a `TabbedContainer`, return a compliance error.
    *   Verify the fix against unit tests and close the filed issue.

### Phase 3: Update Generator Mapping Guidelines (SKILL.md)
*   **Target File**:
    *   [SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/schema-specification-engineering/SKILL.md)
*   **Changes**:
    *   Add a rule stating that since the layout does not instantiate a standalone properties tab inside the `TabbedContainer`, all geodetic and geolocation attributes must map directly to the instantiated details grid: `TableView` component with ID `components_table`.
    *   Explicitly forbid mapping these attributes to trees, topology, or uninstantiated components.

---

## 3. Verification Plan

### 3.1 Python Unit Tests
*   Run `PYTHONPATH=src python3 -m pytest tests/` in the `parity_auditor` directory and ensure all 32 tests pass.

### 3.2 Compilation & Packaging Build
*   Run the compliance build to compile the Flutter application and create the release archive:
    ```bash
    python3 scripts/verify_downstream_baseline.py app_flutter
    ```
*   Verify that `app_flutter_release.zip` is successfully created at the repository root.

### 3.3 Synchronization Check
*   Stage, commit, and push the validator and generator updates to `origin/main`.
*   Verify that `git diff origin/main` is empty.
