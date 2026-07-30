# Implementation Plan - Issues: #271 and #272 (UML Validation and Parser Colon Rules)

This plan outlines the surgical changes to enforce backticks around class names containing colons in Mermaid class diagrams, restrict the UML validator block start pattern to reject raw colons, strip nested namespace prefixes in schema container paths to prevent false-positive errors, update codebase rules, and verify the changes via automated tests.

---

## 1. Proposed Code Changes

### Target File: `rules/platform-independence.md`
- Update the "Mermaid Class Naming Rules" to explicitly forbid colons in unbackticked class names and require backticks (e.g. `` class `Nw:network` ``).

### Target File: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/uml.py`
- Restrict the `is_block_start` regex (around line 671) to reject raw colons: change `[a-zA-Z0-9_\-.:]+` to `[a-zA-Z0-9_\-.]+`.
- Refactor the segment-level namespace prefix stripping logic inside `validate` (around line 865) to strip the prefix per-segment:
  ```python
                    seg_clean = re.sub(r"^[^:]+:", "", seg)
                    seg_parts = re.split(r'[-_]', seg_clean)
  ```

### Target File: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/parsers/mermaid.py`
- Require backticks around class names containing colons by replacing `[a-zA-Z0-9_\-.:]+` with `[a-zA-Z0-9_\-.]+` in:
  - `is_relationship` regex (around line 359)
  - `class_block_match` regex (around line 401)
  - `class_decl_match` regex (around line 416)
  - `rel_match` regex (around line 426)
  - `member_match` regex (around line 482) - also support backticks `` `[^`]+` `` here and strip backticks.
  - `note_match` regex (around line 364) - also support backticks `` `[^`]+` `` here and strip backticks.
- Enforce colon prohibition inside attributes and methods:
  - Inside `parse_attribute_signature`, if `:` is in the signature, append a syntax error to `parse_errors`.
  - Inside `parse_method_signature`, if `:` is in the signature, append a syntax error to `parse_errors`.

---

## 2. Proposed Test Changes

### Target File: `skills/spec-orchestrator/parity_auditor/tests/test_uml_validator.py`
- Add `test_issue_70_unbackticked_colon_rejected` asserting that unbackticked colons in class diagrams are correctly rejected.
- Add `test_issue_272_nested_namespaces_accepted` asserting that nested namespace prefixes in schema paths are successfully validated.

---

## 3. Verification Plan

1. **Verify Unattended Permissions**:
   Ensure all command prefixes (`git`, `gh`) and file read/write permissions are granted.
2. **Automated Unit Tests**:
   Run `.venv/bin/pytest` via the spawned Fix Subagent to verify all tests pass.
3. **Commit and Push Changes**:
   Stage, commit, and push the changes via git to the remote tracking branch.
4. **Git Diff Check**:
   Confirm `git diff origin/<branch>` is empty.
