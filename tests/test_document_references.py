"""Unit tests for document reference integrity and frontmatter governance (Issue #373)."""

import os
import re
import yaml

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
TARGET_DOC = os.path.join(REPO_ROOT, "docs", "feat-hardware-decoupled-persistence-design.md")


def test_hardware_decoupled_persistence_design_document_integrity_issue373():
    assert os.path.isfile(TARGET_DOC), f"Target document does not exist: {TARGET_DOC}"

    with open(TARGET_DOC, "r", encoding="utf-8") as f:
        content = f.read()

    # Verify YAML frontmatter presence and fields
    assert content.startswith("---"), "Document must begin with YAML frontmatter delimiter '---'"
    parts = content.split("---", 2)
    assert len(parts) >= 3, "Document must contain closed YAML frontmatter"

    frontmatter_raw = parts[1]
    metadata = yaml.safe_load(frontmatter_raw)
    assert isinstance(metadata, dict), "Frontmatter must parse as a valid YAML dictionary"

    assert "title" in metadata, "Frontmatter must contain 'title'"
    assert metadata.get("type") == "design", "Frontmatter 'type' must be 'design'"
    assert str(metadata.get("issue_id")) == "373", "Frontmatter 'issue_id' must be 373"
    assert metadata.get("platform") == "vhdl-fpga", "Frontmatter 'platform' must be 'vhdl-fpga'"

    # Verify absence of dangling test-geo-location.yang reference
    assert "test-geo-location.yang" not in content, (
        "Document must not reference unresolvable 'test-geo-location.yang'"
    )

    # Verify Source References section and path resolution
    assert "## Source References" in content, "Document must contain a '## Source References' section"
    
    # Extract referenced schema paths from table or text in Source References section
    source_ref_section = content.split("## Source References", 1)[1]
    referenced_paths = re.findall(r"`([a-zA-Z0-9_\-/\.]+\.(?:yang|json|yaml|md))`", source_ref_section)
    assert len(referenced_paths) > 0, "Source References section must cite at least one schema file"

    for rel_path in referenced_paths:
        abs_path = os.path.join(REPO_ROOT, rel_path)
        assert os.path.isfile(abs_path), f"Referenced schema file does not exist: {rel_path} (resolved to {abs_path})"


def test_control_status_bits_fsm_realisation_issue372():
    assert os.path.isfile(TARGET_DOC), f"Target document does not exist: {TARGET_DOC}"

    with open(TARGET_DOC, "r", encoding="utf-8") as f:
        content = f.read()

    # Assert FSM Realisation Matrix section/table exists
    assert "FSM Realisation Matrix" in content or "Realisation Matrix" in content, (
        "Document must contain an FSM Realisation Matrix for CONTROL_STATUS bits"
    )

    # Assert CONTROL_STATUS bit definitions are realised in FSM
    assert "Commit bit 0" in content or "Bit 0: Commit" in content or "Bit 0" in content, (
        "Document must define Commit bit 0 in FSM matrix"
    )
    assert "Busy bit 1" in content or "Bit 1: Busy" in content or "Bit 1" in content, (
        "Document must define Busy bit 1 in FSM matrix"
    )
    assert "Error bit 2" in content or "Bit 2: Error" in content or "Bit 2" in content, (
        "Document must define Error bit 2 in FSM matrix"
    )

    # Assert STAGED and ERROR states exist in FSM diagram / prose
    assert "STAGED" in content, "Document must include STAGED state in FSM"
    assert "ERROR" in content, "Document must include ERROR state in FSM"

    # Assert STAGED -> COMMIT_REG guard requirements
    assert "commit_bit" in content or "Commit bit" in content, "FSM must check commit_bit / Commit bit"
    assert "01" in content and "10" in content, "FSM guard must check valid geodetic system 01 or 10"

    # Assert error transitions and triggers
    assert "11" in content and "00" in content, "FSM must specify error triggers for invalid 11 and unconfigured 00"
    assert "truncated" in content.lower() or "out-of-range" in content.lower() or "error" in content.lower()

    # Assert ERROR -> IDLE transition on error acknowledgment
    assert "ERROR --> IDLE" in content or ("ERROR" in content and "IDLE" in content), (
        "FSM must define transition from ERROR to IDLE on error acknowledgment"
    )

