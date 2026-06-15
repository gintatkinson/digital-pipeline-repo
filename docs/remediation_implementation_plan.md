# Implementation Plan - UML Metamodel Conformance & Deep Pipeline Remediation

This implementation plan outlines the point-by-point technical remediation of the digital systems engineering pipeline. It directly maps every gap identified in the **[UML Compliance Audit Report](file:///Users/perkunas/digital-pipeline-repo/docs/uml_compliance_audit_report.md)** and the bugs from the **[Forensic Analysis Report](file:///Users/perkunas/digital-pipeline-repo/docs/decisions/pipeline_analysis_report.md)** to specific execution phases.

To prevent context exhaustion and ensure maximum quality, Phase 5 has been decomposed into four granular, focused sub-phases.

---

## 1. Goal Description
To refactor the pipeline's governance files, worker templates, and python automation scripts to define, relate, and validate model components as a **unified, semantically verified UML Metamodel**.

Rather than simply patching syntax errors or regexes, we will update the templates to enforce formal UML classifiers, packages, interactions, and constraints, and upgrade the linter to parse Mermaid diagrams structurally to verify cross-view consistency and semantic validity.

---

## 2. Metamodel & Defect Mapping Reference

To ensure 100% traceability, the table below maps each identified UML Gap and Pipeline Bug to its respective execution phase:

| Gap / Bug ID | Description | Remediation Phase |
| :--- | :--- | :--- |
| **[GAP-STR-01]** | Weak Relationship Verification (linter accepts non-UML connectors) | Phase 5b (Linter Class & Sequence Semantic Validation) |
| **[GAP-STR-02]** | Undetected Isolated Classes (isolated classes pass class diagram checks) | Phase 5b (Linter Class & Sequence Semantic Validation) |
| **[GAP-STR-03]** | Choice & Case Stereotype Omission (choice/case structures unvalidated) | Phase 2 (Worker A) & Phase 5b (Linter) |
| **[GAP-STR-04]** | Text-Only Coverage Loophole (prose coverage counts as model representation) | Phase 5c (Linter Use Case & Coverage Validation) |
| **[GAP-STR-05]** | Non-Standard UML Primitive Types (using protocol instead of UML primitives) | Phase 2 (Worker A) & Phase 5b (Linter) |
| **[GAP-STR-06]** | Missing Epic-to-Package Mapping (Epics lack namespace package boundaries) | Phase 2 (Worker A) |
| **[GAP-STR-07]** | Feature-to-Subtree Mapping Bloat (Features mapped to containment subtrees) | Phase 2 (Worker A) |
| **[GAP-STR-08]** | Missing Multiplicity & Visibility Rules (no multiplicities or visibility) | Phase 2 (Worker A) & Phase 5b (Linter) |
| **[GAP-BEH-01]** | Stories to UML Interactions (User stories lack formal Interaction boundaries) | Phase 3 (Worker B) |
| **[GAP-BEH-02]** | Lifeline Notation Violation (sequence diagrams use raw class names) | Phase 3 (Worker B) & Phase 5b (Linter) |
| **[GAP-BEH-03]** | Reply Message Arrowhead Violation (using filled `-->>` instead of open `-->`) | Phase 3 (Worker B) & Phase 5b (Linter) |
| **[GAP-BEH-04]** | Reply Message Signature Violation (reply message styled as operation call) | Phase 3 (Worker B) & Phase 5b (Linter) |
| **[GAP-BEH-05]** | Combined Fragment Guards (guards lack standard square brackets `[guard]`) | Phase 3 (Worker B) & Phase 5b (Linter) |
| **[GAP-BEH-06]** | Missing State Machine Templates (no state machine templates provided) | Phase 3 (Worker B) |
| **[GAP-UC-01]** | Use Case Classifier Mapping (use cases treated as text instead of classifiers) | Phase 4 (Worker C) |
| **[GAP-UC-02]** | Non-Standard Realization (mapping use cases to stories instead of classifiers) | Phase 4 (Worker C) |
| **[GAP-UC-03]** | Prose-Based Scenarios (use case flows are plain text lists instead of interactions) | Phase 4 (Worker C) |
| **[GAP-UC-04]** | Non-Standard Use Case Shapes (drawing use cases as rectangles `UC[Title]`) | Phase 4 (Worker C) & Phase 5c (Linter) |
| **[GAP-UC-05]** | Directed Actor-UseCase Associations (using directed arrows `Actor --> UC`) | Phase 4 (Worker C) & Phase 5c (Linter) |
| **[GAP-UC-06]** | Reversed Arrow Direction for `<<extend>>` (arrow points base to extend) | Phase 4 (Worker C) & Phase 5c (Linter) |
| **[GAP-UC-07]** | Subject Boundary Violation (missing system boundary subgraph) | Phase 4 (Worker C) & Phase 5c (Linter) |
| **[GAP-TR-01]** | Structural-Behavioral Disconnect (sequence lifelines/messages don't map to class diagram) | Phase 5b (Linter Cross-View Check) |
| **[GAP-TR-02]** | Use Case-to-Sequence Diagram Gap (no mapping of use case steps to messages) | Phase 4 (Worker C) & Phase 5c (Linter) |
| **[GAP-TR-03]** | Traceability Ends at Feature (no mapping of spec classifiers to code files) | Phase 2 (Worker A) |
| **[GAP-TR-04]** | Justification Validation Omission (linter accepts empty or missing justifications) | Phase 5c (Linter Use Case & Coverage Validation) |
| **[GAP-LNT-01]** | Superficial Regex Checks (linter only checks header presence, not semantics) | Phase 5a (Linter Core & Mermaid AST Parser) |
| **[GAP-LNT-02]** | Global Coverage Leakage (coverage checked globally in prose instead of class diagram) | Phase 5c (Linter Use Case & Coverage Validation) |
| **[GAP-LNT-03]** | No Schema Extensibility (linter is hardcoded for YANG, skips others) | Phase 1 (Constitution) & Phase 5a |
| **[GAP-LNT-04]** | Reconciler description Erasure (custom frontmatter parser erases multiline YAML) | Phase 5d (Reconciler Upgrades) |
| **[BUG-01]** | Epic Header Naming (numbered headers in Epic template fail linter check) | Phase 2 (Worker A) |
| **[BUG-02]** | Invalid Mermaid Dotted Link syntax (using pipe label format `-.->|label|`) | Phase 3 (Worker B) & Phase 4 (Worker C) |
| **[BUG-03]** | Too few alternate flows/steps in Use Case worker | Phase 4 (Worker C) |
| **[BUG-04]** | Feature UI requirements header name & missing JSON payload | Phase 2 (Worker A) |
| **[BUG-05]** | Relative links in Realization matrices (causes 404 links on GitHub issues) | Phase 4 (Worker C) |
| **[BUG-06]** | Isolated classes in Class Diagrams | Phase 2 (Worker A) & Phase 5b (Linter) |
| **[BUG-07]** | Shallow sequence diagrams (missing validations/calculations) | Phase 3 (Worker B) |
| **[BUG-08]** | Missing stories for algorithmic/derived states (speed/heading) | Phase 3 (Worker B) |
| **[BUG-09]** | State-open-only/Title-only GitHub query in Use Case worker | Phase 4 (Worker C) |
| **[BUG-10]** | Silent treatment of hallucinated/fake issues in reconciler | Phase 5d (Reconciler Upgrades) |
| **[BUG-11]** | Multiline frontmatter YAML erasures in reconciler | Phase 5d (Reconciler Upgrades) |

---

## 3. Phased Roadmap

### Phase 1: Metamodel Alignment in the Functional Constitution
*   **Target Files**:
    *   `[MODIFY]` [.pipeline/constitution.md](file:///Users/perkunas/digital-pipeline-repo/.pipeline/constitution.md)
    *   `[MODIFY]` [skills/project-constitution/SKILL.md](file:///Users/perkunas/digital-pipeline-repo/skills/project-constitution/SKILL.md)
*   **Remediation Items**:
    - **Dynamic Metamodel Resolution**: Replace hardcoded protocol references (YANG/RFC 8345) with a formal **UML Profile Mapping standard**. Dictate how any ingested schema (YANG, OpenAPI, Protobuf) maps to UML structural classifiers and behavioral interactions at runtime. **[Resolves GAP-LNT-03]**
    - **Universal Model Consistency Rules**: Mandate that all specifications must form a cohesive model. Enforce that no classifier, operation, or message may be used in a dynamic diagram (Sequence/State Machine) without being declared in the static structure (Class Diagram). **[Resolves GAP-TR-01, GAP-TR-02]**

### Phase 2: Schema Specification to UML Classifier Mapping (Worker A)
*   **Target Files**:
    *   `[MODIFY]` [skills/schema-specification-engineering/SKILL.md](file:///Users/perkunas/digital-pipeline-repo/skills/schema-specification-engineering/SKILL.md)
*   **Remediation Items**:
    - **Component-Level Classifier Definition**: Update the Epic template to define a UML `Component` representing the subsystem, including its provided/required `Interfaces` and `Operations`. **[Resolves GAP-STR-06, GAP-STR-07]**
    - **Schema-to-Classifier Property Mapping**: Redesign Feature specifications to represent a single primary UML `Class` or `DataType` instead of a subtree of structural containers. **[Resolves GAP-STR-07]**
    - **YANG to UML Type Translation**: Enforce strict mapping of schema-specific types to standard capitalized UML primitives (`String`, `Integer`, `Real`, `Boolean`) and multiplicities (e.g. `[1]`, `[0..1]`). **[Resolves GAP-STR-05]**
    - **Visibility Rules**: Apply visibility indicators (`+` for public, `-` for private) to all classifier attributes and operations. **[Resolves GAP-STR-08]**
    - **YANG Constraints to UML Constraints**: Enforce mapping of YANG `must` and `when` rules to formal UML `{constraint}` elements attached to the class properties, written in structured text or Object Constraint Language (OCL). **[Resolves GAP-STR-03]**
    - **Package Hierarchy**: Map Epics to UML Packages using the Mermaid `namespace` keyword to define logical boundaries. **[Resolves GAP-STR-06]**
    - **Code Realization Table**: require a Code Realization Table in features mapping Spec classifiers to code files/classes. **[Resolves GAP-TR-03]**
    - **Correct Template Headers**: Update the template headers to prevent linter matching errors (`## System-Level UML Class Diagram` and `## Functional UI Requirements`). **[Resolves BUG-01, BUG-04]**
    - **JSON Payload Scaffold**: Include concrete JSON copy-pasteable blocks under UI requirements. **[Resolves BUG-04]**

### Phase 3: Behavioral Interaction & Interface Alignment (Worker B)
*   **Target Files**:
    *   `[MODIFY]` [skills/spec-user-story-engineering/SKILL.md](file:///Users/perkunas/digital-pipeline-repo/skills/spec-user-story-engineering/SKILL.md)
*   **Remediation Items**:
    - **Interaction Realization Mapping**: Mandate that every User Story sequence diagram lifeline is defined as an instance of a Class or Component declared in the Feature Class Diagrams. **[Resolves GAP-BEH-01]**
    - **Sequence Diagram Lifeline Notation**: Enforce standard lifeline notation (`name : Classifier` or `: Classifier`) instead of naked classifier names. **[Resolves GAP-BEH-02]**
    - **Message-to-Operation Alignment**: Mandate that every message in a sequence diagram corresponds to a formal `Operation` defined on the receiver lifeline's classifier in the class diagram, using camelCase signatures and typed parameters/returns. **[Resolves BUG-07]**
    - **Return arrow and signature**: Enforce open return arrowheads (`-->` in Mermaid) and return value/assignment signature style (e.g. `isValid : Boolean`). **[Resolves GAP-BEH-03, GAP-BEH-04]**
    - **Combined Fragment Guards**: Require combined fragment guards to be enclosed in standard UML square brackets `[guard]`. **[Resolves GAP-BEH-05]**
    - **State Machine Integration**: Provide guidelines and templates for Mermaid `stateDiagram-v2` to model Classifier lifecycles, state transitions, events/triggers, guard conditions, and actions. **[Resolves GAP-BEH-06]**
    - **Algorithmic/Lifecycle Stories Trigger**: Introduce mandatory triggers to spawn stories for calculations (e.g. speed/heading) and state expiries. **[Resolves BUG-08]**
    - **Dotted Link Syntax Constraint**: Force the use of `-. label .->` syntax. **[Resolves BUG-02]**

### Phase 4: Use Case Realization Modeling (Worker C)
*   **Target Files**:
    *   `[MODIFY]` [skills/spec-usecase-engineering/SKILL.md](file:///Users/perkunas/digital-pipeline-repo/skills/spec-usecase-engineering/SKILL.md)
*   **Remediation Items**:
    - **Use Case Classifier Boundaries**: Enforce use case diagrams to group use cases inside a defined Subject boundary (`subgraph` representing the system boundary) and define actors as external classifiers. **[Resolves GAP-UC-01, GAP-UC-07]**
    - **Use Case Realization Collaborations**: Mandate that each Use Case contains a "Realization" section linking scenario steps directly to message interactions on the subsystem components. **[Resolves GAP-UC-02, GAP-UC-03]**
    - **UML Use Case Diagram Shapes**: Correct Use Case diagram templates to draw oval nodes `UC([Title])` and use client-to-supplier extend arrows (`UC_Ext -. <<extend>> .-> UC`). **[Resolves GAP-UC-04, GAP-UC-06]**
    - **Undirected Actor Associations**: Enforce undirected associations (plain solid lines `---` without arrowheads) between Actors and Use Cases. **[Resolves GAP-UC-05]**
    - **Alternate/Exception flows step requirements**: Require at least 2 alternate flows with 2+ steps branching from specific Main Success steps. **[Resolves BUG-03]**
    - **GitHub Issue Query**: Query both open and closed issues and search the body semantically. **[Resolves BUG-09]**
    - **Absolute URLs & Realization checklists**: Enforce absolute URLs to prevent 404 links on GitHub. **[Resolves BUG-05]**

### Phase 5a: Linter Core & Mermaid AST Parser (Worker E1)
*   **Target Files**:
    *   `[MODIFY]` [skills/spec-orchestrator/scripts/verify_model_coverage.py](file:///Users/perkunas/digital-pipeline-repo/skills/spec-orchestrator/scripts/verify_model_coverage.py)
*   **Remediation Items**:
    - **Mermaid AST Symbol Parser**: Write a robust parser in `verify_model_coverage.py` that extracts diagrams (`classDiagram`, `sequenceDiagram`, `stateDiagram-v2`, `flowchart`) from markdown specs and builds an in-memory symbol table representing classes, attributes, lifelines, message operations, use case nodes, system boundary subgraphs, and connections. **[Resolves GAP-LNT-01, GAP-LNT-03]**

### Phase 5b: Linter Class & Sequence Semantic Validation (Worker E2)
*   **Target Files**:
    *   `[MODIFY]` [skills/spec-orchestrator/scripts/verify_model_coverage.py](file:///Users/perkunas/digital-pipeline-repo/skills/spec-orchestrator/scripts/verify_model_coverage.py)
*   **Remediation Items**:
    - **Semantic Class Diagram Validation**: Enforce no isolated classes (reachability check), primitive type check (String, Integer, Real, Boolean), visibility/multiplicity presence, and generalization rules for choices. **[Resolves GAP-STR-01, GAP-STR-02, GAP-STR-03, GAP-STR-05, GAP-STR-08, BUG-06]**
    - **Semantic Sequence Diagram Validation**: Enforce lifeline notation (`name : Classifier`), cross-view classifier check (assert lifeline exists in class diagrams), cross-view operation check (assert message exists as method on receiver class), return arrow open arrowhead (`-->`) and assignment syntax check, and bracket guards check. **[Resolves GAP-BEH-02, GAP-BEH-03, GAP-BEH-04, GAP-BEH-05, GAP-TR-01]**

### Phase 5c: Linter Use Case & Coverage Validation (Worker E3)
*   **Target Files**:
    *   `[MODIFY]` [skills/spec-orchestrator/scripts/verify_model_coverage.py](file:///Users/perkunas/digital-pipeline-repo/skills/spec-orchestrator/scripts/verify_model_coverage.py)
*   **Remediation Items**:
    - **Semantic Use Case Diagram Validation**: Enforce oval shapes for use case nodes `([])`, undirected actor-usecase connections (`---`), system boundary `subgraph` presence, and extend arrow direction. **[Resolves GAP-UC-04, GAP-UC-05, GAP-UC-06, GAP-UC-07, GAP-TR-02]**
    - **Class Diagram Node Coverage**: Enforce that schema node coverage is verified against attributes inside the parsed Class Diagrams instead of globally in the prose. **[Resolves GAP-LNT-02, GAP-STR-04]**
    - **Justification Validation**: Verify story checklist items have parenthetical justifications. **[Resolves GAP-TR-04]**

### Phase 5d: Reconciler Upgrades (Worker E4)
*   **Target Files**:
    *   `[MODIFY]` [skills/spec-orchestrator/scripts/reconcile_backlog.py](file:///Users/perkunas/digital-pipeline-repo/skills/spec-orchestrator/scripts/reconcile_backlog.py)
*   **Remediation Items**:
    - **YAML frontmatter parser repair**: Replace naive line splitters with standard YAML library or robust multi-line parser to prevent block description erasures on sync. **[Resolves BUG-11, GAP-LNT-04]**
    - **Reconciler Hallucination Gate**: Verify that every referenced issue ID matches a real issue in the repository. **[Resolves BUG-10]**

---

## 4. Verification & Validation Plan

### Automated Validation
1. **Linter Compilation**: Run python compiler checks to ensure both modified scripts are syntax-error free:
   ```bash
   python3 -m py_compile skills/spec-orchestrator/scripts/verify_model_coverage.py
   ```
   ```bash
   python3 -m py_compile skills/spec-orchestrator/scripts/reconcile_backlog.py
   ```
2. **Negative Test Suite**: Execute the upgraded linter against a mock specification containing semantic UML violations (e.g. sequence diagram messages calling operations not defined in the class diagrams, or lifelines referencing undeclared classifiers) and verify that the linter correctly identifies the gaps and exits with a non-zero code.

### Manual Verification
1. **Cross-View consistency Check**: Manually trace a generated Use Case down to its Sequence Diagram interactions, verify that all lifelines and operations exist in the Feature Class Diagrams, and confirm that the linter successfully passes the file.
