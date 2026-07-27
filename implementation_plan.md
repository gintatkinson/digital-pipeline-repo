# Implementation Plan - Fix Compiler Grouping Extraction (Issue #241)

This plan details the surgical changes to extract data definitions from top-level grouping blocks in `scripts/compile_yang.py` when compiling YANG files that only define groupings (e.g., `ietf-geo-location`).

## 1. Defect Context & Scope

*   **Target File**: [`scripts/compile_yang.py`](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/compile_yang.py)
*   **Pillar**: Semantic Traceability
*   **Defect Issue**: Issue #241. When a YANG file only defines top-level groupings, `module.i_children` is empty, causing the compiler to return 0 data definitions. The compiler needs to extract definitions from the top-level `grouping` blocks as well.

## 2. Proposed Changes

### File: [`scripts/compile_yang.py`](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/compile_yang.py)

Modify the `parse_yang(input_path)` function (around line 400) to check for groupings if `module.i_children` does not yield any data-definition statements:

```python
    data_defs = [c for c in module.i_children if c.keyword in statements.data_definition_keywords]
    if not data_defs:
        # Fallback to extracting data-definition statements from top-level groupings
        groupings = module.search('grouping')
        for g in groupings:
            g_children = getattr(g, 'i_children', None) or g.substmts
            for c in g_children:
                if c.keyword in statements.data_definition_keywords:
                    data_defs.append(c)

    return data_defs
```

### File: [`skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py`](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py)

Add a new unit test `test_parse_yang_extracts_from_groupings` that verifies that groupings are successfully compiled.

## 3. Verification Plan

1.  **Direct Compilation Verification**: Run `python3 scripts/compile_yang.py -i scratch/test-grouping.yang -o scratch/out2.json` and verify that the output contains the attributes and hierarchy nodes defined inside the grouping.
2.  **Unit Tests**: Run `python3 -m pytest skills/spec-orchestrator/parity_auditor/tests/` to verify all tests (including the new test) pass successfully.
3.  **Compilation Validation**: Run `python3 -m py_compile scripts/compile_yang.py` to ensure the script compiles with no syntax errors.
4.  **Git Verification**: Run `git diff` to verify the surgical changes.
5.  **Reconciliation / Synchronization**: Commit and push the changes, and verify `git diff origin/main` is empty.
