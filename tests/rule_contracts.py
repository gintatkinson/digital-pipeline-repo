"""Registry pairing each enforced rule with the document that states it.

Seven defects found in a single audit session were one class: the documented
contract and the enforced contract disagreed (#283, #286, #289, #292, #295, #281,
#299). Every one was found by a human noticing, or by accident. Nothing tested that
documentation matches enforcement — that absence, rather than any individual
mismatch, is the root cause. See issue #298.

A contract has two anchors. Both must resolve, and the pairing must be registered.
Two failure modes then become mechanically detectable:

* **Orphan documentation** — a rule stated as MUST or prohibited that nothing
  enforces. This is #289.
* **Orphan enforcement** — a rule the code rejects that no document mentions. This
  is #299, where ``parsers/mermaid.py`` rejected unquoted relationship labels while
  ``rules/platform-independence.md`` never mentioned quoting.

**Scope.** This registry currently covers the Mermaid syntax family, where three of
the seven instances live. It is deliberately not a universal solution. Other families
— cardinality, authorization precedence, Python version reconciliation — are listed
in ``KNOWN_UNREGISTERED_FAMILIES`` so their absence is explicit rather than implied.
"""

from dataclasses import dataclass
from typing import List, Optional

PARITY_SRC = "skills/spec-orchestrator/parity_auditor/src/parity_auditor"


@dataclass(frozen=True)
class RuleContract:
    """One rule, its documentation anchor, and its enforcement anchor.

    ``doc_anchor`` and ``enforcement_anchor`` are literal substrings expected to be
    present in the respective files. Substrings rather than regexes, so a failure
    message can quote exactly what was missing.
    """

    id: str
    documented_in: str
    doc_anchor: str
    enforced_in: str
    enforcement_anchor: str
    note: str = ""


MERMAID_CONTRACTS: List[RuleContract] = [
    RuleContract(
        id="mermaid-no-semicolon-in-note-or-message",
        documented_in="rules/platform-independence.md",
        doc_anchor="Mermaid Semicolon Rules",
        enforced_in=f"{PARITY_SRC}/validators/mermaid_syntax_validator.py",
        enforcement_anchor="semicolon in Mermaid Note or message text",
        note="The fault that shipped a non-rendering diagram on issue #283.",
    ),
    RuleContract(
        id="mermaid-no-curly-brace-in-class-member",
        documented_in="rules/platform-independence.md",
        doc_anchor="Mermaid Class Member Brace Rules",
        enforced_in=f"{PARITY_SRC}/validators/mermaid_syntax_validator.py",
        enforcement_anchor="curly brace inside a Mermaid class member",
        note="13 confirmed non-rendering diagrams in downstream output (#296).",
    ),
    RuleContract(
        id="mermaid-no-colon-in-class-member",
        documented_in="rules/platform-independence.md",
        doc_anchor="Mermaid Class Diagram Syntax Rules",
        enforced_in=f"{PARITY_SRC}/validators/mermaid_syntax_validator.py",
        enforcement_anchor="colon inside a Mermaid class member line",
    ),
    RuleContract(
        id="mermaid-no-colon-in-note-string",
        documented_in="rules/platform-independence.md",
        doc_anchor="Mermaid Note Rules",
        enforced_in=f"{PARITY_SRC}/validators/mermaid_syntax_validator.py",
        enforcement_anchor="colon inside a Mermaid note string",
    ),
    RuleContract(
        id="mermaid-no-stereotype-on-relationship",
        documented_in="rules/platform-independence.md",
        doc_anchor="Mermaid Relationship Rules",
        enforced_in=f"{PARITY_SRC}/validators/mermaid_syntax_validator.py",
        enforcement_anchor="stereotype on a Mermaid relationship line",
    ),
    RuleContract(
        id="mermaid-fence-must-be-closed",
        documented_in="rules/platform-independence.md",
        doc_anchor="strictly and explicitly closed",
        enforced_in=f"{PARITY_SRC}/validators/mermaid_syntax_validator.py",
        enforcement_anchor="unclosed ```mermaid fence",
    ),
    RuleContract(
        id="mermaid-relationship-label-must-be-quoted",
        documented_in="rules/platform-independence.md",
        doc_anchor="Mermaid Relationship Label Rules",
        enforced_in=f"{PARITY_SRC}/validators/mermaid_syntax_validator.py",
        enforcement_anchor="unquoted Mermaid relationship label",
        note=(
            "Issue #299. Enforced by parsers/mermaid.py:447 but documented nowhere, so "
            "a generating subagent could not comply. 6 symptoms observed in downstream "
            "feat-10 and feat-11 output."
        ),
    ),
]

