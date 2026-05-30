---
name: feature-driven-implementation
description: Guides the serial, interactive implementation of Agile features and automated lifecycle closure of GitHub issues and parent Epics.
risk: low
source: custom
---

# Feature-Driven Autonomous Delivery & Closure

Use this skill to execute the end-to-end implementation lifecycle for prioritized Agile features and ensure complete automated closure of feature issues, walkthrough updates, and parent Epics.

## Core Mandates

1. **Serial Execution:** strictly implement **one feature at a time**. Do not start feature N+1 until feature N is completely verified, merged, documented, and closed.
2. **The Grill Approval:** create an implementation plan and obtain explicit human approval BEFORE modifying any source files.
3. **Traceability:** all closed issues MUST have a closing comment referencing the relative path or GitHub URL of the committed solution walkthrough.
4. **Agentic Epic Closure:** when all constituent features of an Epic are closed, the agent must check off the items in the local Epic markdown, update the Epic issue's body on GitHub, and close the Epic issue itself.
5. **No Browser Automation:** All web UI verification must be performed manually. Do not use automated browser subagents (`browser_subagent`) or headless testing for UI verification.
6. **GitHub as Source of Truth:** Do not rely on local files or checklist documentation for feature definitions or backlog status as they may be contaminated or contain broken links. Always query the official GitHub repository issues using `gh` CLI commands as the canonical source of truth.
7. **Cumulative Walkthroughs & Document Integrity:** When writing or updating living artifacts (such as implementation plans, task lists, and verification walkthroughs), you MUST NOT perform destructive overwrites. Always read the existing file first. When adding support for a new feature or sub-feature, append or merge the details into the existing document so that the historical record of prior feature deliveries and verification instructions remains fully intact. Do not narrow your focus to the immediate scope at the expense of the overall system specifications or historical audit trail.
8. **Validation Isolation & Separate Subagent Audit:** To prevent confirmation bias, missing link/UUID bugs, and documentation mismatches, the primary agent MUST NOT self-verify database changes or documentation links without a strict checklist. The Orchestrator MUST dispatch a separate **Validator Subagent** (or Spec Reviewer) if available. If running in a single-agent context where subagent spawning is unavailable, the agent MUST perform a strict, isolated self-audit (Step 4.4 fallback) verifying that every UUID and link target referenced in the walkthrough resolves and exists in the unified database.

---

## Step-by-Step Workflow

### Step 1: Backlog & Dependency Mapping
1. Analyze `docs/epics/` and `docs/features/` to determine feature dependencies.
2. Map the backlog queue in order of base dependencies first.
3. Create a local tracking file (e.g., `task.md`) to manage current tasks.

### Step 2: Checkout & Plan Review ("The Grill")
1. Checkout a dedicated feature branch from `master`:
   ```bash
   git checkout -b feat/<N>-<short-description>
   ```
2. Verify the feature target platform (`platform` field in frontmatter) and create/update `implementation_plan.md` outlining a **complete vertical slice**:
   - **Database Layer (Test Data):** Specific updates to the unified database loaded with test data, including edge cases.
   - **Logic & Parser Layer:** Type definitions, validation schemas, and hooks to wire the parser into the main application logic flow.
   - **UI & Presentation Layer:** The visual component, layout changes, styles, and data bindings to render the new attributes.
   - **Verification Plan:** Detailed manual validation instructions, compiler checks, and tests.
3. Present the plan to the user and wait for explicit approval.

### Step 3: Execution & Build (Vertical Slice Mandate & Code Audits)
1. **No Handover Trust:** Never assume previous phases or turns implemented a portion of the code correctly based on summaries. Explicitly open and check the source code files in all relevant directories.
2. **Implement Full Vertical Slice:** Implement the changes strictly based on the approved plan. Do not stop at validation utilities or unit tests. You MUST implement the full vertical slice:
   - **1. Database Layer:** Update/extend the unified database with test data records containing the new properties.
   - **2. Parser/State:** Hook the normalization and validation rules into the main data loader/router pipelines.
   - **3. UI Components:** Update components to retrieve, format, style, and visually present the properties to the user.
