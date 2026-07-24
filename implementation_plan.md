# Implementation Plan - Fix Bug #179: Trailing semicolons in sequence diagram messages

This plan outlines the changes to fix Bug #179: "Spec generator copies trailing semicolons from code model to sequence diagrams".

## Proposed Changes

### Phase 1: Codebase Modifications

1. **Update `skills/spec-orchestrator/parity_auditor/src/parity_auditor/parsers/mermaid.py`**:
   - File: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/parsers/mermaid.py`
   - In `MermaidSequenceDiagramParser.parse()`:
     Where message statements are matched and `msg_text` is extracted (around line 633):
     Check if the message text ends with a semicolon:
     ```python
     if msg_text.endswith(";"):
         parse_errors.append(f"Semicolons are not allowed in sequence diagram message statements: '{line.strip()}'")
     ```

2. **Update `skills/spec-user-story-engineering/SKILL.md`**:
   - File: `skills/spec-user-story-engineering/SKILL.md`
   - Add a warning:
     ```markdown
     > - **Semicolon Restriction**: Do NOT use semicolons (`;`) in sequence diagram `Note` statements or message text statements. Semicolons are not allowed. Replace any semicolons (`;`) with commas, dashes, or spaces.
     ```

3. **Update `skills/spec-usecase-engineering/SKILL.md`**:
   - File: `skills/spec-usecase-engineering/SKILL.md`
   - Add the same semicolon restriction warning in the `> [!WARNING]` block.

4. **Add unit test in `skills/spec-orchestrator/parity_auditor/tests/test_mermaid_parsers_bug171.py`**:
   - Add a test function `test_sequence_diagram_message_with_semicolon_rejected()` that parses a sequence diagram with a trailing semicolon in a message and asserts that a parse error is returned: `"Semicolons are not allowed in sequence diagram message statements:"`.

### Phase 2: Verification (TDD RED-GREEN)

1. **RED Phase**: Run the unit tests with the new test added but before the parser fix is applied, confirming the test fails/errors out.
2. **GREEN Phase**: Apply the parser fix, run `pytest`, and verify all tests pass.
3. Run all tests in the workspace to make sure no regressions are introduced.

### Phase 3: Git Operations & Synchronization

1. Checkout branch `bugfix/pipeline-linter-issues` if not already on it.
2. Stage and commit the changed files (`mermaid.py`, `test_mermaid_parsers_bug171.py`, `SKILL.md` files).
3. Push the changes to the remote branch.
4. Update GitHub Issue #179 with root cause and fix details using the `gh` CLI.
