---
name: spec-user-story-engineering
title: "Specification User Story Engineering (Behavioral Extraction)"
description: "Extracts operational scenarios from normative specification documents and models them as OOA/OOD User Stories matrixed against existing GitHub features."
category: "architecture"
risk: low
source: custom
version: "1.1"
---

# Specification User Story Engineering (Behavioral Extraction)

This skill enables a sub-agent to autonomously read a normative specification document (e.g., IETF RFC, 3GPP TS, CAMARA API Doc) and extract its behavioral deployment scenarios into pure Behavior-Driven Development (BDD) User Stories modeled according to Object-Oriented Analysis and Design (OOA/OOD) principles, linking them dynamically to structural features already defined in the GitHub repository.

## Execution Trigger
You should invoke this skill ONLY after the structural Features have been extracted using the `schema-specification-engineering` skill.

## Step 1: Context Ingestion (Operational Text)
1. Ingest the target normative specification document.
2. **IGNORE** the structural schemas (e.g., YANG, OpenAPI, Protobuf) and normative schema definitions.
3. Target and analyze the following operational chapters:
   - **Introduction & Applicability**
   - **Deployment Scenarios**
   - **Operational Considerations**
   - **Security Considerations**

## Step 2: Behavioral Modeling (OOA/OOD User Story Extraction)
For every distinct deployment scenario found, model it as a formal User Story integrated with OOA/OOD principles.
1. Identify the Actor/Role (the object or entity initiating the action).
2. Formulate the core scenario using strict BDD syntax mapped to object interactions:
   - `Given` (Precondition object state)
   - `When` (Triggering message or event)
   - `Then` (Postcondition object state)
   - Or standard format: `As an [Actor], I need to [Action/Message] so that [Outcome/State Change].`
3. Map the story to specific Domain Objects (the structural schema entities affected).

## Step 3: The Cross-Cutting Matrix (Feature Linking)
A User Story requires technical building blocks (Domain Objects/Features) to function. You must find the blocks that have already been built.
1. Execute `gh issue list --label "feature" --state "open" --json number,title` to pull the existing structural inventory.
2. Analyze the titles/scopes of those issues.
3. Determine exactly which of those `#IssueID`s are prerequisites for your extracted User Story.
4. Construct a `## Required Features` matrix in your document containing a markdown tasklist of these intersecting links referencing BOTH the Issue ID and the absolute GitHub URL of the feature document (relative links like `../features/...` resolve incorrectly on GitHub issues and cause 404 errors). You MUST dynamically determine the remote repository URL by running `git remote get-url origin` and construct the absolute link pointing to the file on the current branch (e.g., `- [ ] #41 - [Feature 01 Title](https://github.com/owner/repo/blob/branch_name/docs/features/feat-01.md)`).

## Step 4: Markdown Generation
Create a new file in `docs/user-stories/us-[XX]-[name].md` (zero-padded, dash-separated, e.g., `us-01-earth-wgs84.md`). Format strictly:

```markdown
---
title: "[User Story Title]"
type: "user-story"
spec_source: "[Spec Reference]"
---

# User Story: [Title]

## Domain Object Mapping
- **Primary Domain Objects:** [List affected structural schema entities]
- **Actor/Role:** [The object/entity initiating the action]

## BDD Scenario (OOA/OOD Realization)
**Given** [Initial system/object state]
**When** [Triggering action/event/message]
**Then** [Resulting system/object state]

*(Alternatively)*
**As an** [Actor]
**I need to** [Action]
**So that** [Outcome/State Change]

## Operational Context
[Verbatim operational constraints or deployment scenarios quoted from the specification]

## Required Features Matrix
- [ ] #[IssueID] [Feature Title]
- [ ] #[IssueID] [Feature Title]

## Source References
YANG Schema: [Link to structural schema, e.g., ietf-geo-location@2022-02-11.yang](https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang)
Normative Specification: [Link to normative specification, e.g., RFC 9179 Geographic Location](https://datatracker.ietf.org/doc/rfc9179/)
```

## Step 5: Zero-Fault GitHub Synchronization
1. Commit and push the Markdown files to the remote repository.
2. You MUST verify the `user-story` label exists in the repository. Run `gh label create "user-story" --force`. Do not bypass this.
3. **Duplicate Detection:** Before creating, run `gh issue list --label "user-story" --state "all" --json number,title` and check if an issue with an identical or semantically equivalent title already exists. If found, skip creation and reuse the existing Issue ID.
4. Create the issue natively in GitHub. You MUST explicitly bind the label:
   `gh issue create --title "[User Story Title]" --body-file [path/to/markdown.md] --label "user-story"`
5. Verify the creation and return the generated GitHub URLs to the Orchestrator or User.
