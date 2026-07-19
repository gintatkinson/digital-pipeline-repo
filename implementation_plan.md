# Implementation Plan: Correct GitHub Issues #58-63 Bodies

This plan outlines the updates to GitHub Issues #58 through #63 to resolve all Mermaid syntax errors, unquoted participant labels, incorrect sequence diagrams, and pillar classification mismatches.

---

## 1. Proposed Actions

We will generate the corrected issue bodies for all 6 issues and run `gh issue edit [number] --body-file [temp_file]` to apply the updates.

### Targets for Correction:
1. **Issue #58 (`[EPIC-LNT-01]`)**:
   * Quoted participant label: `participant C as "Caller (Programmatic)"`
   * Refactored helper call `build_global_classes` as a self-call: `V->>V: build_global_classes(...)`
   * Pillar: `Model Coverage` (Audit Source: `Adversarial Model Coverage Audit`)
   * Reference lines: `uml.py:29`
2. **Issue #59 (`[EPIC-LNT-02]`)**:
   * Quoted participant label: `participant M as "main() implementation"`
   * Pillar: `Model Coverage` (Audit Source: `Adversarial Model Coverage Audit`)
3. **Issue #60 (`[LNT-UML-01]`)**:
   * Refactored helper call `parse_attribute_signature` as a self-call on parser `P`: `P->>P: parse_attribute_signature(...)`
   * Replaced double-quotes in message parameters with single quotes to avoid parser errors.
   * Pillar: `Diagram Validity` (Audit Source: `Adversarial Diagram Validity Audit`)
4. **Issue #61 (`[LNT-UML-02]`)**:
   * Refactored helper call `_validate_class_diagram` as a self-call on validator `V`: `V->>V: _validate_class_diagram(...)`
   * Replaced double-quotes in message parameters.
   * Pillar: `Diagram Validity` (Audit Source: `Adversarial Diagram Validity Audit`)
5. **Issue #62 (`[LNT-UML-03]`)**:
   * Quoted participant labels: `participant C as "CLI (Model Coverage)"` and `participant F as "File Content (with comments)"`
   * Replaced double-quotes in message parameters.
   * Pillar: `Model Coverage` (Audit Source: `Adversarial Model Coverage Audit`)
6. **Issue #63 (`[LNT-UML-04]`)**:
   * Pillar: `Diagram Validity` (Audit Source: `Adversarial Diagram Validity Audit`)

---

## 2. Verification Plan

### Automated Verification
* View all 6 issues on GitHub using `gh issue view` and check that the bodies match the corrected templates with correct quotes and rendering syntax.
