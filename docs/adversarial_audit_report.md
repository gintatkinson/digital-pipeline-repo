# Adversarial Audit Report: Spec-Driven Development Pipeline

This report compiles the exhaustive findings from the adversarial audit of the digital spec-engineering pipeline. It documents **44 systemic bugs, failures, and violations** across the pipeline initialization, specification generation, validation/linter gates, and Git lifecycle. It also identifies the **12+ individual specification files** that were polluted with manual workarounds, and defines a strict **Risk Prevention & Governance** framework to prevent future regressions.

---

## 1. Systemic Bugs, Failures & Violations (44 Items)

The pipeline failures are categorized into five structural layers: Governance & project constitution, Schema specification engineering, Behavioral story modeling, Use case & backlog orchestration, and Verification & linter scripts.

### Category A: Governance & Project Constitution Assumptions (9 Items)
1. **Hardcoded Standards Bodies**: `.pipeline/constitution.md` hardcodes references to standard organizations (`IETF`, `3GPP`, `IEEE`, `ITU-T`, `CAMARA`), preventing the ingestion of private or custom API models.
2. **YANG/ASN.1 File Constraints**: The constitution defines `YANG` and `ASN.1` as default standard modeling formats, failing to account for OpenAPI (JSON/YAML) or Protobuf.
3. **YANG Validation Keywords**: Validation rules in the constitution strictly check for YANG keywords (`when`, `must`, `leafref`, `min-elements`), which are absent in REST/gRPC specifications.
4. **Hardcoded Domain Topologies**: Commit and BDD examples in `.pipeline/constitution.md` refer strictly to network domain topologies (`Node Management`, `termination-point`), creating semantic bias.
5. **Hardcoded Default Branches**: Default branch names are hardcoded to `master` instead of being dynamically resolved from the git configuration.
6. **GitHub Platform Inflexibility**: Enforces dependency on GitHub issue trackers and the `gh` CLI, preventing pipeline portability to GitLab, Gitea, or local backlog files.
7. **Framework & Language Mandates**: `skills/project-constitution/SKILL.md` hardcodes target technologies (`React`, `Flutter`, `.NET`, `TypeScript`, `Dart`, `C#`) as default project structures.
8. **Static Build & Test Tooling**: Hardcodes testing tool assumptions (`Jest`, `Playwright`, `flutter_test`, `npm`, `Vercel`, `Netlify`), failing for Python, Rust, or C++ backends.
9. **Framework-Specific UI Assertions**: Injects framework-specific UI components (`React <Drawer>`, `Flutter showModalBottomSheet`) into generic BDD templates.

### Category B: Schema Specification Engineering Gaps (8 Items)
10. **Hardcoded File Extensions**: `skills/schema-specification-engineering/SKILL.md` strictly audits file extensions (`*.yang`, `*.yaml`, `*.proto`), failing for schema files without standard extensions.
11. **Hardcoded Container Paths**: YANG-specific networking containers (`/globals`, `/tunnels`, `/lsps`, `/rpcs`) are hardcoded as examples for structural decomposition.
12. **Normative Standard Constraints**: Step 1 in the schema spec skill assumes normative source documents are always `IETF RFC` or `3GPP TS` documents.
13. **Isolated UML Classes**: Generates Class Diagrams with isolated classes (no associations/compositions), violating basic object-oriented design standards.
14. **Lack of Composition Mandate**: UML class templates do not mandate parent-child composition representation (`*--`), leading to flat class diagrams.
15. **Choice/Case Omission**: The linter fails to enforce or represent schema `choice` and `case` structures, swallowing nested polymorphic datatypes.
16. **Underspecified Test Data Shape**: Functional UI Requirements lack concrete, structured test data representation, relying on loose prose.
17. **Vague UI Layout Guidelines**: Presentation guidelines are overly abstract, causing LLMs to generate specifications with zero information layout guidelines.

