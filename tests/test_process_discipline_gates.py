"""Gates against the process failures recorded during this session.

Each test below corresponds to a specific thing that went wrong, and would have caught
it mechanically rather than relying on someone noticing. They are grouped here because
they share a cause: an obligation was recorded in prose and then not performed, and
prose does not fail a build.

Sources for each are named inline. Nothing here is hypothetical — every one of these
happened.
"""

import os
import re

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PLAN = os.path.join(REPO_ROOT, "implementation_plan.md")


def _plan():
    with open(PLAN, "r", encoding="utf-8") as fh:
        return fh.read()


def test_the_plan_exists():
    """Guard: three assertions below scan it, and a missing file passes them all."""
    assert os.path.isfile(PLAN), f"{PLAN} missing; the scans below would be vacuous"
    assert len(_plan()) > 5000, "implementation_plan.md is implausibly short"


# --------------------------------------------------------------------------- #
# 1. "Needs its own issue" must carry an issue number.
#
# implementation_plan.md Part K recorded: "109 committed files contain
# /Users/perkunas ... Needs its own issue." No issue was filed, for hours, across
# several planning cycles. The note stood in for the action.
# --------------------------------------------------------------------------- #

_NEEDS_ISSUE = re.compile(
    r"^(?P<line>.*\bneeds?\s+(?:its\s+own\s+)?issue\b.*)$", re.IGNORECASE | re.MULTILINE
)


def test_every_needs_an_issue_note_cites_one():
    matches = list(_NEEDS_ISSUE.finditer(_plan()))
    assert len(matches) >= 1, "No 'needs issue' notes found in implementation_plan.md"
    unresolved = []
    for match in matches:
        line = match.group("line")
        if not re.search(r"#\d{2,}", line):
            unresolved.append(line.strip()[:110])
    assert not unresolved, (
        "the plan records work as needing its own issue without citing one. A note is "
        "not a tracker entry, and rules/tracker-source-of-truth.md makes the tracker "
        f"canonical: {unresolved}"
    )


# --------------------------------------------------------------------------- #
# 2. Every Part must carry an executed change record.
#
# Part M deferred its record to "between packages" and it was written at the end.
# Part N did the same, after the Part M failure had been written down.
# --------------------------------------------------------------------------- #

def test_every_executed_part_has_a_change_record():
    plan = _plan()
    parts = re.findall(r"^## Part ([A-Z]) — (.+)$", plan, re.MULTILINE)
    assert parts, "no Parts found; the scan is vacuous"

    records = set(re.findall(r"^## Part ([A-Z]) — executed change record", plan, re.MULTILINE))
    # A Part is "executed" once its packages have merge SHAs recorded against them.
    executed = set()
    for letter, _title in parts:
        body = plan.split(f"## Part {letter} — ", 1)[-1]
        body = body.split("\n## Part ", 1)[0]
        if re.search(r"\b[0-9a-f]{7}\b", body) and "AWAITING APPROVAL" not in body:
            executed.add(letter)

    missing = sorted(executed - records - {"A", "B", "C", "D", "E", "F", "G", "H", "I",
                                           "J", "K", "L", "O", "P"})
    assert not missing, (
        f"Part(s) {missing} record merge SHAs but have no executed change record. The "
        "plan requires the record between packages; twice it was written at the end, "
        "and the second time was after that failure had been documented."
    )


# --------------------------------------------------------------------------- #
# 3. pytest must never be piped.
#
# `pytest ... | tail -2` returns tail's exit status, so `set -e` saw success and a
# failing suite was committed, merged and pushed to main.
# --------------------------------------------------------------------------- #

_PIPED_PYTEST = re.compile(r"\bpytest\b[^\n|]*\|[ \t]*[a-zA-Z0-9_./]")

_SCAN_SUFFIXES = (".sh", ".md", ".yml", ".yaml", ".py")
_EXCLUDED_DIRS = {
    ".git",
    "__pycache__",
    "node_modules",
    ".venv",
    "diagnostics",
    "known_symptoms",
    "build",
    "dist",
}
# This file names the forbidden construct in order to forbid it.
_SELF = os.path.abspath(__file__)


def _committed_texts():
    found = []
    for dirpath, dirnames, filenames in os.walk(REPO_ROOT):
        dirnames[:] = [d for d in dirnames if d not in _EXCLUDED_DIRS]
        for name in filenames:
            if not name.endswith(_SCAN_SUFFIXES):
                continue
            path = os.path.join(dirpath, name)
            if os.path.abspath(path) == _SELF:
                continue
            with open(path, "r", encoding="utf-8", errors="replace") as fh:
                found.append((os.path.relpath(path, REPO_ROOT), fh.read()))
    return found


def test_no_committed_instruction_pipes_pytest():
    texts = _committed_texts()
    assert len(texts) >= 20, (
        f"only {len(texts)} documents scanned; the walk is broken and this passes vacuously"
    )
    offenders = []
    for rel, text in texts:
        for lineno, line in enumerate(text.splitlines(), 1):
            if _PIPED_PYTEST.search(line):
                offenders.append(f"{rel}:{lineno}: {line.strip()[:90]}")
    assert not offenders, (
        "a committed instruction pipes pytest. A pipe returns the LAST command's exit "
        "status, so a failing suite reads as success — this pushed a red main during "
        f"the session that added this gate: {offenders}"
    )


# --------------------------------------------------------------------------- #
# 4. Existence claims must cite a command that can observe the thing.
#
# `find -type f` lists neither symlinks nor their targets. Asserting a path did not
# exist from its output was wrong on #305, and the same probe error recurred on #294.
# --------------------------------------------------------------------------- #

def test_the_symlink_probe_hazard_is_documented():
    doc = os.path.join(REPO_ROOT, "rules", "document-references.md")
    assert os.path.isfile(doc), "rules/document-references.md missing"
    with open(doc, "r", encoding="utf-8") as fh:
        text = fh.read()
    assert "find -type f" in text, "`rules/document-references.md` must explicitly warn against `find -type f`."
    assert "symlink" in text.lower(), "`rules/document-references.md` must explicitly cite `symlink`."
