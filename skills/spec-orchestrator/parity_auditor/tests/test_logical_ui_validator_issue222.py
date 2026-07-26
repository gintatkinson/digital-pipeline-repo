import os
import sys
import tempfile
import json
import shutil
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from parity_auditor.validators.logical_ui_validator import LogicalUiValidator
from parity_auditor.core.workspace import WorkspaceRepository


def _create_test_repo(tmpdir, layout):
    pipeline_dir = os.path.join(tmpdir, ".pipeline", "logical-ui")
    os.makedirs(pipeline_dir, exist_ok=True)

    rules = {
        "meta": {},
        "target_directories": {"flutter": "app_flutter"},
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
        "python_rules": {"exclusions": []},
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

    features_dir = os.path.join(tmpdir, ".pipeline", "backlog", "features")
    os.makedirs(features_dir, exist_ok=True)

    with open(os.path.join(pipeline_dir, "logical-layout.json"), "w") as f:
        json.dump(layout, f)

    return WorkspaceRepository(tmpdir)


def test_tabbed_container_non_tableview_direct_children():
    tmpdir = tempfile.mkdtemp()
    try:
        non_tableview_types = ["PropertyGrid", "HierarchyTree", "ContextualPanel"]
        for child_type in non_tableview_types:
            layout = {
                "type": "TabbedContainer",
                "id": "main_tab_container",
                "children": [
                    {"type": "TableView", "id": "valid_table"},
                    {"type": child_type, "id": f"invalid_{child_type.lower()}"}
                ]
            }
            repo = _create_test_repo(tmpdir, layout)
            validator = LogicalUiValidator()
            errors = validator.validate(repo)
            expected_msg = f"TabbedContainer 'main_tab_container' contains non-TableView child 'invalid_{child_type.lower()}' of type '{child_type}'"
            assert any(expected_msg in err for err in errors), f"Expected error for {child_type}, got: {errors}"
    finally:
        shutil.rmtree(tmpdir)


def test_tabbed_container_deeply_nested():
    tmpdir = tempfile.mkdtemp()
    try:
        layout = {
            "type": "RootPanel",
            "id": "root",
            "children": [
                {
                    "type": "SplitPane",
                    "id": "split_pane_1",
                    "panels": [
                        {
                            "type": "TabbedContainer",
                            "id": "nested_tab_container",
                            "children": [
                                {"type": "TableView", "id": "table_1"},
                                {"type": "HierarchyTree", "id": "tree_view_1"}
                            ]
                        }
                    ]
                }
            ]
        }
        repo = _create_test_repo(tmpdir, layout)
        validator = LogicalUiValidator()
        errors = validator.validate(repo)
        expected_msg = "TabbedContainer 'nested_tab_container' contains non-TableView child 'tree_view_1' of type 'HierarchyTree'"
        assert any(expected_msg in err for err in errors), f"Expected error for nested TabbedContainer, got: {errors}"
    finally:
        shutil.rmtree(tmpdir)


def test_tabbed_container_invalid_or_missing_children():
    tmpdir = tempfile.mkdtemp()
    try:
        # Test case: TabbedContainer with child missing 'id' or having non-TableView type
        layout_missing_id = {
            "type": "TabbedContainer",
            "id": "tab_container_no_child_id",
            "children": [
                {"type": "ContextualPanel"}
            ]
        }
        repo = _create_test_repo(tmpdir, layout_missing_id)
        validator = LogicalUiValidator()
        errors = validator.validate(repo)
        expected_msg = "TabbedContainer 'tab_container_no_child_id' contains non-TableView child 'unknown' of type 'ContextualPanel'"
        assert any(expected_msg in err for err in errors), f"Expected error for child missing id, got: {errors}"

        # Test case: TabbedContainer missing container 'id'
        layout_missing_container_id = {
            "type": "TabbedContainer",
            "children": [
                {"type": "PropertyGrid", "id": "prop_grid"}
            ]
        }
        repo = _create_test_repo(tmpdir, layout_missing_container_id)
        errors = validator.validate(repo)
        expected_msg = "TabbedContainer 'unknown' contains non-TableView child 'prop_grid' of type 'PropertyGrid'"
        assert any(expected_msg in err for err in errors), f"Expected error for container missing id, got: {errors}"
    finally:
        shutil.rmtree(tmpdir)


def test_tabbed_container_valid_children():
    tmpdir = tempfile.mkdtemp()
    try:
        layout_passing = {
            "type": "TabbedContainer",
            "id": "details_and_relations_tab",
            "children": [
                {"type": "TableView", "id": "valid_child_1"},
                {"type": "TableView", "id": "valid_child_2"}
            ]
        }
        repo = _create_test_repo(tmpdir, layout_passing)
        validator = LogicalUiValidator()
        errors = validator.validate(repo)
        assert not any("contains non-TableView child" in err for err in errors), f"Unexpected errors: {errors}"
    finally:
        shutil.rmtree(tmpdir)

