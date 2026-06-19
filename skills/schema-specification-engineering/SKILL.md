<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

---
name: schema-specification-engineering
description: "Transforms structural schemas and normative specification documents into Agile Epics and Features. Use when you need to extract platform-independent feature specifications from structural schemas with exhaustive constraint parsing and Given-When-Then acceptance criteria."
compatibility: "Requires issue tracker CLI and git. Works with modern agentic development environments."
metadata:
  title: "Schema Specification Engineering (Structural Extraction)"
  risk: medium
  source: custom
  version: "2.0"
---

# Schema Specification Engineering

Use this as the single canonical workflow for translating structural schemas and their normative specification documents into highly rigorous, implementation-ready Agile specifications for sub-agents. 

> [!TIP]
> This skill operates in the spirit of the `andrej-karpathy` methodology: focus deeply on the fundamentals, enforce exhaustive structural rigor, leave absolutely zero ambiguity in the acceptance criteria, and instrument the outputs flawlessly into project tracking systems.

> [!IMPORTANT]
> **EXHAUSTIVE SEMANTIC MODELING MANDATE**
> Do NOT blindly map every isolated schema attribute (e.g., `x`, `y`, `z`) to a separate Feature. You MUST semantically model the schema by grouping cohesive properties into a single logical Feature (e.g., "Cartesian Coordinates"). However, "zero abstraction" still applies: within that grouped Feature, you MUST exhaustively document EVERY underlying attribute/node, capturing its exact data type, mathematical constraints (value ranges, units), defaults, and verbatim specification text. No constraint detail may be lost or summarized away.

## Step 1: Forensic Audit & Module Decomposition

1. **Parse the Schema:** Read the primary structural schema file and its imports.
2. **Identify Top-Level Trees:** Decompose the high-level structural attributes (e.g., system configuration, users, orders) into discrete logical groupings.
3. **Establish Epics:** Map these high-level structures directly into Agile "Epics". Do not create the Epic issue yet. First, document it locally as a markdown file (e.g., `docs/epics/epic-01-name.md`). The Epic file MUST contain:
   - An overarching **System-Level UML Class Diagram** illustrating the subsystem's classes and their relationships.
   - A **UML Component** representing the subsystem, specifying its provided/required interfaces and operations.
   - A **System State Machine Diagram** representing the macro-level domain, combining the individual structures and lifecycles that will be broken down into child features.

## Step 2: Exhaustive Feature Extraction

1. **Semantic Feature Breakdown:** Analyze the child structures, alternative choices, or elements. Identify cohesive functional groups (e.g., a "User Profile" containing `first-name`, `last-name`) and map them to a distinct "Feature".
2. **Platform Independence:** Feature specifications MUST be purely functional and platform-independent. Describe *what* the system must do (data to store, validations to enforce, information to display) — never *how* (no framework-specific components, no platform-specific patterns). Platform-specific implementation details are resolved later via the `feature-driven-implementation` skill using platform-specific implementation profiles.
3. **Exhaustive Constraint Parsing:** For EVERY attribute within the grouped feature, analyze and record all structural constraints:
   - conditional clauses
   - type definitions (value ranges, string patterns, references)
   - units and default values
   - read-only vs configurable access control
4. **UML Class Diagram:** Every Feature specification MUST include a **UML Class Diagram** (using Mermaid `classDiagram`).
    - **UML Classifier Mapping**: Feature specifications must map to a primary UML Class or DataType representing the schema entity, and MUST illustrate its relationship (e.g. composition `*--` or aggregation `o--`) to its parent container class or its child components to ensure no isolated classes exist. Classes that will cross serialization boundaries (Web Workers via `structuredClone`, Flutter Isolates via `SendPort`) MUST be modeled as pure data classes (DTOs) without methods. Service methods (e.g. `save()`, `validate()`) MUST be placed in separate service/repository classes that are NOT transferred across threads.
   - **Choice/Case Representation**: Model schema alternative structures as abstract classes or classes with the `<<choice>>` stereotype, and their constituent choices as classes inheriting (`<|--`) from the choice class.
   - **UML Standard Primitive Types**: All attributes in class diagrams must use standard capitalized UML primitives (`String`, `Integer`, `Real`, `Boolean`) instead of format-specific or custom types.
   - **Visibility & Multiplicity**: Every attribute/operation must use visibility indicators (`+`/`-`) and standard multiplicities (e.g. `[1]`, `[0..1]`, `[0..*]`).
   - **UML Constraints**: Schema-level constraints must map to formal UML `{constraint}` elements or structured notes.
   - **Multiplicity Bracket Rendering**: Note that unquoted brackets `[0..1]` inside Mermaid class bodies may cause rendering failures in some engines (GitHub, Mermaid CLI). Recommend representing multiplicity on relationship lines instead:
     ```mermaid
     GeoLocation "1" *-- "0..1" Velocity : velocity
     ```
   - **Double-Declaration Redundancy**: Do NOT list object-typed attributes (e.g. `+ReferenceFrame referenceFrame[1]`) inside the class body if they are already represented as named relationship lines. This causes sync-drift.
