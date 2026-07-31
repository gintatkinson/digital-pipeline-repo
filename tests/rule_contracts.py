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
from typing import List

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

ALL_CONTRACTS: List[RuleContract] = list(MERMAID_CONTRACTS)


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
KNOWN_DOC_DIVERGENCES = {
    "constitution-lifeline-actor-exemption": (
        ".pipeline/constitution.md:41 states 'Every lifeline in a sequence diagram MUST "
        "represent an instance of a defined logical Class or Component'. Issue #277 "
        "option B exempts lifelines declared as external UML actors, so the implemented "
        "rule is narrower than that sentence. The operative rule is documented in "
        "skills/spec-user-story-engineering/SKILL.md. A constitution amendment is "
        "pending human approval; see implementation_plan.md D6."
    ),
    "constitution-proceed-keyword-sufficiency": (
        ".pipeline/constitution.md:120 states that typing 'Proceed' is sufficient "
        "authorization. .agents/AGENTS.md:7 states a keyword is explicitly insufficient "
        "without an approved plan, and issue #295 unified on the stricter reading. The "
        "constitution sentence remains weaker. Amendment pending human approval."
    ),
}


DOC_ONLY_MERMAID_RULES = {
    "Mermaid Class Naming Rules": (
        "Backtick/quote requirements for class names are enforced inside the class "
        "diagram parser rather than the syntax validator; pairing deferred."
    ),
}
