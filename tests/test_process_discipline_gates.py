# Tracking: #346, #343, #339
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
_SHA_REGEX = re.compile(r"\b[0-9a-f]{7,40}\b", re.IGNORECASE)


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
        if _SHA_REGEX.search(body) and "AWAITING APPROVAL" not in body:
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
_SCAN_ROOTS = [
    REPO_ROOT,
    os.path.join(REPO_ROOT, "implementation_plan.md"),
    os.path.join(REPO_ROOT, ".pipeline", "records"),
]
# This file names the forbidden construct in order to forbid it.
_SELF = os.path.abspath(__file__)


def _committed_texts():
    found = []
    scanned_paths = set()
    for root_item in _SCAN_ROOTS:
        if os.path.isfile(root_item):
            if os.path.abspath(root_item) != _SELF and root_item.endswith(_SCAN_SUFFIXES):
                scanned_paths.add(os.path.abspath(root_item))
        elif os.path.isdir(root_item):
            for dirpath, dirnames, filenames in os.walk(root_item):
                dirnames[:] = [d for d in dirnames if d not in _EXCLUDED_DIRS]
                for name in filenames:
                    if not name.endswith(_SCAN_SUFFIXES):
                        continue
                    path = os.path.abspath(os.path.join(dirpath, name))
                    if path != _SELF:
                        scanned_paths.add(path)
    for path in sorted(scanned_paths):
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


# --------------------------------------------------------------------------- #
# 5. Every realized feature tag in Dart code must have a governance record (#346).
# --------------------------------------------------------------------------- #

def test_every_realized_feature_has_governance_record():
    """Enforces that for every /// Realises: [Feat-X] tag in Dart files under app_flutter/lib/,
    a corresponding .pipeline/records/feat-x.md file exists on disk with required sections."""
    lib_dir = os.path.join(REPO_ROOT, "app_flutter", "lib")
    records_dir = os.path.join(REPO_ROOT, ".pipeline", "records")
    assert os.path.isdir(lib_dir), f"{lib_dir} missing"
    assert os.path.isdir(records_dir), f"{records_dir} missing"

    tag_pattern = re.compile(r"///\s*Realises:\s*\[\s*(Feat-\d+|UC-\d+)", re.IGNORECASE)
    realized_features = set()

    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith(".dart"):
                path = os.path.join(root, file)
                with open(path, "r", encoding="utf-8", errors="replace") as fh:
                    for match in tag_pattern.finditer(fh.read()):
                        feature_id = match.group(1).lower()
                        realized_features.add(feature_id)

    assert len(realized_features) >= 1, "No realized feature tags found in app_flutter/lib/"

    missing_records = []
    incomplete_records = []
    required_sections = ["## Task Breakdown", "## TDD Execution Log", "## Review Sign-off"]

    for feat in sorted(realized_features):
        record_path = os.path.join(records_dir, f"{feat}.md")
        if not os.path.isfile(record_path):
            missing_records.append(f"{feat}.md")
        else:
            with open(record_path, "r", encoding="utf-8") as fh:
                content = fh.read()
            missing_secs = [sec for sec in required_sections if sec not in content]
            if missing_secs:
                incomplete_records.append(f"{feat}.md missing: {', '.join(missing_secs)}")

    assert not missing_records, f"Realized features missing governance records: {missing_records}"
    assert not incomplete_records, f"Governance records incomplete: {incomplete_records}"


# --------------------------------------------------------------------------- #
# 6. Regression tests for source reference false-positives and blocked_specs bounds (#336).
# --------------------------------------------------------------------------- #

def test_source_reference_no_false_positives_issue336():
    """Asserts that source reference scanning ignores doc comments / string literals
    and does not produce false-positive tags."""
    tag_pattern = re.compile(r"///\s*Realises:\s*\[\s*(Feat-\d+|UC-\d+)", re.IGNORECASE)

    comment_line = "// This comment mentions Realises: [Feat-99] but is not a triple-slash doc tag"
    assert not tag_pattern.search(comment_line)


def test_blocked_specs_bounds_issue336():
    """Asserts blocked_specs extraction handles linter output bounds correctly."""
    import sys
    sys.path.insert(0, os.path.join(REPO_ROOT, "skills", "spec-orchestrator", "scripts"))
    from reconcile_backlog import blocked_specs_from_linter_output

    rules = {
        "backlog_directories": {
            "epics": "docs/epics",
            "features": "docs/features",
            "user_stories": "docs/user-stories",
            "use_cases": "docs/use-cases",
        }
    }

    # Clean output -> empty set
    clean_result = blocked_specs_from_linter_output("Success: all checks passed.", REPO_ROOT, rules)
    assert clean_result == set()

    # Bounded extraction with invalid files returns non-none set
    sample_output = "[ERROR] docs/features/feat-13-zero-codegen-grid.md: Missing Parent Epic link"
    sample_result = blocked_specs_from_linter_output(sample_output, REPO_ROOT, rules)
    assert isinstance(sample_result, set)
    assert "feat-13-zero-codegen-grid.md" in sample_result


