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
                            children = node.get("children", [])
                            if isinstance(children, list):
                                for child in children:
                                    if isinstance(child, dict):
                                        child_type = child.get("type", "unknown")
                                        child_id = child.get("id", "unknown")
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
            
            comp_val = "N/A"
            container_val = "N/A"
            
            # Extract Target LUI Component and Target Layout Container ID from ## 5. Logical UI & Layout Bindings
            match = re.search(r"##\s*(?:\d+\.\s*)?Logical\s+UI\s+&\s+Layout\s+Bindings(.*?)(?=##|\Z)", content, re.DOTALL | re.IGNORECASE)
            
            if not match:
                has_ui_concept = bool(re.search(r"(?:interface[-_]type:\s*ui|\bui\b|\binterface\b|\blayout\b|\bview\b|\bcomponent\b|\bwidget\b|\bscreen\b)", content, re.IGNORECASE))
                if has_ui_concept:
                    errors.append(f"Logical UI Compliance: Feature '{rel_path}' is a UI feature but lacks the 'Logical UI & Layout Bindings' section.")
            else:
                section_content = match.group(1)
                for line in section_content.splitlines():
                    if "Target LUI Component" in line:
                        parts = line.split(":", 1)
                        if len(parts) > 1:
                            comp_val = parts[1].strip().strip("*`\"'[]() ")
                    elif "Target Layout Container ID" in line:
                        parts = line.split(":", 1)
                        if len(parts) > 1:
                            container_val = parts[1].strip().strip("*`\"'[]() ")
                            
            # Ensure specified target component is a valid layout component (if not N/A)
            if comp_val.upper() != "N/A":
                if comp_val not in component_types:
                    errors.append(f"Logical UI Compliance: Feature '{rel_path}' specifies invalid component type '{comp_val}'. It must be instantiated in logical-layout.json.")
                    
            # Ensure specified target container ID is valid (if not N/A)
            if container_val.upper() != "N/A":
                if container_val not in container_ids:
                    errors.append(f"Logical UI Compliance: Feature '{rel_path}' specifies invalid container ID '{container_val}'.")
                
        return errors