5. **Interface Requirements:** Every feature spec MUST explicitly include a `## Interface Requirements` section divided into dynamic structured sub-sections based on the `interface_type` (defined in frontmatter as `ui`, `api`, or `m2m`):
   - **For UI Interfaces (`interface_type: ui`)**:
     - `1. Test Data Shape (JSON Payload Example)`: A concrete, copy-pasteable JSON payload schema example block.
     - `2. Validation & Constraints`: Exhaustive list of ranges, regex patterns, mandatory fields, and conditions.
     - `3. Visual Layout & Arrangement`: Detailed, platform-independent description of the visual layout and hierarchy.
     - `4. Interactive Flow & States`: System states (read-only, edit, empty, loading, error highlighting).
   - **For API or M2M Interfaces (`interface_type: api` or `m2m`)**:
     - `1. Payload Schema (JSON Schema/Protobuf)`: Target request/response payload definition.
     - `2. Validation & Constraints`: Schema field constraints, type validations, and logical conditions.
     - `3. Logical Operations & Interface Messages`: Abstract definitions of logical endpoints, methods (GET/POST/Publish/Subscribe or read/write operations), logical paths, or routing channels.
     - `4. Logical Exception States & Validation Failures`: Expected logical error states, exception/failure flows, and timeouts.
6. **Acceptance Criteria Translation:** Transform these programmatic constraints and interface requirements into exhaustive Given-When-Then Logical Acceptance Criteria. Criteria MUST be platform-independent (e.g., "Given the database contains active records... When the user inspects the node... Then the detail view displays the record attributes"). Do not reference specific UI components or frameworks.
8. **Draft the Feature Specs:** Write each Feature as a local markdown file (e.g., `docs/features/feat-01-name.md`).

## Step 3: Specification Context Injection (Verbatim)

1. **Locate Normative Text:** Find the canonical normative text document (e.g. specification standard documents) associated with the schema.
2. **Extract Line-by-Line Context:** Identify the exact paragraphs and sections that explain the behavioral logic of the specific structural container.
3. **Embed Context:** Inject this verbatim text directly into the feature specification under a `## Specification Context (Verbatim)` section. This guarantees that implementing sub-agents have ground-truth knowledge and are not hallucinating implementation details.

## Step 4: Output Formatting & Strict GitHub Instrumentation

> [!WARNING]
> You must strictly follow the operational sequencing below to ensure the `#IssueID` linkages are perfectly resolved.

1. **YAML Frontmatter:** Prepend strict YAML metadata to every `.md` file:
   ```yaml
   ---
   title: "[Title]"
   epic: "[Parent Epic]"
   type: "feature"
   interface_type: "ui" # Options: ui, api, m2m
   labels: ["feature", "<domain-name>"]
   ---
   ```
   > **Note:** No `platform` field. Features are functional specs. Platform targeting occurs at implementation time via `feature-driven-implementation` and the project's implementation profiles.

