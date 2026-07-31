<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

# Rule: Document References Must Resolve

**ALWAYS enforce:** A governance document that refers to a path, a step, or another
document must refer to something that exists.

## Hard constraints

- **Repository-Relative Skill Paths**: Governance documents MUST cite skill files through
  the repository-relative `skills/` prefix, never through the `.agents/skills/` symlink.
  The symlink is tracked (git mode `120000`, pointing at `../skills`) and resolves under a
  normal checkout, but it is not guaranteed to be materialised under archive extraction,
  `core.symlinks=false`, or a filesystem without symlink support. The failure is
  asymmetric and confusing: a `skills/` reference on one line still resolves while an
  `.agents/skills/` reference on the next fails, pointing debugging at the wrong subsystem.
- **Cited Paths Must Resolve**: Every repository path named in a governance document MUST
  exist on disk. A dangling path is worse than no reference, because it sends the reader —
  or a dispatched subagent instructed to read it — somewhere empty, and the resulting
  silence looks like an absence of instructions rather than a broken link.
- **Cited Steps Must Resolve**: Every cross-document citation of another document's numbered
  step MUST name a step that exists in the cited document. A citation to a step that is not
  there defeats verification: a reader checking whether an override or cross-reference
  actually covers the text it claims to cover cannot locate the target, and any step the
  citation omits is silently excluded from whatever the citing document asserts.

## Scope

These constraints apply to every document under `rules/`, `skills/`, `.agents/` and
`.pipeline/` — the corpus scanned by `tests/test_skill_path_references.py`. Hidden
directories are explicitly in scope; omitting them is how the prefix rule went unenforced
against the only document that violated it (issue #305).

## Enforcement

Mechanically enforced, offline, by `tests/test_skill_path_references.py`. The pairing
between each constraint above and its enforcing assertion is registered in
`tests/rule_contracts.py`, so removing either side fails the suite.

## Why

Until issue #310 these three rules were enforced by tests and stated in no document.
`rules/constitution-first.md` requires agents to read `rules/` before any task, so a rule
absent from `rules/` is invisible to the process meant to guarantee compliance — an agent
could follow every documented rule and still fail the suite. It also left the rules
unamendable, because there was no text to propose a change against.

That is the **orphan enforcement** failure mode `tests/rule_contracts.py` exists to detect,
and the same class as issue #299, where the Mermaid parser rejected unquoted relationship
labels that `rules/platform-independence.md` never mentioned.
