"""The contract gate for issue #298.

Asserts that documentation and enforcement stay paired, in both directions.

Seven defects in one audit session were the same class — documented contract
diverging from enforced contract. Fixing them individually has no terminating
condition; instance eight is already out there. These tests are the terminating
condition for the Mermaid family.

Scope is stated deliberately and narrowly: this covers the Mermaid syntax rules.
``rule_contracts.KNOWN_UNREGISTERED_FAMILIES`` lists the families not yet covered so
the gap is explicit rather than implied by an empty section.
"""

import os
import re

import pytest

from rule_contracts import (
    ALL_CONTRACTS,
    DOC_ONLY_MERMAID_RULES,
    KNOWN_UNREGISTERED_FAMILIES,
    RuleContract,
)

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PLATFORM_RULES = os.path.join(REPO_ROOT, "rules", "platform-independence.md")
MERMAID_VALIDATOR = os.path.join(
    REPO_ROOT, "skills", "spec-orchestrator", "parity_auditor", "src",
    "parity_auditor", "validators", "mermaid_syntax_validator.py",
)


def _read(path):
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


# --------------------------------------------------------------------------- #
# Vacuity guards. A registry test matching nothing is worse than no test.
# --------------------------------------------------------------------------- #

def test_registry_is_populated():
    assert len(ALL_CONTRACTS) >= 5, (
        f"registry holds only {len(ALL_CONTRACTS)} contracts; the assertions below "
        "would be close to vacuous"
    )
    assert all(isinstance(c, RuleContract) for c in ALL_CONTRACTS)


def test_registry_ids_are_unique():
    ids = [c.id for c in ALL_CONTRACTS]
    dupes = sorted({i for i in ids if ids.count(i) > 1})
    assert not dupes, f"duplicate contract ids: {dupes}"


def test_scope_limit_is_declared():
    """The registry must name what it does not cover."""
    assert KNOWN_UNREGISTERED_FAMILIES, (
        "KNOWN_UNREGISTERED_FAMILIES must list the families not yet registered, so "
        "an incomplete registry is distinguishable from a complete one"
    )


# --------------------------------------------------------------------------- #
# (a) and (b): both anchors of every contract must resolve.
# --------------------------------------------------------------------------- #

@pytest.mark.parametrize("contract", ALL_CONTRACTS, ids=lambda c: c.id)
def test_documentation_anchor_resolves(contract):
    path = os.path.join(REPO_ROOT, contract.documented_in)
    assert os.path.isfile(path), f"{contract.id}: doc file missing: {contract.documented_in}"
    assert contract.doc_anchor in _read(path), (
        f"{contract.id}: '{contract.doc_anchor}' not found in {contract.documented_in}. "
        "The rule is enforced but no longer documented — orphan enforcement."
    )


@pytest.mark.parametrize("contract", ALL_CONTRACTS, ids=lambda c: c.id)
def test_enforcement_anchor_resolves(contract):
    path = os.path.join(REPO_ROOT, contract.enforced_in)
    assert os.path.isfile(path), f"{contract.id}: source missing: {contract.enforced_in}"
    assert contract.enforcement_anchor in _read(path), (
        f"{contract.id}: '{contract.enforcement_anchor}' not found in "
        f"{contract.enforced_in}. The rule is documented but no longer enforced — "
        "orphan documentation."
    )


# --------------------------------------------------------------------------- #
# (c) Orphan documentation. This is issue #289's defect class.
# --------------------------------------------------------------------------- #

def _documented_mermaid_rule_headings():
    """Every '**Mermaid ... Rules**:' bullet heading in the normative rules file."""
    return set(re.findall(r"\*\*(Mermaid[^*]*?)\*\*:", _read(PLATFORM_RULES)))


def test_documented_mermaid_rules_scan_is_not_vacuous():
    headings = _documented_mermaid_rule_headings()
    assert len(headings) >= 4, (
        f"only {len(headings)} Mermaid rule headings parsed from {PLATFORM_RULES}; "
        f"the orphan-documentation test would be near-vacuous. Found: {headings}"
    )


def test_every_documented_mermaid_rule_is_registered():
    registered = {c.doc_anchor for c in ALL_CONTRACTS}
    orphans = sorted(
        h for h in _documented_mermaid_rule_headings()
        if h not in registered and h not in DOC_ONLY_MERMAID_RULES
    )
    assert not orphans, (
        f"documented Mermaid rules with no registry entry: {orphans}. Either pair each "
        "with the code that enforces it, or record it in DOC_ONLY_MERMAID_RULES with a "
        "reason. A rule stated as prohibited but enforced by nothing is issue #289."
    )


# --------------------------------------------------------------------------- #
# (d) Orphan enforcement. This is issue #299's defect class.
# --------------------------------------------------------------------------- #

def _enforced_error_messages():
    """Literal error prefixes the Mermaid validator can emit.

    Extracted from the f-string bodies appended to ``errors``. Deliberately keyed on
    the human-readable phrase rather than a rule id, because that phrase is what a
    maintainer greps for when a downstream symptom appears.
    """
    source = _read(MERMAID_VALIDATOR)
    return set(re.findall(r'f"\{source\}:\{lineno\}: ([a-z][^"{]*?)(?:\s*"|\()', source))


def test_enforced_message_scan_is_not_vacuous():
    messages = _enforced_error_messages()
    assert len(messages) >= 4, (
        f"only {len(messages)} enforced Mermaid messages parsed; the orphan-enforcement "
        f"test would be near-vacuous. Found: {messages}"
    )


def test_every_enforced_mermaid_rule_is_registered():
    registered = [c.enforcement_anchor for c in ALL_CONTRACTS]
    orphans = sorted(
        msg for msg in _enforced_error_messages()
        if not any(anchor in msg or msg in anchor for anchor in registered)
    )
    assert not orphans, (
        f"the Mermaid validator rejects content for reasons with no registry entry: "
        f"{orphans}. Every enforced rule must be paired with the document that states "
        "it, or a generating subagent cannot comply. This is issue #299."
    )


# --------------------------------------------------------------------------- #
# Known divergences must stay visible, and must not silently accumulate.
# --------------------------------------------------------------------------- #

def test_known_divergences_are_documented_with_a_resolution_path():
    """A recorded divergence is acceptable; an undescribed one is not.

    These exist because an agent may not edit .pipeline/constitution.md, so a
    constitution-level mismatch can only be recorded and escalated. Each entry must
    name where the operative rule lives and what amendment resolves it.
    """
    from rule_contracts import KNOWN_DOC_DIVERGENCES

    assert KNOWN_DOC_DIVERGENCES, "the divergence register must not be silently emptied"
    for key, description in KNOWN_DOC_DIVERGENCES.items():
        assert len(description) > 80, (
            f"divergence '{key}' needs a description naming the governing document, the "
            "implemented rule, and the amendment that resolves it"
        )
        assert "pending" in description.lower() or "amendment" in description.lower(), (
            f"divergence '{key}' must state its resolution path, or it is just a "
            "permanent excuse"
        )