### Category C: Behavioral Story Modeling Gaps (7 Items)
18. **Shallow Sequence Diagrams**: UML Sequence Diagrams in User Stories show actor-to-domain interaction but skip internal calculation, validation, or database/state mutations.
19. **Generic Actor Naming**: Permits generic names (like `actor Actor`) in sequence diagrams, making the flow untraceable.
20. **Untyped Sequence Parameters**: Method signatures in sequence diagrams lack explicit types (e.g. `registerLocation(lat, long)` instead of `(latitude: Decimal64, longitude: Decimal64)`).
21. **Untyped Return Signatures**: Dashed response lines in sequence diagrams lack explicit return types, violating strict OOA/OOD standards.
22. **No Error Handling Paths**: Sequence diagrams skip `alt`/`else` blocks for validation failure paths, assuming only the happy path.
23. **Lack of Computation Delegation**: Fails to delegate mathematical calculations or business rules to helper classes (e.g., calculations are shown inline instead of calling a `Calculator` helper).
24. **Missing Stories for Algorithmic/Derived States**: Mathematical derivations (like calculating speed/heading from a velocity vector) are skipped because story extraction only parses high-level operational chapters.

### Category D: Use Case & Backlog Orchestration Bugs (10 Items)
25. **Title-Only Story Matching**: Use Case mapping runs `gh issue list` querying only titles, leading to false-positive lexical matching.
26. **Open-State Issue Restriction**: Step 3 in Use Case engineering filters issues strictly by `--state "open"`, ignoring closed/completed dependencies and breaking downstream traceability matrices.
27. **Missing Matrix Semantic Justifications**: Realization matrices contain checkbox items with no semantic justification, making mappings opaque.
28. **Thin Alternate Use Case Flows**: Alternate and exception flows are represented as single-step placeholders, leading to low-quality specifications.
29. **Lack of Branching Point Declarations**: Alternate flows do not declare the exact step in the Main Success Scenario from which they branch.
30. **Missing State Guarantees**: Use case exception paths fail to document system rollback states or guarantees.
31. **Silent Ignore of Hallucinated Issues**: `reconcile_backlog.py` silently ignores issue numbers that do not exist on GitHub, allowing hallucinated issues to pollute specification matrices.
32. **Rigid Issue Prefix Stripping**: `reconcile_backlog.py` strips strict prefixes (`epic-`, `feat-`, `us-`, `uc-`), failing if issue titles are named differently.
33. **Static Issue Label Dictionaries**: Reconciler script maps issues to static labels, failing to adapt to custom workflow labels.
34. **GitHub CLI Direct Integration**: Reconcile script relies on direct system-level execution of `gh` commands, causing command failures if GitHub authentication tokens are not present.

