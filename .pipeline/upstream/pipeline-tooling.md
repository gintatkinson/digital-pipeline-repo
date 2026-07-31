---
title: "Implementation Profile — Pipeline Tooling (UPSTREAM ONLY)"
project: "Digital Systems Engineering Pipeline"
tier: implementation
platform: pipeline-tooling
scope: upstream-only
created: "2026-07-31"
last_updated: "2026-07-31"
---

# Implementation Profile: Pipeline Tooling

> **UPSTREAM ONLY.** This profile governs the pipeline repository's own tooling —
> the Python scripts and Markdown governance documents that generate and validate
> specifications. It is **not** an application platform profile.
>
> It MUST NOT be copied into downstream projects. See *Upstream-Only Scoping* below.
> Read alongside `.pipeline/constitution.md` (functional layer).

## Platform & Stack

- **Target:** this repository's own tooling. `scripts/`, `skills/*/scripts/`,
  `skills/spec-orchestrator/parity_auditor/`, plus the Markdown under
  `rules/`, `skills/` and `.pipeline/`.
- **Python floor:** `>=3.9`. This is the empirically verified runtime — the
  development machine exposes only bare `python3` at 3.9.6, and a probe for
  `python3.9` through `python3.13` finds no versioned binaries.
  > **3.9 is end-of-life (October 2025.)** The floor matches reality rather than
  > endorsing it. Migration to 3.12 is tracked in issue #294. Do not raise the
  > floor before that issue lands, or every local invocation breaks.
- **CI matrix:** `['3.9', '3.12']` with `fail-fast: false` — the floor plus a
  forward version, so post-3.9 syntax is caught before it reaches `main`.
- **Runtime dependencies:** `PyYAML>=6.0` and `pyang` (`requirements.txt`).
  `parity_auditor` additionally declares `pytest>=8.3.5` and `pyyaml>=6.0.3`.
- **Forbidden:** new third-party runtime dependencies in `parity_auditor`. CI
  installs only `pytest` and `pyyaml`, so anything further breaks the job.
- **Forbidden:** network egress inside any blocking validation gate. See
  *Validation Gates* below.
- `scripts/` and `skills/*/scripts/` SHOULD be standard-library only.
- `parity_auditor` uses a `src/` layout with setuptools and exposes the console
  entry point `parity-auditor = parity_auditor.cli:main`.

## Coding Standards

- Validators implement `IValidator` from `validators/base.py` and are registered
  in `validators/__init__.py`.
- Parsers live in `parsers/`, shared dataclasses in `core/models.py`, and all
  filesystem access goes through `core/workspace.py`.
- Any file in a scripts directory carrying the executable bit MUST begin with a
  `#!` interpreter directive. A file marked executable without one is re-parsed
  by `/bin/sh` on direct invocation and fails with ENOEXEC.
  Enforced by `parity_auditor/tests/test_script_shebang_issue282.py`.
- Type hints use `typing` imports (`List`, `Optional`, `Dict`) rather than PEP 604
  unions or builtin generics, to hold the 3.9 floor.
- **Linter:** none configured at time of writing. Adoption of `ruff` with
  `select = ["F", "E9"]` — real-bug rules only, style families deliberately
  excluded — is proposed in issue #293. Until that lands, tests are the only
  static gate.

## Testing Mandates

- **Two suites. Both MUST be green before any issue reaches `Fixed / Resolved`:**
  ```bash
  python3 -m pytest tests/ -q                                          # root suite
  python3 -m pytest skills/spec-orchestrator/parity_auditor/tests -q   # package suite
  ```
- TDD per `rules/tdd-mandate.md`. Every fix ships a RED test that names the
  defect and is demonstrated failing before the fix is written.
- **Regression traceability:** the issue number MUST appear in the test file name
  or the test function name, e.g. `test_script_shebang_issue282.py` or
  `test_ci_runs_the_root_test_suite_issue291`. This is the coverage gate.
- **Fixture guard mandate:** any test that iterates over discovered files MUST
  include a companion assertion proving the discovery found something. A test
  that passes by discovering nothing is worse than no test.
