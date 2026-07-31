# Implementation Plan

## Provenance Note (read first)

This plan **replaces** a stale plan describing an unrelated `create_issue.sh` label
task from a prior session.

Parts A and B below were executed **before** being documented here, in violation of
`.agents/AGENTS.md:7` (*Strict Planning Gate*) and `:11` (*Strict Plan Enforcement*).
The agent had read `rules/` and `.pipeline/constitution.md` but had not read
`.agents/AGENTS.md`, and acted on `rules/user-authorization-lock.md`, which treats
the keyword `PROCEED` as sufficient authorization. `AGENTS.md:7` explicitly overrides
that. Part A is already merged and pushed to `main`; Part B is uncommitted.

Retro-approval is requested for A and B. Part C is not started and no file in it has
been touched.

---

## Objective

Resolve the open audit backlog (#276-#294) in the pipeline repository, fixing tooling
and governance defects with TDD, and establish an upstream-only implementation profile
for pipeline tooling that cannot leak into downstream template consumers.

---

## Part A — Executed and pushed (retro-approval requested)

### A1. #282 — `reconcile_backlog.py` missing shebang
Commit `e89836b`, merged via `--no-ff` from `fix/282-reconcile-shebang`.

| File | Exact change |
|---|---|
| `skills/spec-orchestrator/scripts/reconcile_backlog.py` | Insert `#!/usr/bin/env python3` as line 1, above the existing copyright comment. |
| `skills/spec-orchestrator/parity_auditor/tests/test_script_shebang_issue282.py` | **New.** Asserts every executable file in `skills/spec-orchestrator/scripts/` starts with `#!`, and that `.py` ones name a python interpreter. Includes a fixture-discovery guard. |

Evidence: RED 2 failed / 1 passed → GREEN 3 passed. End-to-end, the Phase 4 command
from `spec-orchestrator/SKILL.md:136` now executes as Python instead of emitting
`import: command not found`.

### A2. #290, #291, #292 — CI workflow and Python version drift
Commit `d960394`, merged via `--no-ff` from `fix/290-ci-workflow-config`.

| File | Exact change |
|---|---|
| `.github/workflows/auto_regression_testing.yml` | `push.branches` `[ master ]` → `[ main ]` (#290). Test step `pytest tests/test_repro_cases.py` → `pytest tests/ -q` plus `pytest skills/spec-orchestrator/parity_auditor/tests -q` (#291). Added `strategy.fail-fast: false` and `strategy.matrix.python-version: ['3.9','3.12']`; `setup-python` `with.python-version` `'3.10'` → `${{ matrix.python-version }}` (#292). |
| `skills/spec-orchestrator/parity_auditor/pyproject.toml` | `requires-python` `">=3.8"` → `">=3.9"` (#292). |
| `tests/test_ci_workflow_config.py` | **New.** Parses the workflow and pyproject; asserts the push filter excludes `master` and includes the git default branch, that both suites are invoked, and that CI exercises the declared floor. Handles PyYAML resolving bare `on:` to boolean `True`. |

Evidence: RED 5 failed / 1 passed → GREEN 6 passed. Suites 145 → 151 passed, 1 skipped.

---

## Part B — Uncommitted, awaiting approval to commit

### B1. Upstream-only pipeline-tooling profile and four containment layers

| File | Exact change |
|---|---|
| `.pipeline/upstream/pipeline-tooling.md` | **New.** Implementation profile for pipeline tooling. Frontmatter declares `platform: pipeline-tooling` and `scope: upstream-only`. Records the four approved decisions: Python floor `>=3.9` with CI matrix `['3.9','3.12']`; `ruff` `select = ["F","E9"]` proposed via #293; no coverage percentage, per-issue regression tests instead; blocking gates must be offline. Also records the CMMI rule that agents may not close issues. |
| `.gitattributes` | **New.** Single entry `.pipeline/upstream/ export-ignore`, covering `git archive` and release tarballs. |
| `README.md` | Insert `rm -rf ./.pipeline/upstream` immediately after the existing `cp -RP ./.tmp-pipeline/.pipeline ./` line in the Direct Copy Installation block. One line added, nothing removed. |
| `tests/test_upstream_profile_containment.py` | **New.** Asserts the profile exists in `.pipeline/upstream/`, declares `scope: upstream-only`, is absent from `.pipeline/profiles/`, that the README deletion exists **and appears after** the copy, and that `.gitattributes` marks the directory `export-ignore`. |

Evidence: RED 5 failed / 1 passed → GREEN 6 passed. Suites 151 → 157 passed, 1 skipped.
Containment verified by simulating the README copy sequence into a temp directory:
0 occurrences of `pipeline-tooling.md` reached the simulated downstream tree.

**Proposed commit:** `docs: add upstream-only pipeline-tooling profile with containment`
on branch `docs/upstream-tooling-profile`.

---

## Part C — Not started, no files touched

Sequenced deliberately. C1 and C2 come first because they make autonomous loops safe.
C3-C5 all modify `skills/adversarial-code-auditor/SKILL.md`, so they run strictly
serially per `rules/serial-execution.md` to avoid self-inflicted conflicts.

### C1. #287 — debug-protocol loop cannot terminate
| File | Exact change |
|---|---|
| `skills/debug-protocol/SKILL.md` | In the Step 8 block (lines 72-78), add an explicit reclassify branch: if the Step 0 gate finds the selected issue is not a defect, comment, run `gh issue edit <ID> --remove-label bug --add-label enhancement`, and continue rather than halt. Restate line 78 as: stop when no open `bug`-labelled issue remains that passes the Step 0 defect gate. |
| `skills/adversarial-code-auditor/SKILL.md` | Step E line 176: replace unconditional `--label "bug"` with a severity mapping — Critical/Important → `bug`, Suggestion/Nitpick → `enhancement`. |
| `tests/test_skill_governance.py` | **New.** Assert `debug-protocol/SKILL.md` contains a reclassify instruction and no longer contains the unqualified "ZERO unresolved bugs" terminating clause; assert the auditor's Step E is severity-conditional. |

### C2. #278, #279, #280 — relabel non-defects
No file changes. `gh issue edit <N> --remove-label bug --add-label enhancement` for
each, plus a comment on each explaining the reclassification and citing #287.

### C3. #286 — skeleton bullets contradict Step D check 5
| File | Exact change |
|---|---|
| `skills/adversarial-code-auditor/SKILL.md` | Lines 67-69 and 186-188: `*` bullet markers → `-`. Line 163: regex `^- \*\*(File\|Pillar\|Symptom)\*\*:` → `^[-*] \*\*(File\|Pillar\|Symptom)\*\*:` so either marker passes. |
| `tests/test_skill_governance.py` | Extend: assert the Section 2 skeleton and Section 4 example bullets satisfy the check-5 regex. |

### C4. #288 + #289 — offline Mermaid validation (merged into one change)
| File | Exact change |
|---|---|
| `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/mermaid_syntax_validator.py` | **New.** Implements `IValidator`. Pure Python, no network, no new dependency. Enforces: no `;` in `Note`/message text, balanced fences, valid arrow tokens, participants declared before use. |
| `.../validators/__init__.py` | Register the new validator. |
| `rules/platform-independence.md` | Add the semicolon prohibition alongside the existing Mermaid rules at lines 14-18, making this file the single normative home (#289). |
| `skills/adversarial-code-auditor/SKILL.md` | Line 165: replace check 7 with an executable offline gate invoking the new validator. Line 59: point at `rules/platform-independence.md`. |
| `skills/spec-user-story-engineering/SKILL.md`, `skills/spec-usecase-engineering/SKILL.md`, `skills/schema-specification-engineering/SKILL.md` | Replace the local duplicated Mermaid rule subsets with a pointer to `rules/platform-independence.md`. |
| `.../tests/test_mermaid_syntax_validator_issue288.py` | **New.** RED case is the exact semicolon diagram that broke #283. |

### C5. #283 — wrong `schema_containers` threshold
| File | Exact change |
|---|---|
| `skills/schema-specification-engineering/SKILL.md` | Line 118: terminate the truncated sentence as `len(schema_containers) != 1`, restore the blockquote boundary, and re-establish `2. **Epic File Structure / Template:**` as a top-level list item. Renumber the subsequent duplicate `3.` items at lines 197 and 289. |
| `.../tests/test_schema_container_docs_issue283.py` | **New.** Assert the documented threshold matches `SchemaCardinalityValidator`'s enforced `n == 1`. |

### C6. #284 — duplicate tracker rule
| File | Exact change |
|---|---|
| `rules/tracker-source-of-truth.md` | Merge in the two clauses unique to the sibling file: the `issue_id: <int>` frontmatter mandate and the *Relationship to other rules* section. |
| `rules/github-source-of-truth.md` | **Delete.** |
| `tests/test_rules_consolidation_issue284.py` | **New.** Assert the deleted file is gone, the surviving file carries the migrated clauses, and no live document references the deleted filename. |
| Referencing files | Update any references to the deleted filename. **Exception:** `docs/decisions/adversarial_hardcode_audit_report.md:58` is a historical audit record describing the repository's past state. Per `AGENTS.md:59` and the reasoning recorded in #296, historical records under `docs/decisions/` are not rewritten. The test therefore excludes that directory. |

### C7. #285 — mixed script path prefixes
| File | Exact change |
|---|---|
| `skills/spec-orchestrator/SKILL.md` | Lines 97, 109, 121: `./.agents/skills/spec-orchestrator/scripts/create_issue.sh` → `./skills/spec-orchestrator/scripts/create_issue.sh`. |
| `skills/debug-protocol/SKILL.md` | Line 87: `.agents/skills/debug-protocol/SKILL.md` → `skills/debug-protocol/SKILL.md`. |
| `tests/test_skill_path_references.py` | **New.** Assert no skill or rule document uses the `.agents/skills/` prefix, and — the stronger invariant — that every `skills/...` path referenced in those documents resolves on disk. |

### C8. #276, #277, #281 — Python defects in `parity_auditor`
Genuine `debug-protocol` work, one issue at a time. Target files determined during
each loop's Step 3 and appended to this plan before any edit.

### C9. Governance contradiction — authorization precedence  **[APPROVED, IN PROGRESS]**

Three documents state three different rules for what authorizes a file write:

| Document | Rule stated |
|---|---|
| `rules/user-authorization-lock.md:9` | `PROCEED` in the user's **latest message** is sufficient |
| `.pipeline/constitution.md:120` | `Proceed` / `Approved` / `Approve plan` anywhere in the **current turn sequence** is sufficient |
| `.agents/AGENTS.md:7` | A keyword is **explicitly insufficient**; an approved written plan is required |

**Root cause of the Part A/B violation:** `rules/constitution-first.md` enumerates the
mandatory reads and does **not** list `.agents/AGENTS.md`. An agent that correctly
follows constitution-first therefore never learns the strictest rule exists.

Resolution: unify on the **strictest** reading — an approved plan **and** explicit
approval in the current turn — because under-authorizing merely causes a redundant
question, whereas over-authorizing causes unapproved writes.

| File | Exact change |
|---|---|
| `rules/constitution-first.md` | Add `.agents/AGENTS.md` as required read #1 in the *Required reads* list, ahead of the constitution. Add a hard constraint that it must be read directly by path because it lives in a hidden directory. **Additive only.** |
| `rules/user-authorization-lock.md` | Amend the hard constraint at line 9 to require **both** an approved implementation plan and the keyword. Add a *Precedence* section naming the two co-normative statements and the rule that the strictest applies. **Tightening plus additive; no rule removed.** |
| `.agents/AGENTS.md` | Add a cross-reference inside the *Strict Planning Gate* section pointing to `rules/user-authorization-lock.md` and `.pipeline/constitution.md` § *Strict Planning Mode Gate*, stating all three express one rule. **Additive only.** |
| `tests/test_authorization_precedence.py` | **New.** Assert `constitution-first.md` lists `.agents/AGENTS.md`; assert `user-authorization-lock.md` requires an approved plan and not merely a keyword; assert all three documents cross-reference each other. Includes a fixture-discovery guard. |

**Not modified:** `.pipeline/constitution.md`. Editing it is forbidden by
`AGENTS.md:59` without line-by-line approval, by `project-constitution` skill Core
Mandate 4 (human-authored, agents must not modify autonomously) and Mandate 3
(cumulative, never destructive). The required amendment to its line 120 will be
presented as proposed text for the user to approve and apply. Until then the
`Precedence` sections in the two editable rule files carry the resolution.

**Commit:** `fix: unify authorization precedence across governance documents` on
branch `fix/295-authorization-precedence`.

---

## Governance constraints applying to all parts

- **Never close an issue.** Constitution:161 — `Closed` requires Product Owner
  validation. Agents stop at `Fixed / Resolved`, carried by the
  `status:fixed-resolved` label plus a comment containing pasted evidence.
- **TDD** per `rules/tdd-mandate.md`: a RED test demonstrated failing before any fix.
- **Both suites green** before any issue reaches `Fixed / Resolved`.
- **Blocking gates must be offline** — no third-party network calls in a gate.
- **Push and verify** `git diff origin/main` is empty (`AGENTS.md:19-20`).
- **Serial execution** — one issue fully finished before the next begins.
- Scratch work stays in the system temp path, never in the workspace
  (`AGENTS.md:16-17`).

---

## Approval

Execution is **paused**. Part B is uncommitted and Part C is untouched.
Awaiting explicit approval of this plan before any further file modification.