### Category E: Verification, Parser & Pipeline Bugs (10 Items)
35. **HTML Render Truncation (The `<|--` Bug)**: Markdown parsers on GitHub interpret the Mermaid inheritance operator `<|--` as an unclosed HTML tag, truncating the remainder of the markdown file body.
36. **Double-Escaped Backticks**: Markdown table generators write backticks as `\\\\``, breaking column formatting in GitHub rendering.
37. **Literal Null-Bytes**: The presence of null bytes inside generated markdown files causes the `gh` CLI to terminate uploads prematurely, truncating issue bodies.
38. **Linter Code Swallowing (Unmatched Quote Bug)**: The parser linter swaps string extraction order. A comment containing a single quote (e.g., inside a URL) causes the quote to remain unmatched, swallowing subsequent blocks of code/schema nodes.
39. **Linter Silent Bypass**: The linter script exits with code 0 and reports 100% coverage if no schema files are present in the directory, masking ingestion failures.
40. **Flat Regex Matching (The "of" Match Bug)**: Linter coverage checking performs simple regex name matching. A common prose word like `of` matches the YANG node `of`, generating false-positive coverage reports.
41. **Hardcoded YANG Ingestion**: `verify_model_coverage.py` only extracts nodes matching YANG patterns (`typedef`, `leaf`, `container`), ignoring OpenAPI and Protobuf syntax.
42. **YANG Ingestion Metaclass Neglect**: Parser regexes fail to extract comments, description blocks, or constraints, evaluating only syntax tokens.
43. **Static GitHub URL Checks**: Matrix verification checks strictly validate links starting with `"https://github.com/"`, failing for self-hosted instances.
44. **No Mermaid State Diagram Validation**: The linter asserts the existence of diagram blocks but fails to validate Mermaid syntax rules (e.g., invalid dotted links), resulting in broken rendering on GitHub.

---

## 2. Individual Specification File Pollutions (12+ Items)

Rather than repairing the pipeline generator templates and linter scripts, past runs manually patched the output specifications in `docs/` to force validation gates to pass. This resulted in the pollution of the following 12+ files:

1. **`docs/epics/epic-01-geo-location.md`**: Manually edited to insert mock UML diagrams and hardcoded issue checklist structures.
2. **`docs/features/feat-01-coordinate-system.md`**: Manually patched with escaped backticks to bypass table rendering errors.
3. **`docs/features/feat-02-geodetic-datum.md`**: Manually edited to match specific YANG leaf configurations and hardcode coordinate system attributes.
4. **`docs/features/feat-03-ellipsoid-location.md`**: Manually modified to add static UI payload blocks.
5. **`docs/features/feat-04-cartesian-location.md`**: Bypassed linter validation by hardcoding reference frame structures.
6. **`docs/features/feat-05-geographic-velocity.md`**: Manually injected velocity parameters to pass coverage constraints.
7. **`docs/user-stories/us-01-register-entity.md`**: Manually edited to mock actor sequence flows.
8. **`docs/user-stories/us-02-kml-altitude.md`**: Patched manually to bypass calculation validation gates.
9. **`docs/user-stories/us-03-virtual-reality.md`**: Manually updated to include static parameters.
10. **`docs/user-stories/us-04-track-velocity-vector.md`**: Injected mock sequence participants to satisfy linter checks.
11. **`docs/use-cases/uc-01-register-core-entity.md`**: Manually modified to hardcode realization matrices.
12. **`docs/use-cases/uc-02-derive-speed-and-heading.md`**: Manually patched to link to incorrect user stories.
13. **`docs/use-cases/uc-03-calculate-displacement.md`**: Hardcoded checklist URLs manually to satisfy absolute URL rules.

---

## 3. Risk Prevention & Governance Framework

To establish a zero-defect specification pipeline, the following governance rules are implemented.

### A. Escaping `<|--` (HTML Rendering Crash)
The Mermaid inheritance operator `<|--` must be escaped or structured to prevent markdown parsers from treating it as an HTML opening tag. 
* **Rule**: All specification templates must use the spaced syntax `<|--` or wrap class definitions strictly inside fenced code blocks. If rendering outside a code block, use the HTML entity equivalent `&lt;|--` to avoid parser truncation.

### B. Quoting Brackets inside Diagram Stereotypes
Mermaid class stereotypes (e.g. `<<choice>>`, `<<case>>`, `<<extend>>`) can break compilation if not properly handled by the parser.
* **Rule**: Stereotypes must be alphanumeric strings bounded by double angle brackets. In templates, they must be represented exactly as `<<choice>>` with no interior spaces or illegal characters. The linter must validate that all stereotypes match standard notation patterns: `<<[a-zA-Z0-9_\-]+>>`.

### C. Absolute URL Enforcement & Realization Matrices
Checkbox linkages in use case realization matrices must not use relative file paths, which break on GitHub issue pages.
* **Rule**: Every link in a checklist must be realization-matrix absolute, utilizing the canonical GitHub URL format: `https://github.com/[org]/[repo]/blob/[branch]/docs/...`
* The linter script `verify_model_coverage.py` must run a regex verification asserting that all checklist items contain a valid, absolute GitHub URL.

### D. Strict Workspace Boundary Controls
Under no circumstances should the specification generator or implementer agents scan adjacent workspaces, read arbitrary local directories outside their designated workspace, or import specifications from outside the repository boundary.
* **Rule**: All source models, reference standards, and schemas must be explicitly copied into the target workspace's `yang/` or `schema/` folder.
* Automated tooling must strictly read from local directories defined in the environment variables or runtime configurations. Bypassing the sandbox to access global system paths or reading other agent worktrees is strictly prohibited.
