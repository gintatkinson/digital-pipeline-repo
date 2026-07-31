"""Regression tests for issue #285.

``spec-orchestrator/SKILL.md`` invoked the linter through the repository-relative
``skills/`` prefix and ``create_issue.sh`` through ``.agents/skills/`` — in the same
sentence. Both resolved only because ``.agents/skills`` is a git-tracked symlink
(mode 120000) pointing at ``../skills``.

Nothing was broken at the time of filing, so this was drift risk rather than an
active defect. But the failure mode is asymmetric and confusing: if the symlink is
ever not materialised — archive extraction, ``core.symlinks=false``, a filesystem
without symlink support — the linter call on a given line still succeeds while the
``create_issue.sh`` call on the same line fails, pointing debugging at issue
creation rather than at path resolution.

The second test here is the stronger one: rather than only banning a prefix, it
asserts that every ``skills/...`` path mentioned in a governance document actually
resolves on disk. That catches dangling references generally, not just this one.
"""

import os
import re

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SCAN_ROOTS = ("skills", "rules")
EXCLUDED_DIRS = {".git", "__pycache__", "node_modules", "decisions", "designs"}

# Paths appearing inside prose as examples of the *wrong* form are allowed only in
# documents that exist to explain the convention.
ALLOWED_AGENTS_PREFIX = set()


def _governance_docs():
    found = []
    for base in SCAN_ROOTS:
        root = os.path.join(REPO_ROOT, base)
        if not os.path.isdir(root):
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIRS]
            for name in filenames:
                if name.endswith(".md"):
                    found.append(os.path.join(dirpath, name))
    return found


def _read(path):
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        return fh.read()


def test_governance_docs_are_discoverable():
    """Guard: both assertions below iterate this corpus."""
    docs = _governance_docs()
    assert len(docs) >= 8, f"expected the skill and rule documents, found {len(docs)}"


def test_no_document_uses_the_agents_skills_prefix_issue285():
    offenders = []
    for path in _governance_docs():
        rel = os.path.relpath(path, REPO_ROOT)
        if rel in ALLOWED_AGENTS_PREFIX:
            continue
        for lineno, line in enumerate(_read(path).splitlines(), 1):
            if ".agents/skills" in line:
                offenders.append(f"{rel}:{lineno}")
    assert not offenders, (
        "documents reference paths through the '.agents/skills/' symlink. Use the "
        "repository-relative 'skills/' prefix so resolution does not depend on the "
        f"symlink being materialised: {offenders}"
    )


def test_referenced_skill_paths_resolve_on_disk_issue285():
    """The real invariant: a path named in a governance document must exist."""
    # Most references are written './skills/...', so the leading './' must be
    # accepted and then normalised away. A lookbehind rejecting '.' or '/' matched
    # almost nothing and the vacuity guard below caught it.
    pattern = re.compile(r"(?<![\w-])((?:\./)?(?:\.agents/)?skills/[A-Za-z0-9_./-]+)")
    offenders = []
    checked = 0
    for path in _governance_docs():
        rel = os.path.relpath(path, REPO_ROOT)
        for lineno, line in enumerate(_read(path).splitlines(), 1):
            for match in pattern.finditer(line):
                candidate = match.group(1).rstrip(".,;:)`\"'")
                if candidate.startswith("./"):
                    candidate = candidate[2:]
                # skip glob/placeholder forms that cannot be resolved literally
                if any(ch in candidate for ch in "<>*[]") or candidate.endswith("/"):
                    continue
                if "spec-orchestrator/scripts" in candidate or candidate.endswith(
                    (".md", ".py", ".sh", ".json")
                ):
                    checked += 1
                    if not os.path.exists(os.path.join(REPO_ROOT, candidate)):
                        offenders.append(f"{rel}:{lineno} -> {candidate}")
    assert checked >= 10, (
        f"only {checked} concrete skill paths examined; the scan is close to vacuous"
    )
    assert not offenders, f"governance documents reference paths that do not exist: {offenders}"
