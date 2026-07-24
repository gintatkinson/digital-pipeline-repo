# Implementation Plan - Fix Bug #180: Semicolons in sequence diagram Note statements

This plan outlines the changes to fix Bug #180: "Linter fails to validate and reject semicolons in sequence diagram Note statements (False Negative)".

## Proposed Changes

### Phase 1: Codebase Modifications

1. **Update `skills/spec-orchestrator/parity_auditor/src/parity_auditor/parsers/mermaid.py`**:
   - File: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/parsers/mermaid.py`
   - In `MermaidSequenceDiagramParser.parse()`:
     Where Note statements are bypassed (inside the `if line.lower().startswith("note ") or ...:` block, specifically where `if not (is_msg or is_lifeline): continue` occurs), check if `";" in line`.
     If so, append a parse error:
     ```python
     if ";" in line:
         parse_errors.append(f"Semicolons are not allowed in sequence diagram Note statements: '{line.strip()}'")
     ```

2. **Add unit test in `skills/spec-orchestrator/parity_auditor/tests/test_mermaid_parsers_bug171.py`**:
   - Add a test function `test_sequence_diagram_note_with_semicolon_rejected()` that passes a diagram containing a note with a semicolon, and asserts that the parser returns a parse error: `"Semicolons are not allowed in sequence diagram Note statements:"`.

### Phase 2: Verification (TDD RED-GREEN)

1. **RED Phase**: Add the unit test, run it, and verify that it fails (or returns false negative without the parser change).
2. **GREEN Phase**: Apply the parser change, run the test, and verify it passes.
3. Run all parser tests under `skills/spec-orchestrator/parity_auditor/tests/test_mermaid_parsers_bug171.py`.

### Phase 3: Git Operations & Synchronization

1. Checkout branch `bugfix/pipeline-linter-issues`.
2. Stage modified files (`mermaid.py`, `test_mermaid_parsers_bug171.py`).
3. Commit changes with message: `fix(parity-auditor): reject semicolons in sequence diagram Note statements`.
4. Push to remote origin on `bugfix/pipeline-linter-issues`.
5. Update GitHub Issue #180 with root-cause and fix details using the `gh` CLI.
