import os
import sys
import tempfile
import json
import shutil
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from parity_auditor.validators.logical_ui_validator import LogicalUiValidator
from parity_auditor.core.workspace import WorkspaceRepository

def test_logical_ui_validator_tabbed_container_constraint():
    tmpdir = tempfile.mkdtemp()
    try:
        pipeline_dir = os.path.join(tmpdir, ".pipeline", "logical-ui")
        os.makedirs(pipeline_dir, exist_ok=True)
        
        # Write codebase_rules.json
        rules = {
            "meta": {},
            "target_directories": {
                "flutter": "app_flutter"
            },
            "flutter_rules": {
                "file_extensions": [".dart"],
                "exclusions": [],
                "ui_directories": [],
                "network_directories": [],
                "selection_setters": [],
                "selection_triggers": [],
                "loop_guard_keywords": [],
                "forbidden_words": [],
                "forbidden_words_message": "",
                "write_lock_keywords": [],
                "playhead_clamp_regex": [],
                "ffi_keywords": [],
                "ffi_finalizer_keywords": [],
                "ffi_refcount_keywords": [],
                "viewport_file_patterns": [],
                "network_file_patterns": []
            },
            "python_rules": {
                "exclusions": []
            },
            "spec_rules": {
                "design_tokens_path": ".pipeline/logical-ui/design-tokens.json",
                "spec_files": []
            },
            "validation_rules": {
                "playhead_rate_limits": [0.90, 1.10],
                "dom_leak_patterns": [],
                "pixel_leak_patterns": []
            },
            "backlog_directories": {
                "epics": ".pipeline/backlog/epics",
                "features": ".pipeline/backlog/features",
                "use_cases": ".pipeline/backlog/use_cases",
                "user_stories": ".pipeline/backlog/user_stories"
            }
        }
        with open(os.path.join(pipeline_dir, "codebase_rules.json"), "w") as f:
            json.dump(rules, f)

        # Create features directory
        features_dir = os.path.join(tmpdir, ".pipeline", "backlog", "features")
        os.makedirs(features_dir, exist_ok=True)

        # Write logical-layout.json with violation
        layout = {
            "type": "TabbedContainer",
            "id": "details_and_relations_tab",
            "children": [
                {
                    "type": "TableView",
                    "id": "valid_child"
                },
                {
                    "type": "PropertyGrid",
                    "id": "properties_view"
                }
            ]
        }
        with open(os.path.join(pipeline_dir, "logical-layout.json"), "w") as f:
            json.dump(layout, f)

        repo = WorkspaceRepository(tmpdir)
        validator = LogicalUiValidator()
        errors = validator.validate(repo)

        assert any("TabbedContainer 'details_and_relations_tab' contains non-TableView child 'properties_view' of type 'PropertyGrid'" in err for err in errors), f"Expected constraint error, got: {errors}"
        
        # Write logical-layout.json PASSING
        layout_passing = {
            "type": "TabbedContainer",
            "id": "details_and_relations_tab",
            "children": [
                {
                    "type": "TableView",
                    "id": "valid_child"
                }
            ]
        }
        with open(os.path.join(pipeline_dir, "logical-layout.json"), "w") as f:
            json.dump(layout_passing, f)
            
        errors_passing = validator.validate(repo)
        assert not any("TabbedContainer 'details_and_relations_tab' contains non-TableView child" in err for err in errors_passing), f"Did not expect constraint error, got: {errors_passing}"

    finally:
        shutil.rmtree(tmpdir)
