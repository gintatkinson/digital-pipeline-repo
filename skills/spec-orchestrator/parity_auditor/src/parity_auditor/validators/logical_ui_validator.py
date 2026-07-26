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
        
        # 1. Locate layout configuration JSON file
        # Check workspace_dir / .pipeline / logical-ui / logical-layout.json first
        layout_path = os.path.join(repo.workspace_dir, ".pipeline", "logical-ui", "logical-layout.json")
        if not os.path.exists(layout_path):
            # Check app_flutter / assets / logical-layout.json next
            layout_path = os.path.join(repo.workspace_dir, "app_flutter", "assets", "logical-layout.json")
            
        component_types = set()
        container_ids = set()
        
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
            
        # Allowed component names from logical-components.md
        allowed_component_names = {
            "HierarchyTree", 
            "ResizableSplitter", 
            "NavigationBreadcrumbs", 
            "PropertyGrid", 
            "TopologyMap", 
            "DensityTable", 
            "ContextualPanel"
        }
        
        features_dir = kwargs.get("features_dir")
        if not features_dir:
            features_dir = os.path.join(repo.workspace_dir, backlog_dirs.features)
            
        errors = []
        if not os.path.exists(features_dir):
            errors.append(f"Logical UI Compliance: features directory not found at {features_dir}")
            return errors
            
        feature_files = repo.get_feature_files(features_dir)
        
        coordinate_keywords = [
            "astronomical-body", "geodetic-datum", "coordinate", 
            "latitude", "longitude", "trajectory", "orbit", 
            "elevation", "geo-location", "x", "y", "z"
        ]
        
        for feat in feature_files:
            content = feat.content
            # Use relative path starting with features directory to match doc-checking patterns
            rel_path = os.path.join(backlog_dirs.features, feat.filename)
            
            comp_val = "N/A"
            container_val = "N/A"
            
            data_source_bindings = []
            
            # Extract Target LUI Component and Target Layout Container ID from ## 5. Logical UI & Layout Bindings
            match = re.search(r"##\s*5\.\s*Logical\s+UI\s+&\s+Layout\s+Bindings(.*?)(?=##|\Z)", content, re.DOTALL | re.IGNORECASE)
            if match:
                section_content = match.group(1)
                lines = section_content.splitlines()
                for i, line in enumerate(lines):
                    if "Target LUI Component" in line:
                        parts = line.split(":", 1)
                        if len(parts) > 1:
                            comp_val = parts[1].strip().strip("*`\"'[]() ")
                    elif "Target Layout Container ID" in line:
                        parts = line.split(":", 1)
                        if len(parts) > 1:
                            container_val = parts[1].strip().strip("*`\"'[]() ")
                    elif "Data Source Bindings" in line:
                        parts = line.split(":", 1)
                        if len(parts) > 1 and parts[1].strip():
                            data_source_bindings.append(parts[1].strip().strip("*`\"'[]() "))
                        else:
                            j = i + 1
                            while j < len(lines):
                                next_line = lines[j].strip()
                                if next_line.startswith("-"):
                                    data_source_bindings.append(next_line.lstrip("-").strip().strip("*`\"'[]() "))
                                    j += 1
                                elif not next_line:
                                    j += 1
                                else:
                                    break
                            
            # Ensure specified target component is a valid layout component (if not N/A)
            if comp_val.upper() != "N/A":
                if comp_val not in component_types and comp_val not in allowed_component_names:
                    errors.append(f"Logical UI Compliance: Feature '{rel_path}' specifies invalid component type '{comp_val}'.")
                    
            # Ensure specified target container ID is valid (if not N/A)
            if container_val.upper() != "N/A":
                if container_val not in container_ids:
                    errors.append(f"Logical UI Compliance: Feature '{rel_path}' specifies invalid container ID '{container_val}'.")
                    
            forbidden_nodes = {"cartesian", "ellipsoid", "location-choice"}
            for binding in data_source_bindings:
                for f_node in forbidden_nodes:
                    if f_node in binding:
                        errors.append(f"Logical UI Compliance: Feature '{rel_path}' contains forbidden YANG choice/case node '{f_node}' in Data Source Binding '{binding}'.")
                    
            # Coordinate/Reference-Frame constraint:
            has_coordinate_term = any(re.search(rf"\b{word}\b", content.lower()) for word in coordinate_keywords)
            if has_coordinate_term and comp_val not in {"TopologyMap", "TopographicalView"}:
                errors.append(
                    f"Logical UI Compliance: Feature '{rel_path}' contains geodetic/coordinate concepts but "
                    f"'Target LUI Component' is '{comp_val}'. Demanding mapping to a visual coordinate component (e.g. TopologyMap or TopographicalView)."
                )
                
        return errors
