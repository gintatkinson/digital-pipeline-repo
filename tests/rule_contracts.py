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
        id="mermaid-no-single-line-empty-class-body",
        documented_in="rules/platform-independence.md",
        doc_anchor="Mermaid Empty Class Body Rules",
        enforced_in=f"{PARITY_SRC}/validators/mermaid_syntax_validator.py",
        enforcement_anchor="single-line empty Mermaid class body",
        note=(
            "Issue #279. The reported rule -- forbid empty Mermaid classes outright -- "
            "would reject the canonical Feature template, whose ancestor container node "
            "is deliberately attribute-less. Only the single-line spelling is a defect: "
            "parsers/mermaid.py closes a class block only on a line that is exactly "
            "'}', so 'class X {}' leaves the block open and a later namespace-closing "
            "brace pops it, silently reassigning every following class."
        ),
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

    ``enforcement_files`` is the symmetric relaxation, added for issue #304. The first
    five families each had exactly one enforcing file, so ``enforcement_file`` was
    sufficient. It stops being sufficient as soon as a rule family spans validators —
    the schema-traceability rules are enforced by ``cardinality_validator`` and
    ``spec_validator`` together, and neither alone parses enough messages to clear the
    vacuity floor. When set, it lists every file to scan; ``enforcement_file`` remains
    the primary one, so existing families are unaffected and error messages still name
    a single obvious place to look.
    """

    name: str
    contracts: List[RuleContract]
    enforcement_file: str
    enforcement_pattern: str
    doc_file: Optional[str] = None
    doc_heading_pattern: Optional[str] = None
    doc_only: Optional[dict] = None
    doc_orphan_blocked_by: str = ""
    enforcement_files: Optional[List[str]] = None

    def enforcement_paths(self) -> List[str]:
        """Every file the orphan-enforcement scanner reads for this family."""
        return list(self.enforcement_files or [self.enforcement_file])


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

DOC_REFERENCE_CONTRACTS: List[RuleContract] = [
    RuleContract(
        id="doc-ref-repository-relative-skill-paths",
        documented_in="rules/document-references.md",
        doc_anchor="Repository-Relative Skill Paths",
        enforced_in="tests/test_skill_path_references.py",
        enforcement_anchor="documents reference paths through the '.agents/skills/' symlink",
        note="Enforced since #285, documented only at #310 — orphan enforcement for 3 issues.",
    ),
    RuleContract(
        id="doc-ref-cited-paths-resolve",
        documented_in="rules/document-references.md",
        doc_anchor="Cited Paths Must Resolve",
        enforced_in="tests/test_skill_path_references.py",
        enforcement_anchor="governance documents reference paths that do not exist",
    ),
    RuleContract(
        id="doc-ref-cited-steps-resolve",
        documented_in="rules/document-references.md",
        doc_anchor="Cited Steps Must Resolve",
        enforced_in="tests/test_skill_path_references.py",
        enforcement_anchor="governance documents cite steps that do not exist",
        note="The phantom 'Step 5.5' override citation, issue #307.",
    ),
    RuleContract(
        id="doc-ref-no-runtime-tool-names-in-directives",
        documented_in="rules/document-references.md",
        doc_anchor="Runtime Tool Names Belong In The Dispatch Table",
        enforced_in="tests/test_skill_path_references.py",
        enforcement_anchor="governance documents name concrete dispatch tools",
        note=(
            "Issue #312 established this rule twice — .agents/AGENTS.md scopes it to "
            "'nowhere else in this document' and rules/user-authorization-lock.md "
            "restates it for the authorization lock — so skills/ was covered by "
            "neither and feature-driven-implementation/SKILL.md:50 survived the sweep "
            "still naming a tool absent from this runtime. Documented normatively and "
            "given a gate here; the same missing-referent shape as the three rules "
            "above, with a tool as the referent instead of a path or a step."
        ),
    ),
]

DOC_REFERENCE_FAMILY = ContractFamily(
    name="document-references",
    contracts=DOC_REFERENCE_CONTRACTS,
    doc_file="rules/document-references.md",
    doc_heading_pattern=r"\*\*([A-Z][^*]*?)\*\*:",
    enforcement_file="tests/test_skill_path_references.py",
    # Terminate on ": " or ". " rather than a bare "." — one message embeds
    # ".agents/skills/", whose dot would otherwise truncate the extraction mid-path
    # and weaken orphan-enforcement detection for that rule.
    enforcement_pattern=r'"((?:governance )?documents [a-z][a-z\s\'./]{5,70}?)(?:: |\. )',
)

KARPATHY_CONTRACTS: List[RuleContract] = [
    RuleContract(
        id="karpathy-four-point-check-in-authorization-lock",
        documented_in="rules/user-authorization-lock.md",
        doc_anchor="4-point Karpathy and Pipeline Compliance Check",
        enforced_in="tests/test_karpathy_check_contract_issue312.py",
        enforcement_anchor=(
            "karpathy-gate: a governance document omits the four-point compliance check"
        ),
        note=(
            "Issue #312. Mandatory since the rule was written and enforced by nothing; "
            "not performed once during a session that produced 11 merges to main."
        ),
    ),
    RuleContract(
        id="karpathy-four-point-check-in-agents-md",
        documented_in=".agents/AGENTS.md",
        doc_anchor="4-point Karpathy and Pipeline Compliance Check",
        enforced_in="tests/test_karpathy_check_contract_issue312.py",
        enforcement_anchor=(
            "karpathy-gate: a governance document omits one of the four numbered points"
        ),
        note="The co-normative restatement. Deleting either statement must fail.",
    ),
    RuleContract(
        id="karpathy-delegation-scope-in-authorization-lock",
        documented_in="rules/user-authorization-lock.md",
        doc_anchor=(
            "The delegation duty binds for all repository source and specification "
            "writes, not only during named skill phases."
        ),
        enforced_in="tests/test_karpathy_check_contract_issue312.py",
        enforcement_anchor=(
            "karpathy-gate: a governance document omits the delegation scope statement"
        ),
        note=(
            "Point 4 was ambiguous about whether the delegation duty covered writes "
            "outside a named skill phase. The narrow reading was taken (#312)."
        ),
    ),
    RuleContract(
        id="karpathy-delegation-scope-in-agents-md",
        documented_in=".agents/AGENTS.md",
        doc_anchor=(
            "The delegation duty binds for all repository source and specification "
            "writes, not only during named skill phases."
        ),
        enforced_in="tests/test_karpathy_check_contract_issue312.py",
        enforcement_anchor=(
            "karpathy-gate: a governance document omits the delegation scope statement"
        ),
    ),
    RuleContract(
        id="karpathy-dispatch-machinery-is-runtime-neutral",
        documented_in=".agents/AGENTS.md",
        doc_anchor="Dispatch capability by runtime",
        enforced_in="tests/test_karpathy_check_contract_issue312.py",
        enforcement_anchor=(
            "karpathy-gate: agents md names a dispatch tool absent from the runtime"
        ),
        note=(
            "The remedy point 4 directs the agent to was specified as invoke_subagent "
            "and manage_subagents, neither of which exists in the Claude Code runtime, "
            "so literal compliance with AGENTS.md:75 was impossible (#312)."
        ),
    ),
]

KARPATHY_FAMILY = ContractFamily(
    name="karpathy-compliance-check",
    contracts=KARPATHY_CONTRACTS,
    enforcement_file="tests/test_karpathy_check_contract_issue312.py",
    enforcement_pattern=r'"(karpathy-gate: [a-z][a-z0-9 ]{5,80}?)(?:: |\. )',
    doc_file=None,
    doc_heading_pattern=None,
    doc_orphan_blocked_by=(
        "The check has no single normative home: it is stated co-normatively in "
        "rules/user-authorization-lock.md and .agents/AGENTS.md, and neither is a "
        "summary of the other. Scanning either alone for orphan documentation would "
        "report the other's statements as orphans. Both anchors of every contract "
        "above still resolve, so deleting either statement fails the suite; only the "
        "heading-scan half of orphan-documentation detection is blocked. Same "
        "fragmentation issue #289 fixed for the Mermaid rules by designating a "
        "normative home. Tracked as a follow-up to #312."
    ),
)

SUBAGENT_ISOLATION_CONTRACTS: List[RuleContract] = [
    RuleContract(
        id="subagent-isolation-mandate-in-orchestrator-skill",
        documented_in="skills/spec-orchestrator/SKILL.md",
        doc_anchor="Item-Level Subagent Context Isolation",
        enforced_in="tests/test_subagent_isolation_contract_issue278.py",
        enforcement_anchor=(
            "isolation-gate: a governance document omits the item level isolation mandate"
        ),
        note=(
            "Issue #278. Every specification item is drafted by a fresh subagent with "
            "no inherited session state."
        ),
    ),
    RuleContract(
        id="subagent-isolation-mandate-in-agents-md",
        documented_in=".agents/AGENTS.md",
        doc_anchor="Fresh, isolated context",
        enforced_in="tests/test_subagent_isolation_contract_issue278.py",
        enforcement_anchor=(
            "isolation-gate: a governance document omits the item level isolation mandate"
        ),
        note="The co-normative restatement. Deleting either statement must fail.",
    ),
    RuleContract(
        id="subagent-isolation-no-session-history-in-orchestrator-skill",
        documented_in="skills/spec-orchestrator/SKILL.md",
        doc_anchor="Do **NOT** pass the history of other items generated in the same run.",
        enforced_in="tests/test_subagent_isolation_contract_issue278.py",
        enforcement_anchor=(
            "isolation-gate: a governance document omits the no session history constraint"
        ),
        note=(
            "SKILL.md:74, the line issue #278 was filed against. It was already there; "
            "nothing asserted it stayed."
        ),
    ),
    RuleContract(
        id="subagent-isolation-no-session-history-in-agents-md",
        documented_in=".agents/AGENTS.md",
        doc_anchor="Do not copy the entire conversation history",
        enforced_in="tests/test_subagent_isolation_contract_issue278.py",
        enforcement_anchor=(
            "isolation-gate: a governance document omits the no session history constraint"
        ),
    ),
    RuleContract(
        id="subagent-isolation-marker-named-at-point-of-generation",
        documented_in="skills/spec-orchestrator/SKILL.md",
        doc_anchor="generation_mode",
        enforced_in="tests/test_subagent_isolation_contract_issue278.py",
        enforcement_anchor=(
            "isolation-gate: the drafting step omits the subagent generation mode marker"
        ),
        note=(
            "Issue #278, the real gap. The mandate was stated in two documents and the "
            "marker that proves compliance was named in neither, while the UML "
            "validator rejected any item lacking it -- the #299 shape, a rule a "
            "generating subagent was never shown."
        ),
    ),
    RuleContract(
        id="subagent-isolation-marker-in-spec-templates",
        documented_in="skills/schema-specification-engineering/SKILL.md",
        doc_anchor='generation_mode: "subagent"',
        enforced_in="tests/test_subagent_isolation_contract_issue278.py",
        enforcement_anchor=(
            "isolation-gate: a specification template omits the generation mode marker"
        ),
        note=(
            "Also stated in spec-user-story-engineering and spec-usecase-engineering; "
            "the test checks all three, this anchor pins the Epic/Feature home."
        ),
    ),
    RuleContract(
        id="subagent-isolation-marker-enforced-by-parity-auditor",
        documented_in="skills/spec-orchestrator/SKILL.md",
        doc_anchor="_validate_subagent_isolation",
        enforced_in="tests/test_subagent_isolation_contract_issue278.py",
        enforcement_anchor=(
            "isolation-gate: the parity auditor no longer enforces the isolation marker"
        ),
        note=(
            "Enforced for all four document types by validators/uml.py. Deleting the "
            "check, or narrowing it to fewer types, fails here."
        ),
    ),
    RuleContract(
        id="subagent-isolation-markdown-tables-not-banned-outright",
        documented_in="skills/spec-orchestrator/SKILL.md",
        doc_anchor="Markdown tables are not otherwise restricted",
        enforced_in="tests/test_subagent_isolation_contract_issue278.py",
        enforcement_anchor=(
            "isolation-gate: a governance document prohibits markdown tables outright"
        ),
        note=(
            "Issue #278 proposed 'The generation of Markdown tables is strictly "
            "prohibited'. reconcile_backlog.py::convert_frontmatter_to_table publishes "
            "a '| Metadata | Value |' table into every tracker issue body, so the "
            "literal remedy outlaws the pipeline's own output -- the #279 pattern, "
            "where the reported rule would have rejected the canonical template and "
            "only a narrower rule was correct."
        ),
    ),
]

SUBAGENT_ISOLATION_FAMILY = ContractFamily(
    name="subagent-isolation",
    contracts=SUBAGENT_ISOLATION_CONTRACTS,
    enforcement_file="tests/test_subagent_isolation_contract_issue278.py",
    # Only `isolation-gate:` messages are rules about the corpus. That file also emits
    # `isolation-guard:` messages, which are self-checks on its own fixtures and
    # scanners; pairing those with a document would be meaningless.
    enforcement_pattern=r'"(isolation-gate: [a-z][a-z0-9 ]{5,90})"',
    doc_file=None,
    doc_heading_pattern=None,
    doc_orphan_blocked_by=(
        "The mandate has no single normative home: it is stated co-normatively in "
        "skills/spec-orchestrator/SKILL.md and .agents/AGENTS.md, and the frontmatter "
        "marker that evidences it is stated in the three worker skill templates. "
        "Scanning any one of those for orphan documentation would report the others' "
        "statements as orphans. Both anchors of every contract above still resolve, so "
        "deleting any single statement fails the suite; only the heading-scan half of "
        "orphan-documentation detection is blocked. Same fragmentation issue #289 "
        "fixed for the Mermaid rules by designating a normative home. Tracked as a "
        "follow-up to #278."
    ),
)


SCHEMA_TRACEABILITY_CONTRACTS: List[RuleContract] = [
    RuleContract(
        id="schema-container-declaration-missing",
        documented_in="skills/schema-specification-engineering/SKILL.md",
        doc_anchor="Every Feature MUST declare exactly one schema container",
        enforced_in=f"{PARITY_SRC}/validators/cardinality_validator.py",
        enforcement_anchor="schema-container-declaration-missing",
        note=(
            "Issue #304. The first family whose enforcement anchors are rule ids rather "
            "than message fragments -- see SCHEMA_TRACEABILITY_FAMILY for why."
        ),
    ),
    RuleContract(
        id="schema-container-field-must-be-a-list",
        documented_in="skills/schema-specification-engineering/SKILL.md",
        doc_anchor="with exactly one entry containing the fully-qualified container path",
        enforced_in=f"{PARITY_SRC}/validators/cardinality_validator.py",
        enforcement_anchor="schema-container-field-must-be-a-list",
        note=(
            "The YAML shape, not merely the count: `schema_containers: module/thing` "
            "parses to a str and would otherwise be length-tested character by character."
        ),
    ),
    RuleContract(
        id="schema-container-declaration-empty",
        documented_in="skills/spec-usecase-engineering/SKILL.md",
        doc_anchor="with exactly one entry containing the container path",
        enforced_in=f"{PARITY_SRC}/validators/cardinality_validator.py",
        enforcement_anchor="schema-container-declaration-empty",
    ),
    RuleContract(
        id="schema-container-consolidation-forbidden",
        documented_in="skills/schema-specification-engineering/SKILL.md",
        doc_anchor="Multi-container Features are forbidden",
        enforced_in=f"{PARITY_SRC}/validators/cardinality_validator.py",
        enforcement_anchor="schema-container-consolidation-forbidden",
        note="The threshold corrected by issue #283; documented in both worker skills.",
    ),
    RuleContract(
        id="schema-container-path-must-be-fully-qualified",
        documented_in="skills/schema-specification-engineering/SKILL.md",
        doc_anchor="fully-qualified schema container path format",
        enforced_in=f"{PARITY_SRC}/validators/spec_validator.py",
        enforcement_anchor="schema-container-path-must-be-fully-qualified",
        note=(
            "A path without a module prefix colon cannot be resolved back to a YANG "
            "module, so container traceability is unverifiable."
        ),
    ),
]

SCHEMA_TRACEABILITY_FAMILY = ContractFamily(
    name="schema-traceability",
    contracts=SCHEMA_TRACEABILITY_CONTRACTS,
    enforcement_file=f"{PARITY_SRC}/validators/cardinality_validator.py",
    enforcement_files=[
        f"{PARITY_SRC}/validators/cardinality_validator.py",
        f"{PARITY_SRC}/validators/spec_validator.py",
    ],
    # The five families above scan for message *text*. This one scans for the rule id
    # passed to Finding(), which is strictly stronger now that validators are migrating
    # to structured findings (#304): a text scanner has to be re-tuned every time a
    # message is reworded, and silently stops matching when it is -- an orphan-detection
    # test that quietly matches nothing is the failure this registry exists to prevent.
    # The rule id is the thing the aggregator actually groups on, so pairing *it* with a
    # document is what the contract is really asserting.
    enforcement_pattern=r'Finding\(\s*"([a-z][a-z0-9-]+)"',
    doc_file=None,
    doc_heading_pattern=None,
    doc_orphan_blocked_by=(
        "Container traceability has no single normative home: it is stated for Features "
        "in schema-specification-engineering/SKILL.md:57,118 and for Use Cases in "
        "spec-usecase-engineering/SKILL.md:149, and neither is a summary of the other. "
        "Scanning either alone would report the other's statement as an orphan. Both "
        "anchors of every contract above still resolve, so deleting either statement "
        "fails the suite; only the heading-scan half of orphan-documentation detection "
        "is blocked. Same fragmentation issue #289 fixed for the Mermaid rules by "
        "designating a normative home. Tracked as a follow-up to #304."
    ),
)


BACKLOG_INTEGRITY_CONTRACTS: List[RuleContract] = [
    RuleContract(
        id="tracker-issue-without-local-specification",
        documented_in="rules/tracker-source-of-truth.md",
        doc_anchor="Registered Issues Must Have A Local Specification",
        enforced_in=f"{PARITY_SRC}/validators/sync_validator.py",
        enforcement_anchor="tracker-issue-without-local-specification",
        note=(
            "Issue #304 found this enforced since the validator was written and stated "
            "in no document -- the #299 shape. Documented as part of the migration."
        ),
    ),
    RuleContract(
        id="spec-index-collides-with-tracker-issue",
        documented_in="rules/tracker-source-of-truth.md",
        doc_anchor="Local Indices Must Not Collide With Registered Issues",
        enforced_in=f"{PARITY_SRC}/validators/sync_validator.py",
        enforcement_anchor="spec-index-collides-with-tracker-issue",
        note=(
            "Also undocumented before #304. Distinct from "
            "spec-filename-ordinal-uniqueness, which is a collision between two local "
            "files; this is a local ordinal colliding with a differently-titled issue "
            "already holding that ordinal on the tracker."
        ),
    ),
    RuleContract(
        id="schema-import-dependency-unspecified",
        documented_in=".pipeline/constitution.md",
        doc_anchor=(
            "Cross-module or external schema references must be explicitly documented "
            "with source and target module names"
        ),
        enforced_in=f"{PARITY_SRC}/validators/dependency_validator.py",
        enforcement_anchor="schema-import-dependency-unspecified",
    ),
    RuleContract(
        id="epic-imported-schema-prerequisite-link-missing",
        documented_in="skills/schema-specification-engineering/SKILL.md",
        doc_anchor="Schema Import Prerequisite Links",
        enforced_in=f"{PARITY_SRC}/validators/dependency_validator.py",
        enforcement_anchor="epic-imported-schema-prerequisite-link-missing",
        note=(
            "Undocumented before #304. The import ordering constraint was enforced and "
            "recorded nowhere a generating subagent would read it."
        ),
    ),
]

BACKLOG_INTEGRITY_FAMILY = ContractFamily(
    name="backlog-tracker-integrity",
    contracts=BACKLOG_INTEGRITY_CONTRACTS,
    enforcement_file=f"{PARITY_SRC}/validators/sync_validator.py",
    enforcement_files=[
        f"{PARITY_SRC}/validators/sync_validator.py",
        f"{PARITY_SRC}/validators/dependency_validator.py",
    ],
    enforcement_pattern=r'Finding\(\s*"([a-z][a-z0-9-]+)"',
    doc_file=None,
    doc_heading_pattern=None,
    doc_orphan_blocked_by=(
        "Three of the four rules are stated in rules/tracker-source-of-truth.md and "
        "the fourth in skills/schema-specification-engineering/SKILL.md, because the "
        "import-prerequisite rule governs how a specification is drafted rather than "
        "how the tracker is treated. Scanning either file alone would report the "
        "other's statement as an orphan. Both anchors of every contract above still "
        "resolve, so deleting any statement fails the suite; only the heading-scan "
        "half of orphan-documentation detection is blocked. Tracked as a follow-up "
        "to #304."
    ),
)


PLATFORM_PROFILE_CONTRACTS: List[RuleContract] = [
    RuleContract(
        id="profile-scoping-requires-platform-sources",
        documented_in=".pipeline/profiles/flutter.md",
        doc_anchor="Profile Scoping Requires Platform Sources",
        enforced_in=f"{PARITY_SRC}/validators/profile_scoping_validator.py",
        enforcement_anchor="profile-scoping-requires-platform-sources",
        note=(
            "Issue #304. The first family documented in a platform profile rather than "
            "in rules/: every rule here names the Flutter source tree, a Flutter widget "
            "or Flutter UI directories, so rules/platform-independence.md section Where "
            "platform-specific details belong sends it to the profile."
        ),
    ),
    RuleContract(
        id="flutter-splitter-requires-pointer-gesture-listener",
        documented_in=".pipeline/profiles/flutter.md",
        doc_anchor="Splitter Widgets Require Pointer Gesture Listeners",
        enforced_in=f"{PARITY_SRC}/validators/profile_scoping_validator.py",
        enforcement_anchor="flutter-splitter-requires-pointer-gesture-listener",
        note=(
            "Enforced since the validator was written and documented nowhere -- the "
            "#299 shape. A splitter without a Listener or GestureDetector renders as a "
            "divider that cannot be dragged, so the layout requirement is met visually "
            "and not functionally."
        ),
    ),
    RuleContract(
        id="schema-mapping-requires-platform-sources",
        documented_in=".pipeline/profiles/flutter.md",
        doc_anchor="Schema Mapping Requires Platform Sources",
        enforced_in=f"{PARITY_SRC}/validators/schema_mapping_validator.py",
        enforcement_anchor="schema-mapping-requires-platform-sources",
        note=(
            "Deliberately a distinct rule id from the profile-scoping precondition "
            "above, though the underlying condition -- no platform sources -- is the "
            "same. The two gates fail independently, and a grouped multi-workspace "
            "report that could not say which one fired would be ambiguous."
        ),
    ),
    RuleContract(
        id="schema-field-must-be-realised-in-the-codebase",
        documented_in=".pipeline/profiles/flutter.md",
        doc_anchor="Schema Fields Must Be Realised In The Codebase",
        enforced_in=f"{PARITY_SRC}/validators/schema_mapping_validator.py",
        enforcement_anchor="schema-field-must-be-realised-in-the-codebase",
    ),
    RuleContract(
        id="schema-field-must-be-bound-to-a-ui-component",
        documented_in=".pipeline/profiles/flutter.md",
        doc_anchor="Schema Fields Must Be Bound To A UI Component",
        enforced_in=f"{PARITY_SRC}/validators/schema_mapping_validator.py",
        enforcement_anchor="schema-field-must-be-bound-to-a-ui-component",
        note=(
            "Conditional on the workspace declaring flutter_rules.ui_directories; a "
            "project with no UI layer is not asked to bind anything."
        ),
    ),
]

PLATFORM_PROFILE_FAMILY = ContractFamily(
    name="platform-profile-compliance",
    contracts=PLATFORM_PROFILE_CONTRACTS,
    enforcement_file=f"{PARITY_SRC}/validators/profile_scoping_validator.py",
    enforcement_files=[
        f"{PARITY_SRC}/validators/profile_scoping_validator.py",
        f"{PARITY_SRC}/validators/schema_mapping_validator.py",
    ],
    enforcement_pattern=r'Finding\(\s*"([a-z][a-z0-9-]+)"',
    # Unlike every family registered before it, this one HAS a single normative home, so
    # orphan-documentation detection is live rather than blocked. `.pipeline/profiles/`
    # is where platform-specific constraints belong, and all five rules are Flutter-
    # specific, so nothing is fragmented across files here.
    doc_file=".pipeline/profiles/flutter.md",
    doc_heading_pattern=r"\*\*([A-Z][^*]*?)\*\*:",
)


COVERAGE_GATE_CONTRACTS: List[RuleContract] = [
    RuleContract(
        id="test-suite-must-exist-in-the-workspace",
        documented_in="rules/tdd-mandate.md",
        doc_anchor="Test Suite Must Exist",
        enforced_in=f"{PARITY_SRC}/validators/test_completeness_validator.py",
        enforcement_anchor="test-suite-must-exist-in-the-workspace",
        note="Issue #304. Undocumented before the migration -- the #299 shape.",
    ),
    RuleContract(
        id="test-suite-requires-regex-pattern-assertions",
        documented_in="rules/tdd-mandate.md",
        doc_anchor="Regex Pattern Assertions Required",
        enforced_in=f"{PARITY_SRC}/validators/test_completeness_validator.py",
        enforcement_anchor="test-suite-requires-regex-pattern-assertions",
    ),
    RuleContract(
        id="test-suite-requires-numerical-precision-assertions",
        documented_in="rules/tdd-mandate.md",
        doc_anchor="Numerical Precision Assertions Required",
        enforced_in=f"{PARITY_SRC}/validators/test_completeness_validator.py",
        enforcement_anchor="test-suite-requires-numerical-precision-assertions",
    ),
    RuleContract(
        id="test-suite-requires-computed-style-assertions",
        documented_in="rules/tdd-mandate.md",
        doc_anchor="Computed Style Assertions Required",
        enforced_in=f"{PARITY_SRC}/validators/test_completeness_validator.py",
        enforcement_anchor="test-suite-requires-computed-style-assertions",
    ),
    RuleContract(
        id="test-suite-requires-layout-size-assertions",
        documented_in="rules/tdd-mandate.md",
        doc_anchor="Layout Size Assertions Required",
        enforced_in=f"{PARITY_SRC}/validators/test_completeness_validator.py",
        enforcement_anchor="test-suite-requires-layout-size-assertions",
    ),
    RuleContract(
        id="test-suite-requires-exception-path-assertions",
        documented_in="rules/tdd-mandate.md",
        doc_anchor="Exception Path Assertions Required",
        enforced_in=f"{PARITY_SRC}/validators/test_completeness_validator.py",
        enforcement_anchor="test-suite-requires-exception-path-assertions",
    ),
    RuleContract(
        id="behavioral-trigger-node-must-be-covered-by-a-specification",
        documented_in="rules/behavioral-trigger-coverage.md",
        doc_anchor="Active Trigger Nodes Must Be Covered",
        enforced_in=f"{PARITY_SRC}/validators/behavioral.py",
        enforcement_anchor="behavioral-trigger-node-must-be-covered-by-a-specification",
        note=(
            "Issue #304 found the whole behavioural trigger mechanism enforced and "
            "stated in no document -- rules/behavioral_triggers.json carried the data "
            "and nothing carried the rule. rules/behavioral-trigger-coverage.md was "
            "written as its normative home."
        ),
    ),
    RuleContract(
        id="behavioral-trigger-rule-must-be-satisfied-by-the-specification",
        documented_in="rules/behavioral-trigger-coverage.md",
        doc_anchor="Trigger Rules Must Be Satisfied",
        enforced_in=f"{PARITY_SRC}/validators/behavioral.py",
        enforcement_anchor="behavioral-trigger-rule-must-be-satisfied-by-the-specification",
        note=(
            "Distinct from the coverage rule above: a file may reference the trigger "
            "node and still omit the Mermaid block or body terms the trigger requires, "
            "which looks like coverage and asserts nothing."
        ),
    ),
]

COVERAGE_GATE_FAMILY = ContractFamily(
    name="downstream-coverage-gates",
    contracts=COVERAGE_GATE_CONTRACTS,
    enforcement_file=f"{PARITY_SRC}/validators/test_completeness_validator.py",
    enforcement_files=[
        f"{PARITY_SRC}/validators/test_completeness_validator.py",
        f"{PARITY_SRC}/validators/behavioral.py",
    ],
    enforcement_pattern=r'Finding\(\s*"([a-z][a-z0-9-]+)"',
    doc_file=None,
    doc_heading_pattern=None,
    doc_orphan_blocked_by=(
        "Both validators assert that the downstream demonstrates coverage of something "
        "the pipeline declares, which is why they share a family: the test-completeness "
        "gate asserts coverage of the assertion classes required by rules/tdd-mandate.md, "
        "and the behavioural gate asserts coverage of the triggers declared in "
        "rules/behavioral_triggers.json and stated in rules/behavioral-trigger-coverage.md. "
        "Neither document is a summary of the other, so scanning either alone for orphan "
        "documentation would report the other's rules as orphans. Both anchors of every "
        "contract above still resolve, so deleting either statement fails the suite; only "
        "the heading-scan half of orphan-documentation detection is blocked. Splitting "
        "this into two families is the obvious alternative and does not work: the "
        "behavioural half would hold two contracts, below the vacuity floor that "
        "test_enforced_message_scan_is_not_vacuous applies to every family, and lowering "
        "that floor to accommodate one family would weaken it for all of them. Tracked as "
        "a follow-up to #304."
    ),
)


# NOTE: `FAMILIES` is bound ONCE, at the very bottom of this module, after
# `MERMAID_FAMILY` has been rebound with its doc-only exemptions. There used to be a
# binding here as well; the lower one shadowed it and omitted `DOC_REFERENCE_FAMILY`,
# so three registered contracts were asserted by nothing while the suite reported
# green. `tests/test_families_binding_is_unique.py` now fails on a second binding.
# Do not reintroduce one here.


# Rule families known to exist and deliberately not yet registered. Listing them
# keeps the gap explicit: an empty registry section is indistinguishable from a
# complete one otherwise.
KNOWN_UNREGISTERED_FAMILIES = {
    "schema-container-cardinality": "covered ad hoc by test_schema_container_docs_issue283.py",
    "authorization-precedence": "covered ad hoc by test_authorization_precedence.py",
    "python-version-reconciliation": "covered ad hoc by test_ci_workflow_config.py",
    # "spec-filename-uniqueness" was listed here as "not yet enforced at all - issue
    # #300". That stopped being true when #300 shipped spec_filename_validator.py and
    # FILENAME_FAMILY was registered in FAMILIES below, and the entry survived the
    # change. Removed at #304. A stale disclaimer is worse than no disclaimer: this
    # mapping exists so an incomplete registry is distinguishable from a complete one,
    # and an entry claiming a registered family is unenforced inverts that signal.
    # "document-references" was listed here while DOC_REFERENCE_FAMILY sat outside the
    # live FAMILIES binding. It is now registered and asserted, so the entry is gone
    # rather than being left as a stale disclaimer. The vacuity guard it tripped
    # (rules/document-references.md stated 3 rule headings against a guard of >= 4) was
    # resolved by documenting a fourth genuine constraint -- runtime dispatch tool names
    # belong only in the .agents/AGENTS.md dispatch table -- not by lowering the guard.
    # That rule was already normative in two file-scoped statements written for #312,
    # was violated by skills/feature-driven-implementation/SKILL.md:50 at the time of
    # writing, and is now mechanically enforced.
    "karpathy-check-performance": (
        "issue #312 - the two statements of the 4-point Karpathy and Pipeline "
        "Compliance Check and their scope sentence are now registered as the "
        "karpathy-compliance-check family, so deleting either statement fails the "
        "suite. That pairs documentation with documentation. Nothing verifies the "
        "check is actually PERFORMED: it is a per-turn reasoning obligation with no "
        "artefact in the repository, so no test over source can observe it. Closing "
        "this would need an out-of-band control - a transcript/thought-block auditor "
        "or a runtime pre-tool-use hook that refuses a coordinator write until the "
        "check is recorded for that turn. Neither exists here."
    ),
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
    "reconciler-auto-closes-issues": (
        "skills/spec-orchestrator/scripts/reconcile_backlog.py closed Epics, User "
        "Stories and Use Cases automatically at three call sites, while "
        ".pipeline/constitution.md:161 makes Closed unreachable without Product Owner "
        "validation. This was the enforced-side twin of the documentation divergence: "
        "the skills instructed closure and the tooling performed it, and AGENTS.md "
        "requires the reconciler run before every merge, so it was mandated to execute. "
        "RESOLVED by #309, which replaced close_issue_on_tracker with "
        "resolve_issue_on_tracker applying status:fixed-resolved plus an evidence "
        "comment, moved the idempotency guard from issue state onto the label, and "
        "corrected skills/spec-orchestrator/SKILL.md in the same change."
    ),
    "skills-instruct-closing-issues": (
        "skills/debug-protocol/SKILL.md and "
        "skills/feature-driven-implementation/SKILL.md instructed the agent to close "
        "tracker issues across 6 detected sites, while .pipeline/constitution.md:161 "
        "reserves Closed for Product Owner validation. "
        ".pipeline/upstream/pipeline-tooling.md declared an override, which could not "
        "work: AGENTS.md:75 mandates literal skill execution and that profile is "
        "upstream-only. RESOLVED by #306, which amended both skills to stop at "
        "Fixed / Resolved, narrowed debug-protocol's selection query to exclude "
        "status:fixed-resolved so the loop still terminates, and added "
        "tests/test_skills_never_close_issues_issue306.py as the enforcing gate."
    ),
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
# The single binding of FAMILIES. It must stay here, below the MERMAID_FAMILY rebinding
# above, because that rebinding is what attaches the doc-only exemptions; a list built
# before it would capture the exemption-less instance.
#
# There were formerly two bindings, and the second shadowed the first. The shadowed list
# held DOC_REFERENCE_FAMILY and the live one did not, so from #310 onward the three
# doc-ref contracts were derived into neither ALL_CONTRACTS nor any parametrized
# assertion — registered on paper, checked by nothing, suite green. That is this
# registry failing its own premise: it exists to detect a documented contract diverging
# from an enforced one, and the divergence was inside the detector.
#
# Any new family must be added to this list. tests/test_families_binding_is_unique.py
# asserts both halves of the invariant: exactly one binding of the name, and no
# ContractFamily defined in this module that is missing from it.
FAMILIES: List[ContractFamily] = [
    MERMAID_FAMILY,
    FILENAME_FAMILY,
    DOC_REFERENCE_FAMILY,
    KARPATHY_FAMILY,
    SUBAGENT_ISOLATION_FAMILY,
    SCHEMA_TRACEABILITY_FAMILY,
    BACKLOG_INTEGRITY_FAMILY,
    PLATFORM_PROFILE_FAMILY,
    COVERAGE_GATE_FAMILY,
]
ALL_CONTRACTS: List[RuleContract] = [c for f in FAMILIES for c in f.contracts]


# The `id` field of each contract is the same string validators pass as Finding.rule_id.
# tests/test_rule_contracts.py asserts every emitted rule id is registered here, so a new
# finding cannot become invisible to aggregation (#301) or undocumented (#299).
REGISTERED_RULE_IDS = {c.id for c in ALL_CONTRACTS}
