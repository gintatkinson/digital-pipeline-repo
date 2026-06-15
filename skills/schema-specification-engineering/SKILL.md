<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

---
name: schema-specification-engineering
description: "Transforms structural schemas (YANG, OpenAPI, Protobuf) and normative specification documents into Agile Epics and Features. Use when you need to extract platform-independent feature specifications from protocol schemas with exhaustive constraint parsing and Given-When-Then acceptance criteria."
compatibility: "Requires gh CLI and git. Works with Claude Code, Gemini CLI, Cursor, Copilot, Cascade."
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
> Do NOT blindly map every isolated leaf node (e.g., `x`, `y`, `z`) to a separate Feature. You MUST semantically model the schema by grouping cohesive properties into a single logical Feature (e.g., "Cartesian Coordinates"). However, "zero abstraction" still applies: within that grouped Feature, you MUST exhaustively document EVERY underlying leaf node, capturing its exact data type, mathematical constraints (fraction-digits, units), defaults, and verbatim RFC text. No constraint detail may be lost or summarized away.

## Step 1: Forensic Audit & Module Decomposition

1. **Parse the Schema:** Read the primary structural schema file (e.g., `*.yang`, `*.yaml`, `*.proto`) and its imports.
2. **Identify Top-Level Trees:** Decompose the high-level structural containers (e.g., `/system-config`, `/users`, `/orders`) into discrete logical groupings.
3. **Establish Epics:** Map these high-level structures directly into Agile "Epics". Do not create the Epic GitHub issue yet. First, document it locally as a markdown file (e.g., `docs/epics/epic-01-name.md`). The Epic file MUST contain:
   - An overarching **System-Level UML Class Diagram** using the Mermaid `namespace` keyword to group the subsystem's child classes under a package boundary (UML Package).
   - A **UML Component** representing the subsystem, specifying its provided/required interfaces and operations.
   - A **System State Machine Diagram** representing the macro-level domain, combining the individual structures and lifecycles that will be broken down into child features.

## Step 2: Exhaustive Feature Extraction

1. **Semantic Feature Breakdown:** Analyze the child containers, choices, or elements. Identify cohesive functional groups (e.g., a "User Profile" containing `first-name`, `last-name`) and map them to a distinct "Feature".
2. **Platform Independence:** Feature specifications MUST be purely functional and platform-independent. Describe *what* the system must do (data to store, validations to enforce, information to display) — never *how* (no framework-specific components, no platform-specific patterns). Platform-specific implementation details are resolved later via the `feature-driven-implementation` skill using implementation profiles (`.pipeline/profiles/<platform>.md`).
3. **Exhaustive Constraint Parsing:** For EVERY leaf node within the grouped feature, analyze and record all structural constraints:
   - `when` and `must` clauses
   - `type` definitions (fraction-digits, string patterns, identityrefs)
   - `units` and `default` values
   - `config false` (operational vs configuration state)
4. **UML Class Diagram:** Every Feature specification MUST include a **UML Class Diagram** (using Mermaid `classDiagram`).
   - **UML Classifier Mapping**: Feature specifications must map to a single primary UML Class or DataType (instead of a subtree of containers) representing the schema node.
   - **Choice/Case Representation**: Model schema `choice` structures as abstract classes or classes with the `<<choice>>` stereotype, and their constituent `case` containers as classes inheriting (`<|--`) from the choice class.
   - **UML Standard Primitive Types**: All attributes in class diagrams must use standard capitalized UML primitives (`String`, `Integer`, `Real`, `Boolean`) instead of YANG or custom types (e.g. `string`, `uint32`, `decimal64`).
   - **Visibility & Multiplicity**: Every attribute/operation must use visibility indicators (`+`/`-`) and standard multiplicities (e.g. `[1]`, `[0..1]`, `[0..*]`).
   - **UML Constraints**: YANG `must` and `when` constraints must map to formal UML `{constraint}` elements or structured notes.
5. **Functional UI Requirements:** Every feature spec MUST explicitly include a `## Functional UI Requirements` section divided into the following structured sub-sections:
   - **1. Test Data Shape (JSON Payload Example)**: A concrete, copy-pasteable JSON payload schema example block showing the exact structure of the test data (including nested objects, leaf types, and default values).
   - **2. Validation & Constraints**: Exhaustive list of ranges, regex patterns, mandatory fields, and conditions (e.g., "must-after", "if-then").
   - **3. Visual Layout & Arrangement**: A detailed, platform-independent description of the visual layout. Detail the visual grouping (e.g., layout sections, information density, visual hierarchy, primary vs secondary rows) without naming framework-specific components.
   - **4. Interactive Flow & States**: Detail system states (read-only, edit, empty, loading, error highlighting).
