# Implementation Plan: Fix Template Issues in Schema Specification Engineering Skill

This plan details the surgical changes to resolve four template issues in `skills/schema-specification-engineering/SKILL.md`.

## 1. Defect Context & Scope

*   **Target File**: [`skills/schema-specification-engineering/SKILL.md`](file:///Users/perkunas/jail/digital-pipeline-repo/skills/schema-specification-engineering/SKILL.md)
*   **Defect Issues**:
    1.  **#247 (Epic/Feature Template Parity)**: Add `Operational Considerations` and `Security & Governance` to the Epic template, and split combined headers in the Feature template.
    2.  **#249 (Section Heading Numbering)**: Remove numbered prefixes from `References` and `Bindings` sections in the Feature template (lines 249-277).
    3.  **#250 (Epic UML Consistency)**: Map the transition event in the state machine diagram to a class operation (`operationOne(input)`), and add clause references to checklists and source references.
    4.  **#251 (Feature JSON Alignment & Multiplicity)**: Align the Feature template's JSON example with the attributes in its class diagram, remove the double-declaration of `featureClassifier` from `ParentContainer` class body, and quote multiplicity brackets in class diagrams.

---

## 2. Proposed Changes

### File: [`skills/schema-specification-engineering/SKILL.md`](file:///Users/perkunas/jail/digital-pipeline-repo/skills/schema-specification-engineering/SKILL.md)

1.  **Update Epic Template (Lines 129-191)**:
    *   Rename H2 `## 3. Architecture and System Interaction Diagrams` to `## 3. Architecture`.
    *   Align the Epic transition event in `System State Machine Diagram` to use class operation `operationOne(input)`.
    *   Insert sections `## 4. Operational Considerations` and `## 5. Security & Governance` as H2s.
    *   Rename H2 `## 6. Source References` and add `(Clause: [Clause Number])` to structural schema and normative spec items.
    *   Update H2s `## 4. State Machine Definitions` and `## 5. Specification Context` to be unnumbered: `## State Machine Definitions` and `## Specification Context`.
    *   Quote multiplicity brackets inside the Epic class diagram attributes.

2.  **Update Feature Template & Sections (Lines 193-277)**:
    *   Remove double-declaration `+FeatureClassifier featureClassifier [1]` from `ParentContainer` class body, and quote multiplicity brackets in the class diagram.
    *   Split the combined headers `### 1. Test Data Shape / Payload Schema (JSON Example)`, `### 3. Visual Layout / Logical Operations & Interface Messages`, and `### 4. Interactive Flow & States / Logical Exception States & Validation Failures` into separate blocks for UI interfaces and API/M2M interfaces respectively.
    *   Align the copy-pasteable JSON examples with `FeatureClassifier`'s attributes (`primaryAttribute`, `optionalAttribute`, `listAttribute`).
    *   Remove numbers from headings in the template: change `## 4. Source References` to `## Source References`, and `## 5. Logical UI & Layout Bindings` to `## Logical UI & Layout Bindings`.
    *   Update text references to these headings in the instruction blocks (e.g. lines 264-273).
    *   Add `(Clause: [Clause Number])` placeholders to the Source References template.

---

## 3. Verification Plan

1.  **Validate Model Coverage Linter**: Run the spec validation check:
    ```bash
    python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
    ```
2.  **Git Verification**: Verify changes with `git diff` and ensure only target lines are affected.
3.  **Remote Sync**: Stage, commit (`fix: resolve issues #247, #249, #250, #251 in schema spec skill`), and push changes to the remote branch.
