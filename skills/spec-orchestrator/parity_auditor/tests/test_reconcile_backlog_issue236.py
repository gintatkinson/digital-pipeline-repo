import os
import sys
import tempfile
import pytest

SCRIPT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "scripts"))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from reconcile_backlog import sanitize_source_references, write_markdown_file, sync_issue_body_to_tracker

def test_sanitize_source_references_converts_workstation_file_uris():
    content = (
        "# Feature 01: Backlog Reconciliation\n\n"
        "## 1. Context and References\n"
        "- **File**: file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/scripts/reconcile_backlog.py#L271-L317\n\n"
        "## 6. Source References\n"
        "- **Primary Source**: [reconcile_backlog.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/scripts/reconcile_backlog.py:271-317)\n"
        "- **Auxiliary Source**: file:///Users/developer/digital-pipeline-repo/docs/features/feat-01.md\n"
    )

    workspace_dir = "/Users/perkunas/jail/digital-pipeline-repo"
    rules = {
        "tracker_rules": {},
        "meta": {"upstream_repository": "gintatkinson/digital-pipeline-repo"}
    }

    sanitized = sanitize_source_references(content, workspace_dir=workspace_dir, rules=rules)

    # Assert local workstation URIs are completely sanitized
    assert "file:///Users/" not in sanitized
    assert "file:///" not in sanitized

    # Assert clean GitHub URLs are generated
    assert "https://github.com/gintatkinson/digital-pipeline-repo/blob/main/skills/spec-orchestrator/scripts/reconcile_backlog.py#L271-L317" in sanitized
    assert "https://github.com/gintatkinson/digital-pipeline-repo/blob/main/skills/spec-orchestrator/scripts/reconcile_backlog.py:271-317" in sanitized
    assert "https://github.com/gintatkinson/digital-pipeline-repo/blob/main/docs/features/feat-01.md" in sanitized

def test_write_markdown_file_sanitizes_local_file_uris():
    content = (
        "# Feature 02: Audit Logging\n\n"
        "## 6. Source References\n"
        "- **Ref**: file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/scripts/reconcile_backlog.py\n"
    )

    with tempfile.TemporaryDirectory() as tmpdir:
        spec_path = os.path.join(tmpdir, "feat-02.md")

        rules = {
            "tracker_rules": {},
            "meta": {"upstream_repository": "gintatkinson/digital-pipeline-repo"}
        }

        written_content = write_markdown_file(spec_path, content, workspace_dir="/Users/perkunas/jail/digital-pipeline-repo", rules=rules)

        assert "file:///Users/" not in written_content
        assert "https://github.com/gintatkinson/digital-pipeline-repo/blob/main/skills/spec-orchestrator/scripts/reconcile_backlog.py" in written_content

        with open(spec_path, "r", encoding="utf-8") as f:
            saved_content = f.read()

        assert "file:///Users/" not in saved_content
        assert "https://github.com/gintatkinson/digital-pipeline-repo/blob/main/skills/spec-orchestrator/scripts/reconcile_backlog.py" in saved_content
