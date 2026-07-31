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

Investigation complete (read-only). Target files below. Executed serially.

#### C8a. #276 — module-level env mutation  **[low risk]**

`verify_model_coverage.py` calls `sanitize_github_token_env()` at **line 18, module
level**, and again at line 25 inside `if __name__ == "__main__":`. Any import of the
module therefore pops `GITHUB_TOKEN`/`GH_TOKEN` from the process environment. The
`__main__` call already covers the intended use, so the module-level call is
redundant as well as harmful.

| File | Exact change |
|---|---|
| `skills/spec-orchestrator/scripts/verify_model_coverage.py` | Delete line 18, the bare `sanitize_github_token_env()` call. Keep the function definition and the line-25 call inside `__main__`. |
| `.../parity_auditor/tests/test_env_isolation_issue276.py` | **New.** Set a dummy `GITHUB_TOKEN`, import the module by path, assert the variable survives. Assert the function still sanitises when invoked explicitly, so the fix is not a silent removal of capability. |

Blast radius: none expected. To be confirmed during implementation by checking no
test relies on import-time sanitisation.

#### C8b. #277 — sequence-diagram validation bypass  **[BLOCKED — my risk assessment was wrong]**

> **Revised after implementation.** I assessed this as low risk because
> `docs/user-stories/` is empty. That was incomplete: the bypass is **deliberate and
> test-covered**. Commit `a5de5f8`, *"fix: resolve sequence diagram lifeline false
> positives"*, introduced it together with the regression test
> `test_uml_validator.py::test_bypassed_lifelines_accepted`, which explicitly asserts
> that classifiers ending in those suffixes are accepted.
>
> Removing the bypass makes that test fail. Deleting or weakening it is forbidden by
> `feature-driven-implementation` § 3.8.3, and doing so would reinstate the false
> positives `a5de5f8` was written to eliminate.
>
> Verified: with the bypass removed, `test_bypassed_lifelines_accepted` fails and an
> `actor` lifeline such as `payer : Payer` is reported as undefined.
>
> **The change has been reverted.** `uml.py` is unmodified and the suite is green.
>
> A semantically correct third option exists. `SequenceLifeline.role`
> (`core/models.py:283`) already records whether a lifeline was declared `actor` or
> `participant`, so the exemption could key on **UML role** rather than on a name
> suffix: external `actor` lifelines are not model classes and need no definition,
> while every `participant` must resolve. That honours the constitution's intent and
> removes the arbitrary suffix list. It also contradicts
> `test_bypassed_lifelines_accepted`, which declares `x as "x: InvalidClass"` as an
> `actor` and requires it to error — so that test would need revising too, which
> requires human agreement rather than an agent's judgement.
>
> Options for the human:
> * **A — Keep the bypass.** Close #277 as won't-fix; `a5de5f8` already decided this.
> * **B — Replace suffix exemption with role exemption.** Semantically correct; requires
>   revising `test_bypassed_lifelines_accepted`, which is a deliberate rewrite of an
>   existing regression test and therefore needs explicit approval.
> * **C — Remove the bypass entirely** per #277 as filed. Reinstates the false
>   positives, requires every actor to be a defined class, and contradicts `a5de5f8`.
>
> The tests written for this issue are committed with `xfail` so the work is preserved
> and the suite stays green. They will pass unchanged under option C, and mostly under
> option B.

#### C8b (original assessment, retained for the record)  **[low risk today]**

`uml.py:245` defines `bypass_suffixes = ("Actor", "Calculator", "Provider", "Mapper",
"Manager", "Configurator", "Architect", "Validator", "ValidatorSystem", "System")` and
line 246 skips the registry check for any classifier ending in one. Because a bypassed
class is absent from `global_classes`, the downstream `if rx_cls in global_classes:`
guard also skips **operation** validation for every message sent to it.

Blast radius today is **zero**: `docs/user-stories/` contains 0 files, so this code
path has no live inputs. The fix cannot be validated against real content and will
rest on synthetic fixtures — stated explicitly rather than implied.

