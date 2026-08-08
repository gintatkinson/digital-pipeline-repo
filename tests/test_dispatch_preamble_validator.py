"""
Test suite for DispatchPreambleValidator.

Verifies that subagent dispatch prompts are programmatically checked for mandatory
governance preamble markers (constitution, §1.9 Zero-Mocking, 3-Layer DoD, RED-GREEN-REFACTOR,
build/test commands, view_file mandate) and that skills/feature-driven-implementation/SKILL.md
documents these requirements and the subagent failure protocol.
"""

import os
import pytest
from parity_auditor.validators.dispatch_preamble_validator import (
    DispatchPreambleValidator,
    validate_dispatch_prompt,
    MANDATORY_PREAMBLE_MARKERS,
)

COMPLIANT_PROMPT = """
You are a context-isolated subagent.
Adopt the feature-driven-implementation skill.
First step: Execute view_file on skills/feature-driven-implementation/SKILL.md as step 1 before doing any file edits.
Obey Section 1.9 Zero-Mocking Live Persistence Mandate.
Adhere strictly to 3-Layer Definition of Done (DoD).
Follow the RED-GREEN-REFACTOR cycle strictly.
Verify using flutter analyze (0 issues), flutter test (all pass).
Implement Micro-Task 1: Create widget model. PROCEED
"""

DEGRADED_PROMPT_MISSING_TDD = """
You are a context-isolated subagent.
Adopt the feature-driven-implementation skill.
First step: Execute view_file on skills/feature-driven-implementation/SKILL.md as step 1 before doing any file edits.
Obey Section 1.9 Zero-Mocking Live Persistence Mandate.
Adhere strictly to 3-Layer Definition of Done (DoD).
Verify using flutter analyze (0 issues), flutter test (all pass).
Implement Micro-Task 1: Create widget model. PROCEED
"""

EMPTY_PROMPT = "Implement Micro-Task 1: Create widget model. PROCEED"


def test_mandatory_markers_constant_completeness():
    """Verify MANDATORY_PREAMBLE_MARKERS contains all 6 required governance markers."""
    assert len(MANDATORY_PREAMBLE_MARKERS) >= 6
    expected_substrings = [
        "feature-driven-implementation",
        "view_file",
        "1.9 Zero-Mocking",
        "3-Layer Definition of Done",
        "RED-GREEN-REFACTOR",
        "flutter analyze",
    ]
    for expected in expected_substrings:
        assert any(expected in marker for marker in MANDATORY_PREAMBLE_MARKERS), (
            f"Expected substring '{expected}' missing from MANDATORY_PREAMBLE_MARKERS"
        )


def test_validate_dispatch_prompt_positive():
    """Compliant prompt with all preamble markers returns empty missing list."""
    missing = validate_dispatch_prompt(COMPLIANT_PROMPT)
    assert missing == [], f"Expected no missing markers, got: {missing}"


def test_validate_dispatch_prompt_negative_degraded():
    """Degraded prompt missing RED-GREEN-REFACTOR returns the missing marker."""
    missing = validate_dispatch_prompt(DEGRADED_PROMPT_MISSING_TDD)
    assert len(missing) == 1
    assert "RED-GREEN-REFACTOR" in missing[0]


def test_validate_dispatch_prompt_negative_empty():
    """Bare prompt missing all preamble markers returns all mandatory markers."""
    missing = validate_dispatch_prompt(EMPTY_PROMPT)
    assert len(missing) == len(MANDATORY_PREAMBLE_MARKERS)


def test_validator_class_structure():
    """DispatchPreambleValidator class instantiates and validates prompt text."""
    validator = DispatchPreambleValidator()
    missing = validator.validate_prompt(COMPLIANT_PROMPT)
    assert missing == []

    missing_degraded = validator.validate_prompt(DEGRADED_PROMPT_MISSING_TDD)
    assert len(missing_degraded) == 1


def test_feature_driven_implementation_skill_documentation():
    """Verify skills/feature-driven-implementation/SKILL.md documents the preamble markers and failure protocol."""
    skill_path = os.path.normpath(
        os.path.join(
            os.path.dirname(__file__),
            "../skills/feature-driven-implementation/SKILL.md",
        )
    )
    assert os.path.exists(skill_path), f"Skill file not found at {skill_path}"

    with open(skill_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check verbatim markers/terms documented
    assert "Governance Preamble" in content or "governance preamble" in content.lower()
    assert "Zero-Mocking" in content
    assert "3-Layer Definition of Done" in content or "3-Layer DoD" in content
    assert "RED-GREEN-REFACTOR" in content
    assert "view_file" in content
    assert "flutter analyze" in content or "build/test" in content.lower()

    # Check failure protocol documented
    assert "empty result" in content.lower()
    assert "two consecutive failures" in content.lower()
    assert "escalate" in content.lower()


def test_feature_driven_implementation_subagent_retry_limit_guard():
    """Verify skills/feature-driven-implementation/SKILL.md contains bounded retry limit and escalation guard terms."""
    skill_path = os.path.normpath(
        os.path.join(
            os.path.dirname(__file__),
            "../skills/feature-driven-implementation/SKILL.md",
        )
    )
    assert os.path.exists(skill_path), f"Skill file not found at {skill_path}"

    with open(skill_path, "r", encoding="utf-8") as f:
        content = f.read()

    assert "Output Integrity Verification" in content
    assert "subagent_dispatch_retry" in content
    assert "RETRY_LIMIT_EXCEEDED" in content
    assert "DONE (integrity verified)" in content or "integrity verified" in content

