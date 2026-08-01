"""Rejects Source References that lost their authoritative locator (issues #320, #322).

During drafting a subagent rewrites an upstream locator such as
``https://github.com/YangModels/yang/blob/main/ietf-geo.yang`` into a fabricated local
one under this repository. The prompt supplies the upstream URL for *retrieval*, and
nothing required preserving it in the output (#322). No gate extracted Markdown links
at all, so the rewrite published cleanly (#320).

**This gate is offline by mandate, and does not check reachability.**
``.pipeline/upstream/pipeline-tooling.md`` § *Validation Gates* requires blocking gates
to be offline and dependency-free, and forbids sending specification content to a third
party. #320's text asks for reachability checking; implementing it would put an HTTP
call on the critical path of every registration, failing whenever the far end is down or
rate-limits — for reasons unrelated to correctness — and would leak specification
content to whoever is asked. What is checked instead is the *structure* of the rewrite,
which is what actually catches #322 and needs no network.

Deliberately not enforced
-------------------------
* *Reachability of any URL.* See above. A network-dependent blocking gate is forbidden.
* *Repository-internal links generally.* Specifications legitimately cite
  ``.pipeline/constitution.md`` and the platform profiles by relative path, and the live
  corpus is full of them. Flagging every internal link would reject correct content
  wholesale, and the first response would be to switch the gate off.
* *Whether an upstream URL is the "right" one.* Only that an external artefact is not
  described by a self-referential locator. Judging which upstream URL is correct needs
  the source material, which this gate does not have.
"""

import os
import re
from typing import List, NamedTuple, Optional

from .base import IValidator
from ..core.findings import Finding
from ..core.workspace import WorkspaceRepository

DIRECTORY_KEYS = ("epics", "features", "user_stories", "use_cases")

# Lines under `## Source References` that describe an *external* artefact. These are
# external by definition, which is what makes a self-referential URL decidable.
EXTERNAL_LABELS = ("structural schema", "normative specification")

# Placeholders shipped in the SKILL.md templates. Surviving into a published spec means
# the drafting subagent never populated the block.
PLACEHOLDERS = ("link-to-schema", "link-to-specification")

_MD_LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)")
_SOURCE_REFS_BLOCK = re.compile(
    r"^##\s+Source References\s*$(.*?)(?=^##\s|\Z)",
    re.MULTILINE | re.DOTALL,
)


class Reference(NamedTuple):
    directory: str
    filename: str
    lineno: int
    label: str
    url: str


def _iter_spec_files(repo: WorkspaceRepository):
    rules = repo.get_codebase_rules()
    backlog = rules.backlog_directories
    for key in DIRECTORY_KEYS:
        rel = getattr(backlog, key, None)
        if not rel:
            continue
        target = os.path.join(repo.workspace_dir, rel)
        if not os.path.isdir(target):
            continue
        for name in sorted(os.listdir(target)):
            if name.endswith(".md") and not name.startswith("."):
                yield rel, name, os.path.join(target, name)


def _upstream_repository(repo: WorkspaceRepository) -> Optional[str]:
    rules = repo.get_codebase_rules()
    meta = getattr(rules, "meta", None)
    if meta is None:
        return None
    return getattr(meta, "upstream_repository", None) or None


class SourceReferenceValidator(IValidator):
    def collect_references(self, repo: WorkspaceRepository) -> List[Reference]:
        """Every Markdown link inside a `## Source References` block.

        Exposed separately so a test can prove the scan found something: a discovery
        that silently returns nothing reports no violations and is indistinguishable
        from a clean backlog.
        """
        found: List[Reference] = []
        for rel, name, path in _iter_spec_files(repo):
            try:
                with open(path, "r", encoding="utf-8", errors="ignore") as fh:
                    content = fh.read()
            except OSError:
                continue
            for block in _SOURCE_REFS_BLOCK.finditer(content):
                start_line = content.count("\n", 0, block.start(1)) + 1
                for offset, line in enumerate(block.group(1).splitlines()):
                    for match in _MD_LINK.finditer(line):
                        found.append(Reference(
                            rel, name, start_line + offset, line.strip().lower(),
                            match.group(1),
                        ))
        return found

    def validate(self, repo: WorkspaceRepository, **kwargs) -> List[str]:
        errors: List[str] = []
        upstream = _upstream_repository(repo)

        for ref in self.collect_references(repo):
            where = f"{ref.directory}/{ref.filename}:{ref.lineno}"
            describes_external = any(lbl in ref.label for lbl in EXTERNAL_LABELS)

            if any(p in ref.url for p in PLACEHOLDERS):
                errors.append(Finding(
                    "source-reference-placeholder-must-be-populated",
                    f"{where}: unpopulated Source References placeholder "
                    f"({ref.url!r}). The SKILL.md template ships this token; a "
                    f"specification carrying it into the backlog was never given its "
                    f"authoritative locator.",
                    location=ref.directory,
                ))
                continue

            if describes_external and upstream and upstream in ref.url:
                errors.append(Finding(
                    "external-source-reference-must-not-be-self-referential",
                    f"{where}: a Structural Schema or Normative Specification "
                    f"reference points at this repository ({ref.url!r}). Those "
                    f"artefacts are external by definition, so a self-referential "
                    f"locator is the upstream URL having been rewritten during "
                    f"drafting (#322). Preserve the authoritative URL verbatim - see "
                    f"rules/document-references.md.",
                    location=ref.directory,
                ))
                continue

            # Relative links must resolve. Absolute ones are not fetched - see the
            # module docstring on why reachability is out of scope.
            if "://" in ref.url or ref.url.startswith("#"):
                continue
            target = ref.url.split("#", 1)[0]
            if not target:
                continue
            resolved = os.path.normpath(
                os.path.join(repo.workspace_dir, ref.directory, target)
            )
            if not os.path.exists(resolved):
                errors.append(Finding(
                    "source-reference-relative-link-must-resolve",
                    f"{where}: relative Source References link {target!r} does not "
                    f"exist on disk. A dangling locator sends a reader - or a "
                    f"downstream implementer tracing the specification - nowhere.",
                    location=ref.directory,
                ))

        return errors
