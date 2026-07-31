"""Offline checker for the project's documented Mermaid syntax rules.

This is **not** a Mermaid grammar parser. It enforces the character-level rules
consolidated in ``rules/platform-independence.md``, which are the rules that have
actually broken rendering in this repository. A clean result means no *documented
rule* was violated; it does not prove the diagram renders.

That limit is deliberate. The alternative considered was calling a remote renderer,
which was rejected: a blocking gate depending on a third-party service fails when
that service is down or rate-limits, and it ships specification content to a third
party. See ``.pipeline/upstream/pipeline-tooling.md`` § *Validation Gates*.

Rules enforced
--------------
* Semicolons in ``Note`` statements and in message text. Mermaid reads ``;`` as a
  statement separator, so the remainder of the line becomes a new statement and
  collides with whatever follows. This is the fault that shipped on issue #283.
* Unclosed ```` ```mermaid ```` fences.
* Colons inside class-diagram member lines and inside note strings.
* Stereotypes on class-diagram relationship lines (``<<`` ``>>`` ``«`` ``»`` and
  their HTML entities).
* Curly braces inside class-diagram member lines.

Deliberately not enforced
-------------------------
* *Participants declared before use.* Mermaid auto-declares participants on first
  reference, so requiring an explicit declaration would reject valid diagrams. A
  checker that produces false positives is worse than no checker.
* *Arrow token validity.* Mermaid accepts a large set of arrow forms; enumerating
  them invites false positives for no demonstrated benefit.
"""

import os
import re
from typing import List, Optional, Sequence, Tuple

from .base import IValidator
from ..core.workspace import WorkspaceRepository

FENCE = "`" * 3
_FENCE_OPEN = re.compile(r"^\s*" + FENCE + r"\s*mermaid\s*$", re.I)
_FENCE_ANY = re.compile(r"^\s*" + FENCE)

# `Note over A,B: text` / `Note left of A: text`
_NOTE = re.compile(r"^\s*note\b[^:]*:(?P<text>.*)$", re.I)
# `A->>B: text`, `A-->B: text`, `A-)B: text` and similar
_MESSAGE = re.compile(r"^\s*\S+\s*-{1,2}[->x)]{1,2}>?\s*\S+\s*:(?P<text>.*)$")
# classDiagram note forms: `note "..."` / `note for X "..."`
_CLASS_NOTE = re.compile(r'^\s*note\b.*?"(?P<text>[^"]*)"', re.I)
_RELATIONSHIP = re.compile(r"(\*--|o--|<\|--|--\|>|-->|<--|\.\.>|--)")
# `ClassA *-- ClassB : label`  -- captures whatever follows the colon.
_RELATIONSHIP_LABEL = re.compile(
    r"^\s*\S+\s*(?:\*--|o--|<\|--|--\|>|-->|<--|\.\.>|--)\s*\S+\s*:\s*(?P<label>.*)$"
)
_STEREOTYPE = re.compile(r"(<<|>>|&lt;&lt;|&gt;&gt;|\u00ab|\u00bb)")
# A member line inside `class X { ... }`.
#
# The visibility marker is followed by at most ONE space before content. This
# deliberately excludes unified-diff context lines, which preserve the original
# indentation after the diff marker (e.g. "-       }"). Several docs embed diffs
# containing mermaid blocks, and reading a diff marker as a UML visibility marker
# produced false positives on first implementation.
_MEMBER = re.compile(r"^\s*[+\-#~] ?(?P<rest>\S.*)$")
# Structural brace lines are not members and must never be flagged for braces.
_BRACE_ONLY = re.compile(r"^[{}\s]*$")

_DIAGRAM_KINDS = ("sequencediagram", "classdiagram", "statediagram", "graph", "flowchart")

# No directories are excluded from the default scan.
#
# An earlier revision skipped `decisions/` and `designs/` to keep the linter green on
# historical records. That was wrong: downstream output is a diagnostic instrument,
# and excluding directories suppresses the signal it exists to provide -- the
# exclusion concealed 13 confirmed non-rendering diagrams behind a green check.
# Findings in disposable content are the measurement, not a problem to manage.


def _blocks(text: str) -> Tuple[List[Tuple[int, List[str], str]], List[int]]:
    """Return ``(blocks, unclosed_starts)``.

    Each block is ``(start_line_1based, body_lines, kind)``.
    """
    blocks: List[Tuple[int, List[str], str]] = []
    unclosed: List[int] = []
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        if _FENCE_OPEN.match(lines[i]):
            start = i + 1
            body: List[str] = []
            i += 1
            closed = False
            while i < len(lines):
                if _FENCE_ANY.match(lines[i]):
                    closed = True
                    break
                body.append(lines[i])
                i += 1
            kind = ""
            for line in body:
                stripped = line.strip().lower()
                if stripped:
                    kind = next((k for k in _DIAGRAM_KINDS if stripped.startswith(k)), "")
                    break
            if closed:
                blocks.append((start, body, kind))
            else:
                unclosed.append(start)
        i += 1
    return blocks, unclosed


