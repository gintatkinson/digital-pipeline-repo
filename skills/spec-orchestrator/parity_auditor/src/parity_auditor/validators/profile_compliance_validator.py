"""
Validator that enforces profile compliance rules (e.g. UML traceability tags
/// Realises: [SpecName/ClassName] on public Dart declarations) across target codebase source files.
"""

import os
import re
from typing import List
from .base import IValidator
from ..core.findings import Finding
from ..core.workspace import WorkspaceRepository


class ProfileComplianceValidator(IValidator):
    """Validator that checks UML traceability tags on public classes in source code."""

    def validate(self, repo: WorkspaceRepository, **kwargs) -> List[str]:
        """
        Scans target codebase directories for public Dart classes to ensure
        they contain UML traceability tags (/// Realises: [SpecName/ClassName]).
        """
        errors = []
        workspace_dir = repo.workspace_dir
        rules = repo.get_codebase_rules()
        target_dirs = rules.target_directories if rules else None

        exclusions = {
            ".git", ".agents", ".pipeline", "build", "dist", "node_modules",
            ".dart_tool", "vendor", ".venv", "venv", "__pycache__", "coverage"
        }

        def get_source_files(target_dir_name: str, extensions: List[str]):
            if not target_dir_name:
                return []
            full_path = os.path.join(workspace_dir, target_dir_name)
            if not os.path.exists(full_path):
                return []
            matched = []
            for root, dirs, files in os.walk(full_path):
                dirs[:] = [d for d in dirs if d not in exclusions]
                for file in files:
                    if any(file.endswith(ext) for ext in extensions):
                        matched.append(os.path.join(root, file))
            return matched

        flutter_exts = getattr(rules.flutter_rules, "file_extensions", [".dart"]) if (rules and rules.flutter_rules) else [".dart"]
        flutter_dir = getattr(target_dirs, "flutter", None) if target_dirs else None
        
        flutter_files = get_source_files(flutter_dir, flutter_exts)

        if not flutter_files:
            candidate_dirs = ["app_flutter", "lib"]
            for cdir in candidate_dirs:
                cpath = os.path.join(workspace_dir, cdir)
                if os.path.exists(cpath):
                    for root, dirs, files in os.walk(cpath):
                        dirs[:] = [d for d in dirs if d not in exclusions]
                        for file in files:
                            if file.endswith(".dart"):
                                flutter_files.append(os.path.join(root, file))

        for filepath in flutter_files:
            rel_path = os.path.relpath(filepath, workspace_dir)
            try:
                with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                    lines = f.readlines()
            except Exception:
                continue

            if filepath.endswith(".dart"):
                self._check_dart_traceability_tags(lines, rel_path, errors)

        return errors

    def _check_dart_traceability_tags(self, lines: List[str], rel_path: str, errors: List[str]):
        """Checks missing UML traceability tags on public class declarations in Dart files."""
        decl_pattern = re.compile(
            r'^\s*(?:@\w+(?:\([^)]*\))?\s*)*(?:abstract\s+|base\s+|final\s+|interface\s+|sealed\s+|mixin\s+)*'
            r'(?:class|enum|mixin|extension|typedef)\s+([A-Z]\w*)'
        )
        for idx, line in enumerate(lines):
            match = decl_pattern.match(line)
            if match:
                name = match.group(1)
                if name.startswith("_"):
                    continue

                has_traceability_tag = False
                prev_idx = idx - 1
                doc_lines = []
                while prev_idx >= 0:
                    prev_line = lines[prev_idx].strip()
                    if prev_line.startswith("///") or prev_line.startswith("/**") or prev_line.startswith("*") or prev_line.endswith("*/"):
                        doc_lines.append(prev_line)
                        prev_idx -= 1
                    elif prev_line.startswith("@"):
                        prev_idx -= 1
                        continue
                    elif not prev_line:
                        prev_idx -= 1
                        continue
                    else:
                        break

                full_doc = " ".join(doc_lines)
                if "Realises:" in full_doc:
                    has_traceability_tag = True

                if not has_traceability_tag:
                    errors.append(Finding(
                        "uml-traceability-tag-missing",
                        f"Missing UML traceability tag (/// Realises: [SpecName/ClassName]) for public declaration '{name}' at {rel_path}:{idx + 1}",
                        location=f"{rel_path}:{idx + 1}"
                    ))
