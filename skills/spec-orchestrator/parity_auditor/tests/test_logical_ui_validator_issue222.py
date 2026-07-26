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


def test_logical_ui_validator_dynamic_path():
    tmpdir = tempfile.mkdtemp()
    try:
        custom_flutter_dir = "custom_app_flutter"
        
        pipeline_dir = os.path.join(tmpdir, ".pipeline", "logical-ui")
        os.makedirs(pipeline_dir, exist_ok=True)

        rules = {
            "meta": {},
            "target_directories": {"flutter": custom_flutter_dir},
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

        assets_dir = os.path.join(tmpdir, custom_flutter_dir, "assets")
        os.makedirs(assets_dir, exist_ok=True)
        
        layout = {
            "type": "TabbedContainer",
            "id": "details_and_relations_tab",
            "children": [
                {"type": "TableView", "id": "valid_child_1"}
            ]
        }
        with open(os.path.join(assets_dir, "logical-layout.json"), "w") as f:
            json.dump(layout, f)

        features_dir = os.path.join(tmpdir, ".pipeline", "backlog", "features")
        os.makedirs(features_dir, exist_ok=True)

        repo = WorkspaceRepository(tmpdir)
        validator = LogicalUiValidator()
        errors = validator.validate(repo)
        
        assert not any("logical-layout.json not found" in err for err in errors), f"Failed to find layout dynamically: {errors}"
    finally:
        shutil.rmtree(tmpdir)


def test_hypothesis_1_non_dict_children():
    tmpdir = tempfile.mkdtemp()
    try:
        layout = {
            "type": "TabbedContainer",
            "id": "tab_container_non_dict",
            "children": [
                "invalid_string_child",
                None,
                123
            ]
        }
        repo = _create_test_repo(tmpdir, layout)
        validator = LogicalUiValidator()
        errors = validator.validate(repo)
        expected_msg = "TabbedContainer 'tab_container_non_dict' contains non-TableView child 'unknown' of type 'unknown'"
        assert any(expected_msg in err for err in errors), f"Expected error for non-dict children, got: {errors}"
    finally:
        shutil.rmtree(tmpdir)


def test_hypothesis_2_null_or_empty_id_or_type():
    tmpdir = tempfile.mkdtemp()
    try:
        # Case 2a: type is null (None), id is null (None)
        layout_null = {
            "type": "TabbedContainer",
            "id": "tab_container_null_fields",
            "children": [
                {"type": None, "id": None}
            ]
        }
        repo = _create_test_repo(tmpdir, layout_null)
        validator = LogicalUiValidator()
        errors = validator.validate(repo)
        expected_msg_null = "TabbedContainer 'tab_container_null_fields' contains non-TableView child 'unknown' of type 'unknown'"
        assert any(expected_msg_null in err for err in errors), f"Expected error for null type/id, got: {errors}"

        # Case 2b: type is empty string, id is empty string
        layout_empty = {
            "type": "TabbedContainer",
            "id": "tab_container_empty_fields",
            "children": [
                {"type": "", "id": ""}
            ]
        }
        repo = _create_test_repo(tmpdir, layout_empty)
        errors = validator.validate(repo)
        expected_msg_empty = "TabbedContainer 'tab_container_empty_fields' contains non-TableView child 'unknown' of type 'unknown'"
        assert any(expected_msg_empty in err for err in errors), f"Expected error for empty type/id, got: {errors}"
    finally:
        shutil.rmtree(tmpdir)


def test_hypothesis_3_non_list_children():
    tmpdir = tempfile.mkdtemp()
    try:
        layout = {
            "type": "TabbedContainer",
            "id": "tab_container_non_list_children",
            "children": "invalid_children_string"
        }
        repo = _create_test_repo(tmpdir, layout)
        validator = LogicalUiValidator()
        errors = validator.validate(repo)
        expected_msg = "TabbedContainer 'tab_container_non_list_children' contains non-TableView child 'unknown' of type 'unknown'"
        assert any(expected_msg in err for err in errors), f"Expected error for non-list children attribute, got: {errors}"
    finally:
        shutil.rmtree(tmpdir)


def test_issue220_unprefixed_augmented_elements():
    tmpdir = tempfile.mkdtemp()
    try:
        layout = {"type": "TableView", "id": "table1"}
        repo = _create_test_repo(tmpdir, layout)

        features_dir = os.path.join(tmpdir, ".pipeline", "backlog", "features")
        
        # Write feature file with un-prefixed augmented element 'locations' and 'rack'
        feat_content = """---
title: "Test Feature"
---
## 5. Logical UI & Layout Bindings
- **Target LUI Component:** TableView
- **Target Layout Container ID:** table1
- **Data Source Bindings:** /network/locations/rack, /network/nil:racks, /network/locations[id=1]/rack-location
"""
        with open(os.path.join(features_dir, "feat-test.md"), "w") as f:
            f.write(feat_content)

        validator = LogicalUiValidator()
        errors = validator.validate(repo)
        
        rel_path = os.path.join(".pipeline", "backlog", "features", "feat-test.md")
        assert any(f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding '/network/locations/rack' contains un-prefixed augmented element 'locations'. Must use 'nil:locations'." in err for err in errors)
        assert any(f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding '/network/locations/rack' contains un-prefixed augmented element 'rack'. Must use 'nil:rack'." in err for err in errors)
        assert any(f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding '/network/locations[id=1]/rack-location' contains un-prefixed augmented element 'locations'. Must use 'nil:locations'." in err for err in errors)
        assert any(f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding '/network/locations[id=1]/rack-location' contains un-prefixed augmented element 'rack-location'. Must use 'nil:rack-location'." in err for err in errors)
        
        # Verify /network/nil:racks produces NO error for 'racks'
        assert not any("nil:racks" in err and "un-prefixed" in err for err in errors)
    finally:
        shutil.rmtree(tmpdir)


def test_issue219_geodetic_mapping_to_forbidden_topology():
    tmpdir = tempfile.mkdtemp()
    try:
        layout = {
            "type": "TopographicalView",
            "id": "topology_pane",
            "children": [
                {"type": "PropertyGrid", "id": "properties_view"}
            ]
        }
        repo = _create_test_repo(tmpdir, layout)

        features_dir = os.path.join(tmpdir, ".pipeline", "backlog", "features")
        rel_path_invalid = os.path.join(".pipeline", "backlog", "features", "feat-invalid-geodetic.md")
        rel_path_valid = os.path.join(".pipeline", "backlog", "features", "feat-valid-geodetic.md")

        # Feature mapping geodetic attributes to TopographicalView / topology_pane -> INVALID
        invalid_content = """---
title: "Invalid Geodetic Mapping Feature"
---
# Invalid Feature
Contains latitude and longitude coordinates.

## 5. Logical UI & Layout Bindings
- **Target LUI Component:** TopographicalView
- **Target Layout Container ID:** topology_pane
"""
        with open(os.path.join(features_dir, "feat-invalid-geodetic.md"), "w") as f:
            f.write(invalid_content)

        # Feature mapping geodetic attributes to PropertyGrid / properties_view -> VALID
        valid_content = """---
title: "Valid Geodetic Mapping Feature"
---
# Valid Feature
Contains latitude and longitude coordinates.

## 5. Logical UI & Layout Bindings
- **Target LUI Component:** PropertyGrid
- **Target Layout Container ID:** properties_view
"""
        with open(os.path.join(features_dir, "feat-valid-geodetic.md"), "w") as f:
            f.write(valid_content)

        validator = LogicalUiValidator()
        errors = validator.validate(repo)

        expected_err = f"Logical UI Compliance: Feature '{rel_path_invalid}' erroneously maps geodetic attribute(s) to forbidden topology component 'TopographicalView' or container ID 'topology_pane'."
        assert any(expected_err in err for err in errors), f"Expected error '{expected_err}', got: {errors}"
        assert not any("feat-valid-geodetic.md" in err and "erroneously maps geodetic attribute" in err for err in errors), f"Unexpected error for valid feature: {errors}"
    finally:
        shutil.rmtree(tmpdir)


def test_issue218_plain_text_data_source_binding():
    tmpdir = tempfile.mkdtemp()
    try:
        layout = {"type": "TableView", "id": "table1"}
        repo = _create_test_repo(tmpdir, layout)

        features_dir = os.path.join(tmpdir, ".pipeline", "backlog", "features")
        rel_path = os.path.join(".pipeline", "backlog", "features", "feat-plain-text.md")

        content = """---
title: "Plain Text Binding Feature"
---
## 5. Logical UI & Layout Bindings
- **Target LUI Component:** TableView
- **Target Layout Container ID:** table1
- **Data Source Bindings:** Plain text description, /valid/schema/path, invalid_no_prefix, schema:valid_schema
"""
        with open(os.path.join(features_dir, "feat-plain-text.md"), "w") as f:
            f.write(content)

        validator = LogicalUiValidator()
        errors = validator.validate(repo)

        assert any(f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding 'Plain text description' contains plain-text English instead of valid schema path." in err for err in errors)
        assert any(f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding 'invalid_no_prefix' contains plain-text English instead of valid schema path." in err for err in errors)
        assert not any("contains plain-text English" in err and "/valid/schema/path" in err for err in errors)
        assert not any("contains plain-text English" in err and "schema:valid_schema" in err for err in errors)
    finally:
        shutil.rmtree(tmpdir)


def test_issue217_strict_section_5_header_numbering():
    tmpdir = tempfile.mkdtemp()
    try:
        layout = {"type": "TableView", "id": "table1"}
        repo = _create_test_repo(tmpdir, layout)

        features_dir = os.path.join(tmpdir, ".pipeline", "backlog", "features")
        rel_path_unnumbered = os.path.join(".pipeline", "backlog", "features", "feat-unnumbered.md")
        rel_path_numbered = os.path.join(".pipeline", "backlog", "features", "feat-numbered.md")

        # Feature with unnumbered header
        content_unnumbered = """---
title: "Unnumbered Header UI Feature"
interface_type: ui
---
## Logical UI & Layout Bindings
- **Target LUI Component:** TableView
- **Target Layout Container ID:** table1
"""
        with open(os.path.join(features_dir, "feat-unnumbered.md"), "w") as f:
            f.write(content_unnumbered)

        # Feature with correctly numbered section 5 header
        content_numbered = """---
title: "Numbered Header UI Feature"
interface_type: ui
---
## 5. Logical UI & Layout Bindings
- **Target LUI Component:** TableView
- **Target Layout Container ID:** table1
"""
        with open(os.path.join(features_dir, "feat-numbered.md"), "w") as f:
            f.write(content_numbered)

        validator = LogicalUiValidator()
        errors = validator.validate(repo)

        expected_err = f"Logical UI Compliance: Feature '{rel_path_unnumbered}' is a UI feature but lacks the 'Logical UI & Layout Bindings' section."
        assert any(expected_err in err for err in errors), f"Expected missing section error for unnumbered header, got errors: {errors}"
        assert not any("feat-numbered.md" in err for err in errors), f"Unexpected error for valid numbered feature: {errors}"
    finally:
        shutil.rmtree(tmpdir)







