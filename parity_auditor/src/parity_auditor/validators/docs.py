import os
import re
from typing import List, Dict, Any
from .base import IValidator
from ..core.workspace import WorkspaceRepository

class DocsValidator(IValidator):
    def validate(self, repo: WorkspaceRepository, **kwargs) -> List[str]:
        errors = []
        workspace_dir = repo.workspace_dir
        
        doc_files = [
            "README.md",
            ".pipeline/constitution.md",
            ".pipeline/profiles/react.md",
            ".pipeline/profiles/flutter.md"
        ]
        
        obsolete_patterns = [
            (r"color\.alarm\b", "color.alarm (obsolete token namespace)"),
            (r"alarm\.cleared\b", "alarm.cleared (obsolete token namespace)"),
            (r"alarm\.minor\b", "alarm.minor (obsolete token namespace)"),
            (r"alarm\.critical\b", "alarm.critical (obsolete token namespace)"),
        ]
        
        for rel_path in doc_files:
            filepath = os.path.join(workspace_dir, rel_path)
            if not os.path.exists(filepath):
                continue
            try:
                with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
            except Exception:
                continue
                
            for pattern, name in obsolete_patterns:
                if re.search(pattern, content, re.IGNORECASE):
                    errors.append(f"Documentation file '{rel_path}' contains obsolete reference '{name}'. Please update it to standard-agnostic status mappings.")
                    
            if "react.md" in rel_path or "flutter.md" in rel_path or "README.md" in rel_path:
                if "X.733" in content:
                    errors.append(f"Documentation file '{rel_path}' contains hardcoded reference to 'X.733'. Target profiles and READMEs must remain strictly standard-agnostic.")
                    
        return errors