2. **Epic File Structure / Template:** Every Epic specification markdown file MUST follow this exact section structure and ordering:
    ```markdown
    # Epic: [Epic Title]

    ## 1. Context
    [High-level functional description and specification-engineering context of the schema module]

    ## 2. Requirements & Checklist
    - [ ] #[IssueID] - Feature 1: [Feature Title](URL)

    ### Associated Use Cases & User Stories

    #### Associated Use Cases
    - [ ] #[IssueID] - Use Case 1: [Use Case Title] (Issue #[IssueID])

    #### Associated User Stories
    - [ ] #[IssueID] - User Story 1: [User Story Title] (Issue #[IssueID])

    ## 3. Architecture and System Interaction Diagrams

    ### Subsystem Component Definition
    Define the subsystem representing the Epic as a UML Component specifying provided/required interfaces and operations.
    ```mermaid
    classDiagram
        class SubsystemComponent {
            <<component>>
            +providedInterface() : Boolean [1]
            +requiredInterface() : String [1]
        }
    ```

    ## System-Level UML Class Diagram
    ```mermaid
    classDiagram
        class SubsystemComponent {
            <<component>>
        }
        class FeatureClassifier1 {
            +String attributeOne [1]
            -Boolean attributeTwo [0..1]
        }
        class FeatureClassifier2 {
            +Integer attributeThree [0..*]
            +operationOne(input : String) : Boolean [1]
        }
        SubsystemComponent *-- FeatureClassifier1
        SubsystemComponent *-- FeatureClassifier2
    ```

    ## 4. State Machine Definitions

    ## System State Machine Diagram
    ```mermaid
    stateDiagram-v2
        [*] --> InitialState
        InitialState --> [*] : Event / Action
    ```

    ## 5. Specification Context
    [Verbatim schema grouping/container descriptions from the normative specification]

    ## 6. Source References
    Structural Schema: [Schema File Name]
    Normative Specification: [RFC/Standard Name]
    ```

3. **Feature File Structure / Template:** Every feature specification markdown file MUST follow this exact section structure and ordering:
   ```markdown
   # Feature: [Feature Title]

   ## Description
   [Functional description of the feature]

     ## UML Class Diagram
     ```mermaid
     classDiagram
         class ParentContainer {
             +FeatureClassifier featureClassifier [1]
         }
         class FeatureClassifier {
             +String primaryAttribute [1]
             -Boolean optionalAttribute [0..1] {constraintText}
             +Integer listAttribute [0..*]
             +doSomething(param : String) : Boolean [1]
         }
         ParentContainer *-- FeatureClassifier
     ```

     ## Interface Requirements
     ### 1. Test Data Shape / Payload Schema (JSON Example)
     ```json
     {
       "example_key": "example_value"
     }
     ```

     ### 2. Validation & Constraints
     - [Field constraints, ranges, patterns, protocol/payload limits]

     ### 3. Visual Layout / Logical Operations & Interface Messages
     - [For UI: abstract grouping, zoning, hierarchy guidelines. For API/M2M: logical methods, operations, abstract paths, or channels]

     ### 4. Interactive Flow & States / Logical Exception States & Validation Failures
     - [For UI: states, errors, loading. For API/M2M: logical error states, timeouts, exception flows]

   ## Given-When-Then Acceptance Criteria
   [BDD scenarios]

   ## Specification Context (Verbatim)
   [Raw normative specification context paragraphs]

   ## 4. Source References
   [Source references links]
   ```

3. **Source References Block (CRITICAL):**
   - At the bottom of every feature markdown file, you MUST append a `## 4. Source References` section containing dynamic references to the input structural schemas and specifications, formatted like this:
   ```markdown
   ## 4. Source References
   Structural Schema: [Target Schema File](link-to-schema)
   Normative Specification: [Normative Specification](link-to-specification)
   ```
   - Inject the exact absolute URLs pointing to the authoritative structural schema and normative text document provided by the user. Do not omit this.

2. **Tracker Label Bootstrapping:** Invoke the issue tracker's label bootstrap interface (e.g. creating "epic" and "feature" labels in the configured provider).

3. **Duplicate Detection (Idempotency Check):**
   - Before creating any issue, query the active tracker provider for all existing backlog issues to check if an issue with an identical or semantically equivalent title already exists.
   - If a duplicate is found: skip creation, and reuse the existing Issue ID for Epic linkage.
   - This ensures the pipeline is safe to re-run without creating duplicate issues.

4. **Feature Backlog Creation FIRST:**
   - Register each Feature specification with the active tracker provider, capturing the returned Issue ID/URL from the tracker.

5. **Epic Backlog Assembly:**
   - Now that you possess the actual live Issue IDs for all extracted features, inject them into the Epic's checklist.
   - Ensure the body of the Epic lists its child features as a tasklist referencing the Issue ID and the absolute repository URL of the feature document (relative links resolve incorrectly on tracker UI platforms). You MUST dynamically determine the repository base URL from the runtime configuration (`meta.upstream_repository` in `codebase_rules.json`) and construct the absolute link pointing to the file on the current branch using the configured URL template (e.g., `[Repository Base URL]/<blob_path>/[Branch Name]/docs/features/feat-01.md` where `<blob_path>` is resolved from configuration).

6. **Epic Backlog Creation LAST:**
   - Finally, register the Epic specification containing the fully resolved tasklist with the active tracker provider.