- **`PYTHONDONTWRITEBYTECODE=1` is mandatory when running tests.** macOS system Python
  caches `.pyc` under `~/Library/Caches/com.apple.python/`, *outside* the repository, so
  clearing `./tests/__pycache__` has no effect. Because `.pyc` invalidation keys on mtime
  and size, an edit that does not change a file's byte length can leave stale bytecode in
  place — a test then passes or fails against source no longer on disk. This invalidates
  negative-control probes, which are the only evidence that a gate can actually fail. Set
  in CI job `env`; set it locally too. See issue #302.
- **No coverage percentage threshold.** Deliberate. The observed failure mode in
  this repository is specific defects escaping, not low aggregate coverage — a
  percentage gate would have prevented none of issues #276 through #294, and on a
  tooling repository it is trivially gamed by importing modules. Measure coverage
  for information if desired, but do not gate on it. The per-issue regression
  rule above is the gate with teeth.

## Validation Gates

- Blocking gates MUST be **offline and dependency-free**. A gate that calls a
  third-party service fails when that service is down or rate-limits, blocking
  work for reasons unrelated to correctness — the same pathology as issue #282,
  where a mandatory gate hard-failed for an unrelated reason.
- Sending specification content to a third-party renderer or API for validation
  is additionally a confidentiality concern and is not permitted in a gate.
- Network-dependent checks are allowed only as **optional, non-blocking**
  developer smoke checks, never as a condition of filing or merging.
- Mermaid syntax validation is therefore implemented in pure Python inside
  `parity_auditor/validators/`, enforcing the rules consolidated in
  `rules/platform-independence.md`. Tracked in issues #288 and #289.

## Build & Deployment

- No build artifact. Install editable for development:
  ```bash
  pip install -e skills/spec-orchestrator/parity_auditor
  ```
- CI is `.github/workflows/auto_regression_testing.yml`. It triggers on
  `pull_request`, on `push` to `main`, and on `issues` labelled `bug` or
  `feature`.
- **Never rely on git hooks for gating.** `scripts/setup_git_hooks.py`
  deliberately *removes* `pre-commit` and `pre-push` hooks to prevent
  auto-triggered compiler runs. Gates are explicit commands or CI steps.
- Commit format per `.pipeline/constitution.md` § *Commit Format*:
  `fix:`, `feat:`, `test:`, `refactor:`, `chore:`.
- Branches per constitution § *Branch Strategy*: `feat/<issue-number>-<description>`
  or `fix/<issue-number>-<description>`, merged `--no-ff` and deleted after merge.

## Security & Ops

- Secret scanning: `.pipeline/scripts/verify_secret_leak.py`.
- `verify_model_coverage.py` strips placeholder `GITHUB_TOKEN` / `GH_TOKEN`
  values before shelling out to `git` or `gh`; preserve that behaviour.
- No credentials, tokens or absolute developer paths in committed files.

## Issue Lifecycle

Per `.pipeline/constitution.md` § *CMMI Level 3 & Scrum Issue Lifecycle Rules*:

- An agent may take an issue as far as **`Fixed / Resolved`** — development
  complete, both suites green, merged to `main`, evidence pasted on the issue.
- **`Closed` is unreachable by an agent.** It requires explicit Product Owner
  validation. Agents MUST NOT close issues.
- This repository has no Projects board, so the state is carried by the
  `status:fixed-resolved` label.
- This overrides `debug-protocol` Step 7 and `feature-driven-implementation`
  Step 5.5, both of which instruct the agent to close the issue. The
  constitution is Tier 1 and takes precedence.

## Upstream-Only Scoping

This profile must never reach a downstream project. The leak vector is concrete:
README *Direct Copy Installation* runs `cp -RP ./.tmp-pipeline/.pipeline ./`, a
wholesale recursive copy, and the GitHub template route copies the entire tree.

Four layers enforce containment:

1. **Location.** This file lives in `.pipeline/upstream/`, never
   `.pipeline/profiles/`. The documented discovery command is
   `ls .pipeline/profiles/`, so a downstream agent enumerating platforms never
   sees it.
2. **Install.** The README Direct Copy block deletes `./.pipeline/upstream`
   immediately after copying `.pipeline`.
3. **Archive.** `.gitattributes` marks `.pipeline/upstream/ export-ignore`,
   covering `git archive` and release tarballs.
4. **Enforcement.** `tests/test_upstream_profile_containment.py` asserts all
   three layers above, including that the README deletion appears *after* the
   copy. Prose exclusions rot; this test fails if any layer is removed.

Anything else that is upstream-only belongs in `.pipeline/upstream/` for the
same reason.
