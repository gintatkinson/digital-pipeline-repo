import re
import os
from typing import Tuple, Set, Optional
from .base import IParser
from ..core.workspace import WorkspaceRepository

class YangParser(IParser):
    def __init__(self, workspace_repo: WorkspaceRepository):
        self.workspace_repo = workspace_repo

    def can_parse(self, filepath: str) -> bool:
        return filepath.lower().endswith(".yang")

    def parse(self, filepath: str) -> Tuple[Optional[str], Set[str]]:
        with open(filepath, "r", encoding="utf-8") as f:
            raw_content = f.read()

        module_match = re.search(r'\bmodule\s+([a-zA-Z0-9_\-]+)', raw_content)
        if not module_match:
            return None, set()

        module_name = module_match.group(1)

        # Clean comments and strings
        pattern = r'(/\*.*?\*/)|(//[^\n]*)|("(?:\\.|[^"\\])*")|(\'(?:\\.|[^\'\\])*\')'
        def replacer(match):
            if match.group(1): return " "
            if match.group(2): return "\n"
            return ""
        content = re.sub(pattern, replacer, raw_content, flags=re.DOTALL)

        patterns = [
            r'\btypedef\s+([a-zA-Z0-9_\-]+)',
            r'\bleaf\s+([a-zA-Z0-9_\-]+)',
            r'\bleaf-list\s+([a-zA-Z0-9_\-]+)',
            r'\bcontainer\s+([a-zA-Z0-9_\-]+)',
            r'\blist\s+([a-zA-Z0-9_\-]+)',
            r'\bgrouping\s+([a-zA-Z0-9_\-]+)',
            r'\bchoice\s+([a-zA-Z0-9_\-]+)',
            r'\bcase\s+([a-zA-Z0-9_\-]+)',
            r'\bidentity\s+([a-zA-Z0-9_\-]+)',
            r'\banydata\s+([a-zA-Z0-9_\-]+)',
            r'\banyxml\s+([a-zA-Z0-9_\-]+)',
            r'\brpc\s+([a-zA-Z0-9_\-]+)',
            r'\bnotification\s+([a-zA-Z0-9_\-]+)',
            r'\baction\s+([a-zA-Z0-9_\-]+)'
        ]

        rules = self.workspace_repo.get_codebase_rules()
        yang_exclude_keywords = set(rules.validation_rules.yang_exclude_keywords)

        definitions = set()
        for pattern in patterns:
            for match in re.finditer(pattern, content):
                name = match.group(1)
                if name not in yang_exclude_keywords:
                    definitions.add(name)

        return module_name, definitions
