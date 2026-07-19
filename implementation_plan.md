# Implementation Plan: Filing Upstream Linter Defects on GitHub

This plan outlines the creation of 6 individual GitHub issues to track the linter defects identified in the `parity_auditor` package, conforming to the **Upstream Tooling Bug Reporting** mandate.

---

## 1. Proposed Actions

We will run the `gh` CLI command to create 6 new bug issues with detailed bodies, including 5 Whys analysis, symptom descriptions, correctness analysis, UML diagrams, and proposed corrections.

### target issues to file:
1. **`[EPIC-LNT-01]`**: Programmatic `validate()` ignores `epics_dir` argument in `uml.py`.
2. **`[EPIC-LNT-02]`**: CLI bypasses Epic validation if `features` list is empty in `cli.py`.
3. **`[LNT-UML-01]`**: Mermaid parser fails to extract multiplicity inside type-bound definitions (e.g. `+Type[mult] name`) in `mermaid.py`.
4. **`[LNT-UML-02]`**: Return validator requires multiplicity on `void` or single returns in `uml.py`.
5. **`[LNT-UML-03]`**: Codebase coverage checks use naive substring matching, causing false positives on common words in `cli.py`.
6. **`[LNT-UML-04]`**: Link and diagram validation checks run on raw markdown content instead of extracted mermaid blocks in `uml.py`.

---

## 2. Verification Plan

### Automated Verification
* Verify that the issues are successfully created by running `gh issue list --limit 10` and confirming the new issue numbers are returned.