FILENAME_CONTRACTS: List[RuleContract] = [
    RuleContract(
        id="spec-filename-ordinal-uniqueness",
        documented_in="skills/spec-usecase-engineering/SKILL.md",
        doc_anchor="zero-padded, dash-separated",
        enforced_in=f"{PARITY_SRC}/validators/spec_filename_validator.py",
        enforcement_anchor="duplicate ordinal",
        note="Issue #300. feat-04 and feat-05 each appear twice in downstream output.",
    ),
    RuleContract(
        id="spec-filename-format",
        documented_in="skills/spec-user-story-engineering/SKILL.md",
        doc_anchor="zero-padded, dash-separated",
        enforced_in=f"{PARITY_SRC}/validators/spec_filename_validator.py",
        enforcement_anchor="does not match the documented convention",
    ),
    RuleContract(
        id="spec-filename-padding-consistency",
        documented_in="skills/spec-usecase-engineering/SKILL.md",
        doc_anchor="zero-padded",
        enforced_in=f"{PARITY_SRC}/validators/spec_filename_validator.py",
        enforcement_anchor="inconsistent ordinal padding width",
        note="feat-002 uses 3-digit padding where the directory otherwise uses 2.",
    ),
    RuleContract(
        id="spec-filename-directory-prefix",
        documented_in="skills/schema-specification-engineering/SKILL.md",
        doc_anchor="docs/features/feat-01-name.md",
        enforced_in=f"{PARITY_SRC}/validators/spec_filename_validator.py",
        enforcement_anchor="directory prefix mismatch",
    ),
]


@dataclass(frozen=True)
class ContractFamily:
    """A group of contracts plus the scanners that find orphans in either direction.

    ``doc_heading_pattern`` is optional. A family whose rule is scattered across several
    documents has no single file to scan for orphan documentation, so the field is None
    and ``doc_orphan_blocked_by`` must explain why. Orphan **enforcement** detection
    still works for such a family, because that scans one validator.
    """

    name: str
    contracts: List[RuleContract]
    enforcement_file: str
    enforcement_pattern: str
    doc_file: Optional[str] = None
    doc_heading_pattern: Optional[str] = None
    doc_only: Optional[dict] = None
    doc_orphan_blocked_by: str = ""


MERMAID_FAMILY = ContractFamily(
    name="mermaid-syntax",
    contracts=MERMAID_CONTRACTS,
    doc_only=None,  # set below, once DOC_ONLY_MERMAID_RULES is defined
    doc_file="rules/platform-independence.md",
    doc_heading_pattern=r"\*\*(Mermaid[^*]*?)\*\*:",
    enforcement_file=f"{PARITY_SRC}/validators/mermaid_syntax_validator.py",
    enforcement_pattern=r'f"\{source\}:\{lineno\}: ([a-z][^"{]*?)(?:\s*"|\()',
)

FILENAME_FAMILY = ContractFamily(
    name="spec-filename",
    contracts=FILENAME_CONTRACTS,
    enforcement_file=f"{PARITY_SRC}/validators/spec_filename_validator.py",
    enforcement_pattern=r'f"\{rel\}(?:/\{name\})?: ([a-z][a-z ]*[a-z])',
    doc_file=None,
    doc_heading_pattern=None,
    doc_orphan_blocked_by=(
        "The filename convention has no single normative home. It is stated in "
        "spec-usecase-engineering/SKILL.md:62, spec-user-story-engineering/SKILL.md:73 "
        "and schema-specification-engineering/SKILL.md:39,89 — the same fragmentation "
        "issue #289 fixed for the Mermaid rules by designating "
        "rules/platform-independence.md as the normative home. Orphan-documentation "
        "detection for this family is blocked until an equivalent home exists. Tracked "
        "as a follow-up to #300."
    ),
)

