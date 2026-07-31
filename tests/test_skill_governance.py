"""Governance regression tests for skill instruction files.

Covers:
  #287 - the debug-protocol autonomous loop selected work by the ``bug`` label and
         could not stop until zero such issues remained, while Step 0 ordered an
         immediate halt on any selected item that was not a defect. Nothing
         relabelled or closed it, so the terminating condition was unsatisfiable.
         The upstream producer was adversarial-code-auditor Step E, which labelled
         every finding ``bug`` regardless of severity.
"""

import os
import re

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
DEBUG_PROTOCOL = os.path.join(REPO_ROOT, "skills", "debug-protocol", "SKILL.md")
AUDITOR = os.path.join(REPO_ROOT, "skills", "adversarial-code-auditor", "SKILL.md")


def _read(path):
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


def test_skill_files_are_discoverable():
    for path in (DEBUG_PROTOCOL, AUDITOR):
        assert os.path.isfile(path), f"skill file not found: {path}"


# --------------------------------------------------------------------------- #
# #287 - the loop must be able to terminate
# --------------------------------------------------------------------------- #

def test_debug_protocol_has_a_reclassification_branch_issue287():
    content = _read(DEBUG_PROTOCOL)
    assert re.search(r"--remove-label\s+bug", content), (
        "debug-protocol/SKILL.md must instruct the agent to relabel a non-defect off "
        "'bug' and continue, rather than halt. Without it the loop's exit condition "
        "cannot be satisfied."
    )
    assert re.search(r"reclassif", content, re.I), (
        "debug-protocol/SKILL.md must name the reclassification path explicitly"
    )


def test_debug_protocol_terminating_condition_is_qualified_issue287():
    content = _read(DEBUG_PROTOCOL)
    assert "ZERO unresolved bugs remaining in the repository backlog" not in content, (
        "the unqualified terminating condition must be replaced. It cannot be met "
        "while a non-defect retains the 'bug' label, and Step 0 forbids processing it."
    )
    assert re.search(r"Step 0 defect gate", content), (
        "the terminating condition must be qualified by the Step 0 defect gate, e.g. "
        "'no open issue labelled bug remains that passes the Step 0 defect gate'"
    )


def test_debug_protocol_explains_why_halting_is_not_an_option_issue287():
    """The 3-iteration skip is unreachable for a non-defect. Say so, or the next
    author will re-derive the halt."""
    content = _read(DEBUG_PROTOCOL)
    assert re.search(r"before iteration one", content, re.I), (
        "debug-protocol/SKILL.md should record that the 3-iteration skip does not "
        "rescue the loop because Step 0 halts before iteration one"
    )


# --------------------------------------------------------------------------- #
# #287 - stop the upstream producer of mislabelled inputs
# --------------------------------------------------------------------------- #

def test_auditor_does_not_hardcode_the_bug_label_issue287():
    content = _read(AUDITOR)
    assert '--label "bug"' not in content, (
        'adversarial-code-auditor/SKILL.md must not hardcode --label "bug" in Step E. '
        "Section 1.4 defines Suggestion as explicitly NOT a current bug, so labelling "
        "it 'bug' manufactures the inputs that deadlock debug-protocol."
    )


def test_auditor_maps_severity_to_label_issue287():
    content = _read(AUDITOR)
    assert "enhancement" in content, (
        "adversarial-code-auditor/SKILL.md Step E must map Suggestion and Nitpick "
        "findings to a non-bug label such as 'enhancement'"
    )
    mapping = re.search(r"Critical.{0,80}Important.{0,120}Suggestion", content, re.S)
    assert mapping, (
        "Step E must state an explicit severity-to-label mapping covering Critical, "
        "Important, Suggestion and Nitpick"
    )


# --------------------------------------------------------------------------- #
# Guard against the duplicate-numbering defect class seen in #283, and
# reintroduced accidentally while fixing #287.
# --------------------------------------------------------------------------- #

def _ordered_list_runs(text):
    """Yield each maximal run of consecutive top-level numbered lines."""
    run = []
    for line in text.splitlines():
        m = re.match(r"^(\d+)\.\s", line)
        if m:
            run.append(int(m.group(1)))
        elif run and not line.strip():
            continue          # blank lines do not break a list
        elif run and re.match(r"^\s+", line):
            continue          # indented continuation does not break a list
        elif run:
            yield run
            run = []
    if run:
        yield run


def test_skill_numbered_lists_have_no_duplicate_ordinals():
    """An inserted step must renumber the ones after it.

    #283 was partly this defect in schema-specification-engineering. It recurred in
    adversarial-code-auditor Step E while fixing #287, so it is now pinned.
    """
    offenders = []
    for path in (DEBUG_PROTOCOL, AUDITOR):
        for run in _ordered_list_runs(_read(path)):
            if len(run) > 2 and len(set(run)) != len(run):
                dupes = sorted({n for n in run if run.count(n) > 1})
                offenders.append((os.path.basename(os.path.dirname(path)), run, dupes))
    assert not offenders, (
        "numbered lists contain repeated ordinals, so an inserted step did not "
        f"renumber its successors: {offenders}"
    )