| File | Exact change |
|---|---|
| `.../validators/uml.py` | Delete the `bypass_suffixes` tuple at line 245 and the `and not cls_name.endswith(bypass_suffixes)` clause at line 246, so an undefined lifeline classifier always raises. |
| `.../parity_auditor/tests/test_uml_sequence_bypass_issue277.py` | **New.** Synthetic user story whose lifeline classifier `PaymentManager` appears in no class diagram → expect an error. Second case: a message to that lifeline must have its operation validated rather than silently accepted. Include a fixture guard. |

#### C8c. #281 — brittle placeholder detection  **[BLOCKED — needs a decision]**

Confirmed as a live defect, with a consequence that is not mine to choose.

Two detection gaps in `_validate_placeholders_and_links` (uml.py:620-658):
* `PLACEHOLDER_STUBS` omits `[Epic Title]`, `(semantic linkage justification)`, `*(None)*`.
* `if "IssueID" in content` misses `#[EpicID]` — the string `"EpicID"` does not contain
  `"IssueID"`.

Live corpus impact, measured:

| Finding | Count |
|---|---|
| Feature files with an entirely unpopulated `## Parent Epic` (`#[EpicID] - [Epic Title]`) | **8** |
| …of those, already registered on the tracker (`issue_id: 54-58`) | 5 |
| …not yet registered | 3 |
| Of the 8, also using relative `../epics/` links forbidden by `tracker-source-of-truth.md` | 3 |
| Epic issues on the tracker available to link to | **0** |
| `epic` label present | **no** |
| Files in `docs/epics/` | **0** |

**The blocker:** repairing the detector turns the linter red, and the 8 files cannot be
populated correctly because no Epics exist to reference. The linter is green today only
because the detector fails to look.

Options, for the human to choose:

* **A — Fix the detector, file the 8 files as a separate issue, accept a red linter.**
  Honest; the current green is false. But Phase 4 stays blocked until Epics exist.
* **B — Fix the detector and author the missing Epics.** Removes the blocker, but is
  substantial specification work needing human input on Epic boundaries, and is well
  outside this plan.
* **C — Fix the detector, gate only documents carrying `issue_id`.** Semantically the
  closest to #281's actual complaint. Reduces the failure from 8 files to 5 — it does
  **not** eliminate it, because 5 of the 8 are already registered.
* **D — Defer #281** until Epics exist, leaving the detector brittle and recorded.

**DECISION: option A**, authorised by the human ("do all", following the recommendation
of A). Rationale on record: a gate that passes unpopulated specifications is worse than
a gate that is honestly red, and the precedent set by #296 is to file exposed
pre-existing content rather than silently absorb it.

Consequence accepted: `verify_model_coverage.py` will report failures on 8 feature files
until Epics exist. This is the gate working, not a regression.

| File | Exact change |
|---|---|
| `.../validators/uml.py` | In `_validate_placeholders_and_links`: replace the literal `PLACEHOLDER_STUBS` membership test with normalised pattern detection covering `[Epic Title]`, `[Feature Title]`, `(semantic linkage justification)`, `*(None)*` and the existing stubs. Replace `if "IssueID" in content` with a check matching any unresolved `#[...ID]` bracket token, so `#[EpicID]` is caught. |
| `.../parity_auditor/tests/test_placeholder_detection_issue281.py` | **New.** Assert each evasive placeholder is detected, assert `#[EpicID]` is caught, and assert a fully populated document produces no error so the detector is not simply rejecting everything. |

**Revert path**, if option C is preferred later: gate the new detections on the document
declaring `issue_id` in its frontmatter. That reduces failures from 8 files to 5 and is
a single conditional around the new checks.

#### C8d. Follow-up issue for content exposed by C8c
File an issue recording the 8 feature files with unpopulated `## Parent Epic` sections,
the 3 using forbidden relative links, and the absence of any Epic to link to. No file
changes; issue creation only. Mirrors the handling of #296.

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

---

## Part D — Root-cause programme (downstream treated as diagnostic instrument)

**Reframing.** The human clarified that everything under `docs/`, `app_flutter/`,
`web_react/` and `schema/` is disposable downstream output, retained only to source
symptoms and isolate upstream causes across multiple downstream projects. Content is
therefore **never repaired**. Only pipeline code, rules, skills and gates are fixed.

