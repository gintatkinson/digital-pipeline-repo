import os
import re
import json
from typing import List
from .base import IValidator
from ..core.workspace import WorkspaceRepository

class LogicalUiValidator(IValidator):
    def validate(self, repo: WorkspaceRepository, **kwargs) -> List[str]:
        rules = repo.get_codebase_rules()
        backlog_dirs = rules.backlog_directories
        
        flutter_dir = rules.target_directories.flutter if (rules.target_directories and rules.target_directories.flutter) else "app_flutter"
        # Check workspace_dir / .pipeline / logical-ui / logical-layout.json first
        layout_path = os.path.join(repo.workspace_dir, ".pipeline", "logical-ui", "logical-layout.json")
        if not os.path.exists(layout_path):
            # Check flutter_dir / assets / logical-layout.json next
            layout_path = os.path.join(repo.workspace_dir, flutter_dir, "assets", "logical-layout.json")
            
        component_types = set()
        container_ids = set()
        tabbed_container_errors = []
        
        if os.path.exists(layout_path):
            try:
                with open(layout_path, "r", encoding="utf-8") as f:
                    layout_data = json.load(f)
                    
                def traverse(node):
                    if isinstance(node, dict):
                        # Extract component type if present
                        node_type = node.get("type")
                        if isinstance(node_type, str):
                            component_types.add(node_type)
                        # Extract container/component ID if present
                        node_id = node.get("id")
                        if isinstance(node_id, str):
                            container_ids.add(node_id)

                        if isinstance(node_type, str) and node_type == "TabbedContainer":
                            container_id_str = node_id if (isinstance(node_id, str) and node_id) else "unknown"
                            children = node.get("children")
                            if not isinstance(children, list):
                                tabbed_container_errors.append(f"TabbedContainer '{container_id_str}' contains non-TableView child 'unknown' of type 'unknown'")
                            else:
                                for child in children:
                                    if not isinstance(child, dict):
                                        tabbed_container_errors.append(f"TabbedContainer '{container_id_str}' contains non-TableView child 'unknown' of type 'unknown'")
                                    else:
                                        raw_type = child.get("type")
                                        raw_id = child.get("id")
                                        child_type = raw_type if (isinstance(raw_type, str) and raw_type) else "unknown"
                                        child_id = raw_id if (isinstance(raw_id, str) and raw_id) else "unknown"
                                        if child_type != "TableView":
                                            tabbed_container_errors.append(f"TabbedContainer '{container_id_str}' contains non-TableView child '{child_id}' of type '{child_type}'")
                            
                        # Recurse on values
                        for val in node.values():
                            traverse(val)
                    elif isinstance(node, list):
                        for item in node:
                            traverse(item)
                            
                traverse(layout_data)
            except Exception as e:
                return [f"Logical UI Compliance: Failed to parse logical-layout.json: {e}"]
        else:
            return [f"Logical UI Compliance: logical-layout.json not found at expected paths."]
            
        features_dir = kwargs.get("features_dir")
        if not features_dir:
            features_dir = os.path.join(repo.workspace_dir, backlog_dirs.features)
            
        errors = []
        errors.extend(tabbed_container_errors)
        if not os.path.exists(features_dir):
            errors.append(f"Logical UI Compliance: features directory not found at {features_dir}")
            return errors
            
        feature_files = repo.get_feature_files(features_dir)
        
        for feat in feature_files:
            content = feat.content
            # Use relative path starting with features directory to match doc-checking patterns
            rel_path = os.path.join(backlog_dirs.features, feat.filename)
            
            specified_components = set()
            container_val = "N/A"
            
            # Extract Target LUI Component and Target Layout Container ID from ## 5. Logical UI & Layout Bindings
            match = re.search(r"##\s*5\.\s*Logical\s+UI\s+&\s+Layout\s+Bindings(.*?)(?=##|\Z)", content, re.DOTALL | re.IGNORECASE)
            
            if not match:
                errors.append(f"Logical UI Compliance: Feature '{rel_path}' is a UI feature but lacks the 'Logical UI & Layout Bindings' section.")
            else:
                section_content = match.group(1)
                for line in section_content.splitlines():
                    if "Target LUI Component" in line:
                        raw_val = ""
                        if "|" in line:
                            cells = [c.strip() for c in line.split("|")]
                            for idx, cell in enumerate(cells):
                                cell_clean = re.sub(r'[*`]', '', cell).strip().lower()
                                if "target lui component" in cell_clean:
                                    if idx + 1 < len(cells):
                                        raw_val = cells[idx + 1]
                                    break
                        elif ":" in line:
                            parts = line.split(":", 1)
                            if len(parts) > 1:
                                raw_val = parts[1]
                        
                        if raw_val:
                            cleaned = re.sub(r'\[([^\]]+)\](?:\([^)]*\))?', r'\1', raw_val)
                            for item in cleaned.split(','):
                                token = item.strip().strip("*`\"'[]() ")
                                if token:
                                    specified_components.add(token)
                    elif "Target Layout Container ID" in line:
                        raw_container = ""
                        if "|" in line:
                            cells = [c.strip() for c in line.split("|")]
                            for idx, cell in enumerate(cells):
                                cell_clean = re.sub(r'[*`]', '', cell).strip().lower()
                                if "target layout container id" in cell_clean:
                                    if idx + 1 < len(cells):
                                        raw_container = cells[idx + 1]
                                    break
                        elif ":" in line:
                            parts = line.split(":", 1)
                            if len(parts) > 1:
                                raw_container = parts[1]
                        if raw_container:
                            cleaned = re.sub(r'\[([^\]]+)\](?:\([^)]*\))?', r'\1', raw_container)
                            container_val = cleaned.strip().strip("*`\"'[]() ")
                    elif "Data Source Binding" in line:
                        parts = line.split(":", 1)
                        if len(parts) > 1:
                            ds_val = parts[1].strip().strip("*`\"'[]() ")
                            if ds_val and ds_val.upper() != "N/A":
                                paths = [p.strip().strip(" *`\"'") for p in ds_val.split(',')]
                                nil_elements = {"locations", "racks", "rack", "rack-location", "contained-chassis"}
                                FORBIDDEN_CHOICE_NODES = {"location-choice", "cartesian", "ellipsoid", "choice", "case"}
                                for path in paths:
                                    if not path or path.upper() == "N/A":
                                        continue
                                    if ' ' in path or not (path.startswith('/') or path.startswith('schema:') or path.startswith('provider:') or path.upper() == 'N/A'):
                                        errors.append(
                                            f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding '{path}' contains plain-text English instead of valid schema path."
                                        )
                                        continue
                                    segments = path.split('/')
                                    in_augmented_subtree = False
                                    for seg in segments:
                                        seg_clean = seg.strip()
                                        if not seg_clean:
                                            continue
                                        if '[' in seg_clean:
                                            seg_clean = seg_clean.split('[', 1)[0].strip()
                                        if ':' in seg_clean:
                                            prefix, local_name = seg_clean.split(':', 1)
                                        else:
                                            prefix, local_name = "", seg_clean
                                        
                                        if local_name in FORBIDDEN_CHOICE_NODES or local_name.endswith("-choice") or local_name.endswith("-case"):
                                            errors.append(
                                                f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding '{path}' contains forbidden YANG choice/case node '{local_name}'. Choice/case wrappers must be omitted from data paths."
                                            )
                                        
                                        if prefix == "nil" or local_name in nil_elements:
                                            in_augmented_subtree = True
                                            if local_name in nil_elements and prefix != "nil":
                                                errors.append(
                                                    f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding '{path}' contains un-prefixed augmented element '{local_name}'. Must use 'nil:{local_name}'."
                                                )
                                        elif in_augmented_subtree and prefix == "":
                                            errors.append(
                                                f"Logical UI Compliance: Feature '{rel_path}' Data Source Binding '{path}' contains un-prefixed augmented child segment '{local_name}' under augmented subtree. Must use 'nil:{local_name}'."
                                            )
                            
            # Ensure specified target component is a valid layout component (if not N/A)
            for c in sorted(specified_components):
                if c.upper() != "N/A":
                    if c not in component_types:
                        errors.append(f"Logical UI Compliance: Feature '{rel_path}' specifies invalid component type '{c}'. It must be instantiated in logical-layout.json.")
                    
            # Ensure specified target container ID is valid (if not N/A)
            if container_val.upper() != "N/A":
                if container_val not in container_ids:
                    errors.append(f"Logical UI Compliance: Feature '{rel_path}' specifies invalid container ID '{container_val}'.")

            # Enforce that geodetic attributes are not erroneously mapped to forbidden topology components or container IDs
            FORBIDDEN_TOPOLOGY_COMPONENTS = {"TopographicalView", "TopologyMap", "GeoSpatialViewer", "HierarchyTreeSelector", "HierarchyTree"}
            FORBIDDEN_TOPOLOGY_CONTAINERS = {"topology_pane", "resource_tree", "navigation_tree", "map_viewport"}
            GEODETIC_REGEX = re.compile(r"\b(?:location|velocity|geo-location|geodetic|latitude|longitude|altitude|elevation|datum|position|spatial|reference-frame|geodetic-system|coordinates|velocity\s+vectors)\b", re.IGNORECASE)

            forbidden_comp_matched = [c for c in specified_components if c in FORBIDDEN_TOPOLOGY_COMPONENTS]
            if forbidden_comp_matched or container_val in FORBIDDEN_TOPOLOGY_CONTAINERS:
                if GEODETIC_REGEX.search(content):
                    comp_name_to_report = forbidden_comp_matched[0] if forbidden_comp_matched else (sorted(specified_components)[0] if specified_components else "N/A")
                    errors.append(
                        f"Logical UI Compliance: Feature '{rel_path}' erroneously maps geodetic attribute(s) to forbidden topology component '{comp_name_to_report}' or container ID '{container_val}'."
                    )

        return errors


