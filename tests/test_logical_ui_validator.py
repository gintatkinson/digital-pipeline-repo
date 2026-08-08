import json
import os
import pytest

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

LOGICAL_UI_PATH = os.path.join(REPO_ROOT, ".pipeline", "logical-ui", "logical-layout.json")
FLUTTER_ASSETS_PATH = os.path.join(REPO_ROOT, "app_flutter", "assets", "logical-layout.json")


def _find_container_by_id(node, target_id):
    if isinstance(node, dict):
        if node.get("id") == target_id:
            return node
        for val in node.values():
            res = _find_container_by_id(val, target_id)
            if res:
                return res
    elif isinstance(node, list):
        for item in node:
            res = _find_container_by_id(item, target_id)
            if res:
                return res
    return None


@pytest.mark.parametrize("layout_file_path", [LOGICAL_UI_PATH, FLUTTER_ASSETS_PATH])
def test_workspace_split_axis_is_vertical_and_has_no_nested_splitters(layout_file_path):
    assert os.path.exists(layout_file_path), f"Layout file does not exist: {layout_file_path}"
    with open(layout_file_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    workspace_split = _find_container_by_id(data, "workspace_split")
    assert workspace_split is not None, f"workspace_split container not found in {layout_file_path}"

    props = workspace_split.get("props", {})
    axis = props.get("axis")
    assert axis == "vertical", f"workspace_split axis is '{axis}', expected 'vertical' in {layout_file_path}"

    children = workspace_split.get("children", [])
    child_ids = [child.get("id") for child in children if isinstance(child, dict)]
    child_types = [child.get("type") for child in children if isinstance(child, dict)]

    # Assert no nested SplitWorkspace or ResizableSplitter exists inside workspace_split
    nested_splitters = [t for t in child_types if t in ("SplitWorkspace", "ResizableSplitter")]
    assert len(nested_splitters) == 0, f"Found nested splitters {nested_splitters} inside workspace_split in {layout_file_path}"
    assert "lower_split" not in child_ids, f"Found nested lower_split container in {layout_file_path}"

    # Assert workspace_split contains flattened items: topology_pane, elements_view, details_and_relations_tab
    assert "topology_pane" in child_ids, f"topology_pane missing from workspace_split in {layout_file_path}"
    assert "elements_view" in child_ids, f"elements_view missing from workspace_split in {layout_file_path}"
    assert "details_and_relations_tab" in child_ids, f"details_and_relations_tab missing from workspace_split in {layout_file_path}"