6. **Acceptance Criteria Translation:** Transform these programmatic constraints and functional UI requirements into exhaustive Given-When-Then Logical Acceptance Criteria. Criteria MUST be platform-independent (e.g., "Given the database contains active records... When the user inspects the node... Then the detail view displays the record attributes"). Do not reference specific UI components or frameworks.
7. **Code Realization Table:** Every feature solution walkthrough/implementation document MUST include a Code Realization Table mapping features/attributes to implemented source files, classes, and functions.
8. **Draft the Feature Specs:** Write each Feature as a local markdown file (e.g., `docs/features/feat-01-name.md`).

## Step 3: Specification Context Injection (Verbatim)

1. **Locate Normative Text:** Find the canonical normative text document (e.g., IETF RFC, 3GPP TS) associated with the schema.
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
   labels: ["feature", "<protocol-name>"]
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
        namespace SubsystemPackage {
            class FeatureClassifier1 {
                +String attributeOne [1]
                -Boolean attributeTwo [0..1]
            }
            class FeatureClassifier2 {
                +Integer attributeThree [0..*]
                +operationOne(input : String) : Boolean [1]
            }
        }
        SubsystemComponent ..> FeatureClassifier1 : realizes
    ```

    ## 4. State Machine Definitions

    ## System State Machine Diagram
    ```mermaid
    stateDiagram-v2
        [*] --> [Initial]
        [High-level module state transitions]
    ```

    ## 5. Specification Context
    [Verbatim schema grouping/container descriptions from the normative specification]

    ## 6. Source References
    YANG Schema: [Schema File Name]
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
        class FeatureClassifier {
            +String primaryAttribute [1]
            -Boolean optionalAttribute [0..1] {constraintText}
            +Integer listAttribute [0..*]
            +doSomething(param : String) : Boolean [1]
        }
    ```

    ## Functional UI Requirements
    ### 1. Test Data Shape (JSON Payload Example)
    ```json
    {
      "example_key": "example_value"
    }
    ```

    ### 2. Validation & Constraints
    - [Field constraints, ranges, patterns]

    ### 3. Visual Layout & Arrangement
    - [Detailed grouping, zoning, typographic hierarchy, and information density guidelines]

    ### 4. Interactive Flow & States
    - [Behavior in read-only vs editable mode, validation error indicators, loading/empty states]

   ## Code Realization Table
   | Feature/Attribute | Source File | Class/Type | Function/Method | Notes |
   |---|---|---|---|---|
   | [Attribute or feature] | [Path to source file] | [Class or type name] | [Function or method name] | [Details] |

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

2. **GitHub Label Bootstrapping:** Run `gh label create "epic" --force` and `gh label create "feature" --force`.

3. **Duplicate Detection (Idempotency Check):**
   - Before creating any issue, run `gh issue list --label "feature" --state "all" --json number,title` and check if an issue with an identical or semantically equivalent title already exists.
   - If a duplicate is found: skip creation, reuse the existing Issue ID for Epic linkage.
   - This ensures the pipeline is safe to re-run without creating duplicate issues.

4. **Feature Generation FIRST:**
   - Execute `gh issue create` for EVERY Feature markdown file first.
   - Example: `gh issue create --title "Feature Title" --body-file docs/features/feat-01.md --label "feature"`
   - **CRITICAL:** Capture the returned GitHub Issue URL/ID from standard output.

5. **Epic Markdown Assembly:**
   - Now that you possess the actual live Issue IDs for all extracted features, inject them into the Epic's Markdown file.
   - Ensure the body of the Epic explicitly lists its child features as a Markdown tasklist referencing the GitHub Issue ID and the absolute GitHub URL of the feature document (relative links like `../features/...` resolve incorrectly on GitHub issues and cause 404 errors). You MUST dynamically determine the remote repository URL by running `git remote get-url origin` and construct the absolute link pointing to the file on the current branch (e.g., `https://github.com/owner/repo/blob/branch_name/docs/features/feat-01.md`):
     `- [ ] #[IssueID] - [Feature Title](https://github.com/owner/repo/blob/branch_name/docs/features/feat-01.md)`

6. **Epic Generation LAST:**
   - Finally, execute `gh issue create` for the Epic markdown file containing the fully resolved tasklist.
