"""Rejects backlog specifications that claim the same title (issue #318).

Every other gate in this package looked at schema coverage, UML conformance, filenames
or Mermaid syntax. None looked at ``title``. That is the one field
``reconcile_backlog.py`` builds its issue lookup on, so a duplicate title is not a
tidiness problem: it is an ambiguous key, and the reconciler resolves it by last-writer-
wins. The observed consequences are #316 (one specification's body published over
another's) and #329 (the loser orphaned). This gate runs offline, before anything is
published, which is the cheapest place to stop that.

**Uniqueness is scoped per spec type, not globally.** Issue #303 settled the same
question for ``SyncValidator``, which keys on ``(spec_type, normalised_title)``: an
epic issue is not satisfied by a same-titled feature file, and an Epic naming a theme
alongside a Feature delivering part of it is ordinary, correct output. A global set —
as the proposed correction on #318 sketches — would reject that pairing and the first
thing anyone would do is disable the gate. The collision that does damage is two
specifications *of the same type*, because that is the key the reconciler collides in.
The backlog directory is the spec type: one directory per type is the layout every
other validator here assumes.

**Normalisation is ``reconcile_backlog.py``'s, deliberately.** Including its guard that
keeps the original title when prefix-stripping would empty it, which
``sync_validator.py``'s otherwise-identical copy lacks. A gate that exists to prevent
the reconciler mis-resolving has to collide in exactly the space the reconciler
collides in; a stricter normaliser invents collisions the reconciler does not have, and
a looser one misses the ones it does. The three copies of this function that now exist
in the repository are noted as an adjacent defect rather than unified here, because
unifying them changes ``sync_validator``'s behaviour and that belongs with the
reconciler work, not with this gate.
"""

import os
import re
from typing import Dict, List, NamedTuple, Optional

from .base import IValidator
from ..core.findings import Finding
from ..core.workspace import WorkspaceRepository

# Key in ``backlog_directories`` -> the spec type its files declare. Uniqueness is
# asserted within each of these independently.
DIRECTORY_SPEC_TYPES: Dict[str, str] = {
    "epics": "Epic",
    "features": "Feature",
    "user_stories": "User Story",
    "use_cases": "Use Case",
}

# The prefix ``reconcile_backlog.py::normalize_title`` strips: a type word, an optional
# ordinal, and an optional separator.
_PREFIX_RE = re.compile(
    r"^(epic|feature|feat|user[- ]story|use[- ]case|us|uc)[s]?(?:[- ]*\d+)?\s*[:\-]?\s*",
    re.IGNORECASE,
)


class DiscoveredTitle(NamedTuple):
    spec_type: str
    directory: str
    filename: str
    title: str


def normalize_spec_title(title: Optional[str]) -> str:
    """The lookup key ``reconcile_backlog.py`` addresses tracker issues by.

    Kept byte-for-byte equivalent to that function on purpose — see the module
    docstring. If it changes there, it must change here, or the gate stops describing
    the collision space it was built to protect.
    """
    if not title:
        return ""
    title = title.strip().strip("\"'")
    stripped = _PREFIX_RE.sub("", title)
    # Strip only when something survives: a title that is *only* a prefix ("Epic 2")
    # would otherwise normalise to the empty string, and every such title would then
    # collide with every other one.
    if stripped.strip():
        title = stripped
    title = title.replace("-", " ")
    title = re.sub(r"[^\w\s]", "", title)
    return " ".join(title.split()).lower()


def _extract_title(filepath: str) -> Optional[str]:
    """Frontmatter ``title``, falling back to the first H1.

    Same order and same 2KB read as ``reconcile_backlog.py::extract_title`` and
    ``sync_validator``: the gate must see the title the reconciler will see, not a
    better-parsed one.
    """
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as fh:
            content = fh.read(2048)
    except Exception:
        return None
    match = re.search(r'^title:\s*(["\']?)(.*?)\1\s*$', content, re.MULTILINE)
    if match:
        return match.group(2).strip()
    match = re.search(r"^#\s+(.*?)$", content, re.MULTILINE)
    if match:
        return match.group(1).strip()
    return None


class SpecTitleUniquenessValidator(IValidator):
    def collect_titles(self, repo: WorkspaceRepository) -> List[DiscoveredTitle]:
        """Every titled specification in the configured backlog directories.

        Exposed separately so a test can prove the scan found something. A discovery
        that silently returns nothing reports no duplicates and is indistinguishable
        from a clean backlog.
        """
        rules = repo.get_codebase_rules()
        backlog_dirs = rules.backlog_directories
        found: List[DiscoveredTitle] = []

        for dir_key, spec_type in DIRECTORY_SPEC_TYPES.items():
            rel = getattr(backlog_dirs, dir_key, None)
            if not rel:
                continue
            target = os.path.join(repo.workspace_dir, rel)
            if not os.path.isdir(target):
                continue
            for name in sorted(os.listdir(target)):
                if not name.endswith(".md") or name.startswith("."):
                    continue
                title = _extract_title(os.path.join(target, name))
                # An untitled specification is the UML validator's finding, not this
                # one's. Treating "" as a key would pair innocent files and point the
                # reader at a collision that does not exist.
                if not title:
                    continue
                found.append(DiscoveredTitle(spec_type, rel, name, title))
        return found

    def validate(self, repo: WorkspaceRepository, **kwargs) -> List[str]:
        errors: List[str] = []

        # (spec_type, normalised_title) -> the files claiming it. Insertion order is the
        # sorted directory walk, so the report is deterministic.
        claims: Dict[tuple, List[DiscoveredTitle]] = {}
        for entry in self.collect_titles(repo):
            key = (entry.spec_type, normalize_spec_title(entry.title))
            claims.setdefault(key, []).append(entry)

        for (spec_type, norm_title), colliding in claims.items():
            if len(colliding) < 2:
                continue
            listed = ", ".join(
                f"{e.directory}/{e.filename} ('{e.title}')" for e in colliding
            )
            errors.append(Finding(
                "spec-title-must-be-unique-within-its-spec-type",
                f"{colliding[0].directory}: duplicate {spec_type} title "
                f"- {len(colliding)} specifications normalise to '{norm_title}' "
                f"({listed}). reconcile_backlog.py addresses tracker issues by "
                f"normalised title, so a shared key resolves to whichever issue was "
                f"seen last: one body overwrites the other and the loser is orphaned. "
                f"Namespace the titles to their source module - see "
                f"rules/tracker-source-of-truth.md.",
                location=colliding[0].directory,
            ))

        return errors
