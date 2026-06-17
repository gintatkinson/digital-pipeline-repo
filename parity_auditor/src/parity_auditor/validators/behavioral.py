import os
import re
from typing import List, Dict, Any, Set
from .base import IValidator
from ..core.workspace import WorkspaceRepository
from ..utils.case_utils import normalize_case

class BehavioralValidator(IValidator):
    def validate(self, repo: WorkspaceRepository, **kwargs) -> List[str]:
        schema_dir = kwargs.get("schema_dir")
        if not schema_dir:
            schema_dir = os.path.join(repo.workspace_dir, repo.get_codebase_rules().backlog_directories.schemas)
            
        modules = kwargs.get("modules", {})
        
        rules = repo.get_codebase_rules()
        backlog_dirs = rules.backlog_directories
        user_stories_dir = os.path.join(repo.workspace_dir, backlog_dirs.user_stories)
        use_cases_dir = os.path.join(repo.workspace_dir, backlog_dirs.use_cases)
        
        triggers = repo.get_behavioral_triggers(schema_dir)
        
        all_nodes_normalized = {normalize_case(node) for defs in modules.values() for node in defs}
        
        errors = []
        for trigger in triggers:
            trigger_nodes = trigger.get("trigger_nodes", [])
            normalized_trigger_nodes = [normalize_case(node) for node in trigger_nodes]
            if not any(node in all_nodes_normalized for node in normalized_trigger_nodes):
                continue
                
            for rule in trigger.get("rules", []):
                target_type = rule.get("target_type")
                target_dir = user_stories_dir if target_type == "user-story" else use_cases_dir
                
                files = []
                if os.path.exists(target_dir):
                    files = [os.path.join(target_dir, f) for f in os.listdir(target_dir) if f.endswith(".md")]
                    
                trigger_files = []
                for filepath in files:
                    try:
                        with open(filepath, "r", encoding="utf-8") as f:
                            content = f.read()
                    except Exception as e:
                        print(f"Warning: Failed to read file {filepath}: {e}")
                        continue
                        
                    has_any_node = False
                    for node in trigger_nodes:
                        escaped_node = re.escape(node).replace(r'\-', r'[\s\-_]').replace(r'\_', r'[\s\-_]')
                        if re.search(rf'\b{escaped_node}\b', content, re.IGNORECASE):
                            has_any_node = True
                            break
                    if has_any_node:
                        trigger_files.append((filepath, content))
                        
                if not trigger_files:
                    errors.append(f"Validation failed: No {target_type} files found referencing any trigger nodes: {', '.join(trigger_nodes)}. {rule.get('error_message')}")
                    continue
                    
                for filepath, content in trigger_files:
                    file_valid = True
                    is_target = False
                    for node in trigger_nodes:
                        escaped_node = re.escape(node).replace(r'\-', r'[\s\-_]').replace(r'\_', r'[\s\-_]')
                        if re.search(rf'\b{escaped_node}\b', content, re.IGNORECASE):
                            is_target = True
                            break
                    if not is_target:
                        continue
                        
                    mermaid_type = rule.get("requires_mermaid_block")
                    if mermaid_type:
                        mermaid_matches = re.findall(rf"```mermaid\s*\n\s*{mermaid_type}(.*?)\n```", content, re.DOTALL)
                        if not mermaid_matches:
                            file_valid = False
                        else:
                            mermaid_terms = rule.get("match_terms_in_mermaid", [])
                            if mermaid_terms:
                                if not any(any(term in m_content for term in mermaid_terms) for m_content in mermaid_matches):
                                    file_valid = False
                                    
                    body_terms = rule.get("match_terms_in_body", [])
                    if body_terms:
                        if not any(term in content.lower() for term in body_terms):
                            file_valid = False
                            
                    body_terms_sec = rule.get("match_terms_in_body_secondary", [])
                    if body_terms_sec:
                        if not any(term in content.lower() for term in body_terms_sec):
                            file_valid = False
                            
                    if not file_valid:
                        errors.append(f"In {os.path.basename(filepath)}: {rule.get('error_message')}")
                        
        return errors