3. **Double-Check Code Presence:** Before proceeding to verification, perform explicit grep or file-reading checks of the modified UI files to guarantee that all presentation code actually exists in the files.
4. Maintain strong typing, domain-driven design conventions, and strict schema compliance.
5. Ensure no linting, type-checking, or compilation errors are present.

### Step 4: Verification & Testing (Human & Assertion-Based Verification)
1. **Assertion-Based Automation:** When writing or updating widget/unit tests, do not rely on basic smoke tests that only verify the app launches. Add explicit assertions that query the rendering tree for the presence of the new fields or text tokens.
2. Run local tests or build checks (e.g., `npm run lint`, `npm run build`, `flutter analyze`).
3. Provide **precise, step-by-step human manual testing instructions** in the verification section. The instructions must guide the user on exactly what commands to run, which page/element to navigate to, what actions to perform, and what visual output to inspect in the browser or client to verify that the implementation is 100% correct.
4. **Independent Subagent Validation Check (or Single-Agent Fallback Self-Audit):** 
   - **Multi-Agent Mode:** Dispatch a separate **Validator Subagent** to read the draft `walkthrough.md` / `feat-<Issue_Number>-solution.md` and cross-reference every referenced UUID, link, and port ID. The Validator subagent must independently locate these elements in the unified database to confirm they exist and match the UI navigation targets. Fail the validation step if there is any mismatch.
   - **Single-Agent Fallback:** The agent must step out of the implementation context and systematically audit its own draft `walkthrough.md` / `feat-<Issue_Number>-solution.md`. Perform exact regex and grep lookups to verify that every single UUID, link, and port ID referenced in the walkthrough exists verbatim in the unified database. Document the results of this check explicitly before requesting user approval.
5. Apply any feedback iteratively on the feature branch.

### Step 5: Release & Closure (CRITICAL)
1. Merge the feature branch into `master` after explicit acceptance:
   ```bash
   git checkout master
   git merge feat/<N>-<short-description>
   ```
2. Create or update a cumulative solution walkthrough document under `docs/designs/feat-<Issue_Number>-solution.md` summarizing the changes, testing, and validations. Do not delete or overwrite sections for previously implemented sub-features or related components. Ensure the document is a cumulative record of all changes, maintaining a 100% scope perspective to deliver 0-defect verification instructions.
   > [!IMPORTANT]
   > **DO NOT USE THE FEATURE INDEX NUMBER** (e.g. 24 for Feature 24) in the solution filename if the GitHub Issue Number is different (e.g. 82). The solution file name MUST strictly use the GitHub Issue Number (e.g. `feat-82-solution.md`).
   > 
   > **ZERO-TRUST COLLISION CHECK:** Before updating or creating this file, search the repository and Git history for the filename `feat-<Issue_Number>-solution.md` to check its existing content. If it exists, read it first and append/merge the new changes rather than overwriting. If there is a filename mismatch or conflict, alert the user and resolve the naming conflict immediately.
3. Commit and push the solution document:
   ```bash
   git add docs/designs/feat-<Issue_Number>-solution.md
   git commit -m "docs: release solution walkthrough for issue #<Issue_Number>"
   git push origin master
   ```
4. Close the feature issue on GitHub using `gh` CLI, embedding a comment pointing to the committed solution document:
   ```bash
   gh issue close <Issue_Number> --comment "Implemented in master. Solution Walkthrough: https://github.com/<owner>/<repo>/blob/master/docs/designs/feat-<Issue_Number>-solution.md"
   ```
5. Update the local parent Epic markdown checklist:
   - Mark the completed feature as completed (`[x]`).
   - Push the updated Epic markdown file.

### Step 6: Agentic Epic Closure (CRITICAL)
1. Inspect the local Epic checklist (`docs/epics/epic-<ID>-<name>.md`).
2. If **all** features listed in the Epic checklist are checked off (`[x]`):
   - Update the GitHub Epic issue body with the completed task list.
   - Close the Epic issue on GitHub using the `gh` CLI:
     ```bash
     gh issue close <Epic_Issue_Number> --comment "Epic completed. All constituent features successfully delivered and verified."
     ```
3. Delete the local and remote feature branch:
   ```bash
   git branch -d feat/<N>-<short-description>
   ```
