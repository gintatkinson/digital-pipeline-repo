"""Regression tests for CI workflow configuration defects.

Covers:
  #290 - push trigger filtered on ``master`` while the default branch is ``main``,
         so pushes to the default branch triggered no run at all.
  #291 - the only test step ran ``pytest tests/test_repro_cases.py``, so 30 of 31
         test files and all 116 parity_auditor tests never executed in CI, yet the
         check reported green.
  #292 - ``requires-python`` (>=3.8), the CI pin (3.10) and the sole installed
         interpreter (3.9.6) all disagreed, so the declared floor was never
         exercised and post-3.9 syntax could pass CI while breaking local runs.
"""

import os
import re
import subprocess

import pytest
import yaml

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
WORKFLOW = os.path.join(REPO_ROOT, ".github", "workflows", "auto_regression_testing.yml")
PYPROJECT = os.path.join(
    REPO_ROOT, "skills", "spec-orchestrator", "parity_auditor", "pyproject.toml"
)

PARITY_TESTS = "skills/spec-orchestrator/parity_auditor/tests"


def _load_workflow():
    with open(WORKFLOW, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def _triggers(wf):
    """PyYAML resolves the bare key ``on`` to boolean True under YAML 1.1."""
    if "on" in wf:
        return wf["on"]
    return wf[True]


def _push_branches(wf):
    push = _triggers(wf).get("push") or {}
    return list(push.get("branches") or [])


def _run_blocks(wf):
    blocks = []
    for job in wf.get("jobs", {}).values():
        for step in job.get("steps", []) or []:
            if isinstance(step, dict) and step.get("run"):
                blocks.append(step["run"])
    return blocks


def _ci_python_versions(wf):
    """Every python version the workflow could run, from matrix or a literal pin."""
    versions = set()
    for job in wf.get("jobs", {}).values():
        matrix = (job.get("strategy") or {}).get("matrix") or {}
        for key, value in matrix.items():
            if "python" in key.lower() and isinstance(value, list):
                versions.update(str(v) for v in value)
        for step in job.get("steps", []) or []:
            if not isinstance(step, dict):
                continue
            pinned = (step.get("with") or {}).get("python-version")
            if pinned and "matrix" not in str(pinned):
                versions.add(str(pinned))
    return versions


def _declared_python_floor():
    with open(PYPROJECT, "r", encoding="utf-8") as fh:
        match = re.search(r'requires-python\s*=\s*"[><=~!]*\s*([0-9]+\.[0-9]+)', fh.read())
    assert match, "could not parse requires-python from pyproject.toml"
    return match.group(1)


# --------------------------------------------------------------------------- #
# Guard: the fixtures must find real content, or these tests prove nothing.
# --------------------------------------------------------------------------- #

def test_workflow_and_pyproject_are_discoverable():
    assert os.path.isfile(WORKFLOW), f"workflow not found at {WORKFLOW}"
    assert os.path.isfile(PYPROJECT), f"pyproject not found at {PYPROJECT}"
    assert _run_blocks(_load_workflow()), "no run steps parsed from the workflow"


# --------------------------------------------------------------------------- #
# #290 - push trigger must reference a branch that exists
# --------------------------------------------------------------------------- #

def test_push_trigger_does_not_reference_master_issue290():
    branches = _push_branches(_load_workflow())
    assert "master" not in branches, (
        f"push trigger references a non-existent 'master' branch: {branches}. "
        "The default branch is 'main', so this filter matches nothing and CI "
        "silently never runs on push."
    )


def test_push_trigger_targets_the_default_branch_issue290():
    try:
        ref = subprocess.check_output(
            ["git", "symbolic-ref", "refs/remotes/origin/HEAD"],
            cwd=REPO_ROOT, stderr=subprocess.DEVNULL, text=True,
        ).strip()
        default_branch = ref.rsplit("/", 1)[-1]
    except (subprocess.CalledProcessError, OSError):
        pytest.skip("origin/HEAD not resolvable in this environment")

    branches = _push_branches(_load_workflow())
    assert default_branch in branches, (
        f"default branch '{default_branch}' is absent from the push filter {branches}, "
        "so merges to it receive no regression validation."
    )


# --------------------------------------------------------------------------- #
# #291 - CI must run the repository's test suites, not one file
# --------------------------------------------------------------------------- #

def test_ci_runs_the_root_test_suite_issue291():
    joined = "\n".join(_run_blocks(_load_workflow()))
    assert re.search(r"pytest\s+tests/(\s|$|-)", joined), (
        "no CI step runs the root suite as a directory ('pytest tests/'). "
        "Running a single file means a green check does not mean the tests passed."
    )


def test_ci_runs_the_parity_auditor_suite_issue291():
    joined = "\n".join(_run_blocks(_load_workflow()))
    assert PARITY_TESTS in joined, (
        f"no CI step runs the parity_auditor suite ({PARITY_TESTS}); "
        "116 tests never execute in CI despite the package being pip-installed."
    )


# --------------------------------------------------------------------------- #
# #292 - declared floor, CI pin and tested runtime must be reconciled
# --------------------------------------------------------------------------- #

def test_ci_exercises_the_declared_python_floor_issue292():
    floor = _declared_python_floor()
    ci_versions = _ci_python_versions(_load_workflow())
    assert floor in ci_versions, (
        f"pyproject declares a floor of Python {floor} but CI runs {sorted(ci_versions)}. "
        "The declared minimum is never exercised, so it is an unverified claim."
    )