Two consequences for work already completed:

* `EXCLUDED_DIR_NAMES = {"decisions", "designs"}` in `mermaid_syntax_validator.py`
  is **wrong under this model**. It was added to keep the linter green on historical
  records, but those directories are symptom sources and excluding them suppresses
  diagnostic signal — it concealed 13 confirmed non-rendering diagrams. To be removed.
* #296 and #297 were filed by me as content-repair tasks. They are symptom records
  whose root causes are already fixed (#288/#289 and #281 respectively). To be closed
  with root-cause traceability. Closure is authorised by the Product Owner in this
  turn, satisfying `.pipeline/constitution.md:161`.

### The systemic finding

Seven confirmed defects this session are one defect class — **the documented contract
and the enforced contract disagree**: #283, #286, #289, #292, #295, #281, and NEW-1.
Every one was found by a human noticing or by accident. Nothing tests that
documentation matches enforcement.

### D1. NEW-0 — documentation/enforcement contract gate  **[highest value]**

| File | Exact change |
|---|---|
| `tests/rule_contracts.py` | **New.** A registry of `RuleContract` entries pairing each enforced rule with its documentation anchor: rule id, the source file and anchor that enforces it, the rule file and anchor that documents it. |
| `tests/test_rule_contracts.py` | **New.** Four assertions: (a) every registry entry's documentation anchor exists in the named file; (b) every entry's enforcement anchor exists in the named source; (c) **orphan documentation** — every Mermaid rule heading in `rules/platform-independence.md` has a registry entry, which is #289's defect; (d) **orphan enforcement** — every Mermaid parse-error family raised in `parsers/mermaid.py` and `validators/mermaid_syntax_validator.py` has a registry entry, which is NEW-1's defect. Plus a vacuity guard on each scan. |

Scope stated honestly: this covers the **Mermaid syntax contract family** first, where
three instances live. The registry is extensible to other families; it is not a
universal solution and the tests must say so.

### D2. NEW-1 — undocumented relationship-label quoting rule

`parsers/mermaid.py:447` rejects relationship labels containing unquoted spaces or
colons. `rules/platform-independence.md:18` documents only stereotype prohibition and
never mentions quoting. Generators therefore cannot comply.

| File | Exact change |
|---|---|
| `rules/platform-independence.md` | Add a Mermaid relationship-label quoting rule alongside the existing rules. |
| `.../validators/mermaid_syntax_validator.py` | Add the corresponding check so the rule is enforced by the offline gate, not only incidentally by the parser. |
| `.../tests/test_mermaid_syntax_validator_issue288.py` | Extend with a case built from the live `feat-10` symptom. |

### D3. NEW-2 — spec filename uniqueness and format validator
### D4. NEW-3 — multi-downstream symptom aggregator
### D5. Remove `EXCLUDED_DIR_NAMES`

Filed as issues in this turn. D3-D5 implementation is **not** authorised yet; only
issue creation, plus the D1/D2 work above.

### D6. #277 — replace suffix bypass with UML role exemption  **[DECISION: option B, authorised]**

Rationale on record. The suffix list (`Actor`, `Manager`, `System`, …) exempted lifelines
by **name spelling**, so `PaymentManager` passed while `PaymentHandler` did not. Worse,
because an exempt classifier never entered `global_classes`, the downstream
`if rx_cls in global_classes:` guard was also false and **operation-signature validation
was skipped for every message sent to it** — one exemption disabling two checks.

Deleting the bypass outright (option C) was tested and rejected: an ordinary human actor
`payer : Payer` is reported undefined, which is the false-positive class commit `a5de5f8`
existed to remove.

Option B keys the exemption on **UML role**, which the parser already records
(`mermaid.py:620` sets `role` from the `actor|participant` keyword; undeclared lifelines
default to `participant` at line 691). The pipeline's own template already distinguishes
them correctly (`spec-user-story-engineering/SKILL.md:102-104`).

| File | Exact change |
|---|---|
| `.../validators/uml.py` | Replace the `bypass_suffixes` tuple and its `endswith` clause with a role test: exempt `role == "actor"`, require every other lifeline's classifier to be in `global_classes`. |
| `.../tests/test_uml_validator.py` | Rewrite `test_bypassed_lifelines_accepted` to assert the real rule: `actor` lifelines exempt regardless of name, `participant` lifelines required. Retain the `InvalidClass` case, re-declared as a `participant` so it still must fail. Rename to reflect what it tests. |
| `.../tests/test_uml_sequence_bypass_issue277.py` | Remove the four `xfail` markers. Add a case asserting an `actor` is exempt, and one asserting a bogus operation on a `participant` is now caught — the second-order hole. |
| `skills/spec-user-story-engineering/SKILL.md` | Document the actor/participant distinction as the operative rule, so enforcement is paired with documentation in a file an agent may edit. |

**Constitution divergence this creates — flagged, not hidden.**
`.pipeline/constitution.md:41` states *"Every lifeline in a sequence diagram MUST represent
an instance of a defined logical Class or Component."* Option B exempts external actors,
so the implemented rule will be narrower than that sentence. Left unaddressed this becomes
instance #8 of the defect class #298 was built to catch.

The constitution may not be edited by an agent (`AGENTS.md:59`, `project-constitution`
Core Mandate 4). Proposed amendment submitted for human approval, to be applied alongside
the pending line-120 amendment:

> - Every lifeline in a sequence diagram MUST represent an instance of a defined logical
>   Class or Component, **except lifelines declared as external actors (UML `actor`), which
>   represent entities outside the system boundary and are therefore not defined in the
>   structural models.** Every non-actor lifeline MUST resolve to a defined classifier.

Until that is applied, the divergence is recorded in `tests/rule_contracts.py`
`KNOWN_DOC_DIVERGENCES` so it is visible rather than forgotten.

---

## Part E — Constitution amendment protocol

**Finding.** The constitution was never actually locked. `.agents/AGENTS.md:60` forbids
rewriting it *"unless every line of the replacement has been explicitly approved by the
user in the current conversation turn"*; `project-constitution` Mandate 4 forbids
modifying it *autonomously*; line 285 says *"On evolution: Human requests an update.
Agent reads existing, proposes amendments, waits for approval."* Three sanctioned paths.

What was missing was **procedure and audit trail**. Step 7 gave Tier 2 profiles a full
add/update/remove/list lifecycle while Tier 1 had one sentence — the higher-authority
document had the weaker process, so the safe default became refusal and two known
divergences stayed unfixed.

### E1. Phase 1 — build the mechanism  **[COMPLETE]**

| File | Change |
|---|---|
| `.pipeline/constitution-amendments.md` | **New.** Append-only log. Each entry carries Date, Logged, Motivating issue, Approved by (verbatim), Destructive, Line count and resulting SHA-256. Seeded with AMEND-0000 baseline recording the current checksum, and the two pending amendments. |
| `tests/test_constitution_integrity.py` | **New.** 8 assertions. The core one: SHA-256 of the constitution must equal the newest log entry, so any unlogged edit fails the suite. Plus field completeness, approval provenance, `last_updated` agreement, line-count agreement, and Mandate 3's cumulative rule (a non-destructive entry may not reduce line count). |
| `skills/project-constitution/SKILL.md` | Adds **Step 9 — Amending the Functional Constitution**, the missing Tier 1 lifecycle: 9 numbered steps plus hard constraints. Notes the authority already existed. |

Verified with four negative controls rather than a green run: unlogged edit caught by
both checksum and line count, bare `n/a` approval caught, missing required field caught.

### E2. Phase 2 — apply the two pending amendments  **[AWAITING LINE-BY-LINE APPROVAL]**

Not started. `AGENTS.md:60` requires verbatim approval of the replacement text, and
Step 9 item 4 requires that approval to reference the proposed text specifically — a
bare "proceed" to a message containing two proposals is explicitly insufficient and must
be clarified.

Both targets are recorded in `tests/rule_contracts.py` `KNOWN_DOC_DIVERGENCES`:

* `constitution.md:41` — external actor exemption (issue #277)
* `constitution.md:120` — authorization sufficiency (issue #295)

Each will be applied as its own commit, per Step 9's constraint that an amendment be
reviewable in isolation.