def _in_class_body(body: Sequence[str], idx: int) -> bool:
    """True when ``body[idx]`` sits inside a ``class X { ... }`` block."""
    depth = 0
    for line in body[:idx]:
        depth += line.count("{") - line.count("}")
    return depth > 0


def check_mermaid_text(text: str, source: str = "<input>") -> List[str]:
    """Return one error string per documented-rule violation. Empty means clean."""
    errors: List[str] = []
    blocks, unclosed = _blocks(text)

    for start in unclosed:
        errors.append(
            f"{source}:{start}: unclosed ```mermaid fence. Every diagram must be "
            f"closed with a matching {FENCE} on its own line, or the block leaks "
            f"into the surrounding document."
        )

    for start, body, kind in blocks:
        for offset, line in enumerate(body):
            lineno = start + offset + 1

            # --- semicolons in Note statements and message text ---------------
            payload: Optional[str] = None
            note = _NOTE.match(line)
            if note:
                payload = note.group("text")
            else:
                msg = _MESSAGE.match(line)
                if msg:
                    payload = msg.group("text")
            if payload and ";" in payload:
                errors.append(
                    f"{source}:{lineno}: semicolon in Mermaid Note or message text "
                    f"({line.strip()!r}). Mermaid parses ';' as a statement separator, "
                    f"so the rest of the line becomes a new statement and the diagram "
                    f"fails to render. Replace it with a comma, dash or space."
                )

            if kind != "classdiagram":
                continue

            # --- class-diagram-only rules --------------------------------------
            member = _MEMBER.match(line)
            if member and not _BRACE_ONLY.match(member.group("rest")) \
                    and _in_class_body(body, offset):
                if ":" in line:
                    errors.append(
                        f"{source}:{lineno}: colon inside a Mermaid class member line "
                        f"({line.strip()!r}). Use 'ReturnType methodName(Type arg)' "
                        f"spacing instead."
                    )
                if "{" in line or "}" in line:
                    errors.append(
                        f"{source}:{lineno}: curly brace inside a Mermaid class member "
                        f"line ({line.strip()!r}). Use parentheses, e.g. "
                        f"'(default earth)'."
                    )

            class_note = _CLASS_NOTE.match(line)
            if class_note and ":" in class_note.group("text"):
                errors.append(
                    f"{source}:{lineno}: colon inside a Mermaid note string "
                    f"({line.strip()!r}). Colons in notes break rendering."
                )

            if _RELATIONSHIP.search(line) and _STEREOTYPE.search(line):
                errors.append(
                    f"{source}:{lineno}: stereotype on a Mermaid relationship line "
                    f"({line.strip()!r}). Use a plain label such as 'references'."
                )

            rel_label = _RELATIONSHIP_LABEL.match(line)
            if rel_label:
                label = rel_label.group("label").strip()
                if label and not label.startswith('"') and re.search(r"[\s:]", label):
                    errors.append(
                        f"{source}:{lineno}: unquoted Mermaid relationship label "
                        f"containing spaces or colons ({line.strip()!r}). Enclose it in "
                        f'double quotes, e.g. : "renders one instance".'
                    )

    return errors


class MermaidSyntaxValidator(IValidator):
    """``IValidator`` wrapper scanning markdown trees for rule violations."""

    def validate(self, repo: WorkspaceRepository, **kwargs) -> List[str]:
        search_dirs = kwargs.get("search_dirs")
        if not search_dirs:
            search_dirs = [
                os.path.join(repo.workspace_dir, "docs"),
                os.path.join(repo.workspace_dir, "rules"),
                os.path.join(repo.workspace_dir, "skills"),
            ]

        errors: List[str] = []
        for root in search_dirs:
            if not os.path.isdir(root):
                continue
            for dirpath, _dirnames, filenames in os.walk(root):
                for name in sorted(filenames):
                    if not name.endswith(".md"):
                        continue
                    path = os.path.join(dirpath, name)
                    try:
                        with open(path, "r", encoding="utf-8", errors="replace") as fh:
                            content = fh.read()
                    except OSError:
                        continue
                    if FENCE + "mermaid" not in content:
                        continue
                    rel = os.path.relpath(path, repo.workspace_dir)
                    errors.extend(check_mermaid_text(content, source=rel))
        return errors
