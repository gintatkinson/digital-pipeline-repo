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
2. **Identify Top-Level Trees:** Decompose the high-level structural containers (e.g., `/globals`, `/tunnels`, `/lsps`, `/rpcs`) into discrete logical groupings.
3. **Establish Epics:** Map these high-level structures directly into Agile "Epics". Do not create the Epic GitHub issue yet. First, document it locally as a markdown file (e.g., `docs/epics/epic-01-name.md`).

## Step 2: Exhaustive Feature Extraction

1. **Semantic Feature Breakdown:** Analyze the child containers, choices, or elements. Identify cohesive functional groups (e.g., a "Velocity Vector" containing `v-north`, `v-east`, and `v-up`) and map them to a distinct "Feature".
2. **Platform Independence:** Feature specifications MUST be purely functional and platform-independent. Describe *what* the system must do (data to store, validations to enforce, information to display) — never *how* (no framework-specific components, no platform-specific patterns). Platform-specific implementation details are resolved later via the `feature-driven-implementation` skill using implementation profiles (`.pipeline/profiles/<platform>.md`).
3. **Exhaustive Constraint Parsing:** For EVERY leaf node within the grouped feature, analyze and record all structural constraints:
   - `when` and `must` clauses
   - `type` definitions (fraction-digits, string patterns, identityrefs)
   - `units` and `default` values
   - `config false` (operational vs configuration state)
4. **UML Class Diagram:** Every Feature specification MUST include a **UML Class Diagram** (using Mermaid `classDiagram`) illustrating the domain object class structure, attributes with types, and relationships (aggregations, compositions, inheritances) representing the schema container. **Isolated classes are strictly prohibited.** Every class diagram must show relationships to parent or child containers using composition/aggregation lines (using symbols like `*--`, `o--`, `<|--`, `--`, or `-->`) to map nested containers and choice/case structures.
5. **Functional UI Requirements:** Every feature spec MUST explicitly include a `## Functional UI Requirements` section detailing:
   - The data that must be stored and retrievable, including a copy-pasteable JSON payload shape placeholder representing the complete structure.
   - The validation logic that must be enforced (constraints, ranges, patterns).
   - Platform-independent layout arrangement guidelines (e.g. specifying logical grouping, field order, and presentation hierarchy such as displaying all coordinates in a grouped detail view, without referencing framework-specific components or grids like React, HTML inputs, CSS flexbox, etc.).
6. **Acceptance Criteria Translation:** Transform these programmatic constraints and functional UI requirements into exhaustive Given-When-Then Logical Acceptance Criteria. Criteria MUST be platform-independent (e.g., "Given the database contains active records... When the user inspects the node... Then the detail view displays the record attributes"). Do not reference specific UI components or frameworks.
7. **Draft the Feature Specs:** Write each Feature as a local markdown file (e.g., `docs/features/feat-01-name.md`).

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

2. **File Structure / Template:** Every feature specification markdown file MUST follow this exact section structure and ordering:
   ```markdown
   # Feature: [Feature Title]

   ## Description
   [Functional description of the feature]

   ## UML Class Diagram
   ```mermaid
   classDiagram
       ParentContainer *-- ChildContainer : contains
       class ParentContainer {
           +string parentAttribute
       }
       class ChildContainer {
           +int childAttribute
       }
   ```

   ## Functional UI Requirements
   ### Data Shape & JSON Payload
   ```json
   {
     "placeholder_key": "placeholder_value"
   }
   ```

   ### Validation Logic
   - Validation rule 1...

   ### Layout & Presentation Guidelines
   - [Platform-independent layout specifications detailing how the elements are grouped and ordered visually without specifying any platform-specific rendering framework]

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
   Structural Schema: [schema-filename](link-to-schema)
   Normative Specification: [specification-name](link-to-specification)
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
