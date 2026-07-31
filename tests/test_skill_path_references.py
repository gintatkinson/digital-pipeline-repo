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
# `.agents` and `.pipeline` are hidden, and were omitted here until issue #305. The
# omission was self-defeating: the prefix ban below exists to keep `.agents/skills/`
# out of governance documents, and the only document using that prefix lived in the
# one directory this scan skipped. The test was green because it could not see its
# own subject. Same root cause as #295 — hidden directories dropped by
# convention-based enumeration — with a test doing the skipping rather than an agent.
#
# os.walk does not follow symlinks by default, so `.agents/skills -> ../skills` is
# not descended into and `skills/` documents are not counted twice.
SCAN_ROOTS = ("skills", "rules", ".agents", ".pipeline")
EXCLUDED_DIRS = {
    ".git",
    "__pycache__",
    "node_modules",
    "decisions",
    "designs",
    "diagnostics",  # .pipeline/diagnostics holds ~78 repro payloads, none of them .md
}

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
    """Guard: every assertion below iterates this corpus.

    The count alone is a weak guard — it cleared comfortably on ``skills/`` and
    ``rules/`` alone while the hidden roots were missing entirely (#305). The
    membership assertions are the real check: they name one document from each hidden
    root, so dropping a scan root fails here loudly instead of silently shrinking
    what the suite examines.
    """
    docs = _governance_docs()
    rels = {os.path.relpath(p, REPO_ROOT) for p in docs}

    assert len(docs) >= 28, (
        f"expected the skill, rule and hidden governance documents, found {len(docs)}"
    )
    for required in (".agents/AGENTS.md", ".pipeline/constitution.md"):
        assert required in rels, (
            f"{required} is missing from the scanned corpus — a SCAN_ROOTS regression. "
            "This is the #305 blind spot; do not fix it by lowering the guard."
        )


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