FAMILIES: List[ContractFamily] = [MERMAID_FAMILY, FILENAME_FAMILY]

ALL_CONTRACTS: List[RuleContract] = [c for f in FAMILIES for c in f.contracts]


# Rule families known to exist and deliberately not yet registered. Listing them
# keeps the gap explicit: an empty registry section is indistinguishable from a
# complete one otherwise.
KNOWN_UNREGISTERED_FAMILIES = {
    "schema-container-cardinality": "covered ad hoc by test_schema_container_docs_issue283.py",
    "authorization-precedence": "covered ad hoc by test_authorization_precedence.py",
    "python-version-reconciliation": "covered ad hoc by test_ci_workflow_config.py",
    "skill-path-references": "covered ad hoc by test_skill_path_references.py",
    "spec-filename-uniqueness": "not yet enforced at all - issue #300",
}


# Documented Mermaid rule headings in rules/platform-independence.md that are
# intentionally not paired with an enforcement anchor, with the reason. Anything not
# listed here and not in the registry is an orphan-documentation failure.
# Known divergences between a governing document and the implemented rule, recorded so
# they are visible rather than forgotten. Each must name the amendment that resolves it.
# An agent may not edit .pipeline/constitution.md (AGENTS.md:59, project-constitution
# Core Mandate 4), so constitution-level divergences can only be recorded here and
# submitted for human approval.
# OPEN divergences. Empty is the goal, not a defect — but the structure must remain so
# a future divergence has a defined home rather than being left undocumented.
KNOWN_DOC_DIVERGENCES: dict = {}


# RESOLVED divergences, retained as history. Each MUST name the amendment or change that
# resolved it, so the register records how divergences were closed and not merely that
# they vanished.
RESOLVED_DIVERGENCES = {
    "constitution-lifeline-actor-exemption": (
        ".pipeline/constitution.md:41 required every sequence-diagram lifeline to resolve "
        "to a defined Class or Component, while issue #277 option B exempts external UML "
        "actors. RESOLVED by AMEND-0001, which added the exemption and restated the "
        "requirement for all non-actor lifelines."
    ),
    "constitution-proceed-keyword-sufficiency": (
        ".pipeline/constitution.md:120 treated an authorization keyword as sufficient, "
        "while .agents/AGENTS.md:7 states it is not without an approved plan; issue #295 "
        "unified on the stricter reading. RESOLVED by AMEND-0002, which now requires both "
        "an approved implementation plan and the keyword."
    ),
}


DOC_ONLY_MERMAID_RULES = {
    "Mermaid Class Naming Rules": (
        "Backtick/quote requirements for class names are enforced inside the class "
        "diagram parser rather than the syntax validator; pairing deferred."
    ),
}


# Bound after definition: the Mermaid family's intentional doc-only exemptions.
MERMAID_FAMILY = ContractFamily(
    name=MERMAID_FAMILY.name,
    contracts=MERMAID_FAMILY.contracts,
    enforcement_file=MERMAID_FAMILY.enforcement_file,
    enforcement_pattern=MERMAID_FAMILY.enforcement_pattern,
    doc_file=MERMAID_FAMILY.doc_file,
    doc_heading_pattern=MERMAID_FAMILY.doc_heading_pattern,
    doc_only=DOC_ONLY_MERMAID_RULES,
)
FAMILIES = [MERMAID_FAMILY, FILENAME_FAMILY]
ALL_CONTRACTS = [c for f in FAMILIES for c in f.contracts]


# The `id` field of each contract is the same string validators pass as Finding.rule_id.
# tests/test_rule_contracts.py asserts every emitted rule id is registered here, so a new
# finding cannot become invisible to aggregation (#301) or undocumented (#299).
REGISTERED_RULE_IDS = {c.id for c in ALL_CONTRACTS}
