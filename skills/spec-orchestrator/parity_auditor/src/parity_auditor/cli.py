import os
import sys
import re
import argparse
from typing import Dict, Set, List

from .core.workspace import WorkspaceRepository
from .parsers.schema_router import parse_schema_file
from .validators.uml import UmlValidator
from .validators.behavioral import BehavioralValidator
from .validators.codebase import CodebaseValidator
from .validators.docs import DocsValidator

def main():
    parser = argparse.ArgumentParser(description="Model Coverage Parity Audit CLI")
    parser.add_argument("schema_dir", nargs="?", help="Path to schema directory")
    parser.add_argument("features_dir", nargs="?", help="Path to feature specs directory")
    
    args = parser.parse_args()
    
    repo = WorkspaceRepository()
    rules = repo.get_codebase_rules()
    backlog_dirs = rules.backlog_directories
    
    schema_dir = args.schema_dir
    if not schema_dir:
        schema_dir = os.environ.get("SCHEMA_DIR", os.environ.get("YANG_DIR"))
    if not schema_dir:
        schema_dir_rel = backlog_dirs.schemas
        if not schema_dir_rel:
            raise ValueError("Missing 'backlog_directories.schemas' in codebase_rules.json")
        schema_dir = os.path.join(repo.workspace_dir, schema_dir_rel)
    else:
        schema_dir = os.path.abspath(schema_dir)
        
    features_dir = args.features_dir
    if not features_dir:
        features_dir = os.environ.get("FEATURES_DIR")
    if not features_dir:
        features_dir_rel = backlog_dirs.features
        if not features_dir_rel:
            raise ValueError("Missing 'backlog_directories.features' in codebase_rules.json")
        features_dir = os.path.join(repo.workspace_dir, features_dir_rel)
    else:
        features_dir = os.path.abspath(features_dir)
        
    has_failed = False
    print("=== Model Coverage Parity Audit ===")
    print(f"Scanning schemas in: {schema_dir}")
    print(f"Scanning feature specifications in: {features_dir}\n")
    
    # 1. Parse all modules
    modules = {}
    if os.path.exists(schema_dir):
        for filename in os.listdir(schema_dir):
            filepath = os.path.join(schema_dir, filename)
            if os.path.isdir(filepath):
                continue
            try:
                module_name, definitions = parse_schema_file(filepath)
                if module_name:
                    modules[module_name] = definitions
            except Exception as e:
                print(f"Warning: Failed to parse schema file {filename}: {e}")
                
    non_yang_extensions = set(rules.validation_rules.non_yang_extensions)
    has_yang_schemas = False
    has_non_yang_schemas = False
    if os.path.exists(schema_dir):
        for filename in os.listdir(schema_dir):
            if os.path.isdir(os.path.join(schema_dir, filename)):
                continue
            ext = os.path.splitext(filename)[1].lower()
            if ext == ".yang":
                has_yang_schemas = True
            elif ext in non_yang_extensions:
                has_non_yang_schemas = True
                
    # 2. Load all feature markdown files
    features = repo.get_feature_files(features_dir)
    print(f"Loaded {len(features)} feature specifications.\n")
    
    skip_coverage_checks = False
    if not features:
        print("Note: No feature specifications found in directory. Skipping model coverage checks.")
        skip_coverage_checks = True
    elif has_non_yang_schemas:
        print("Warning: Deep AST node coverage parity audit is currently optimized for YANG schemas. Skipping strict coverage percentage check for OpenAPI/Protobuf/ASN.1, but proceeding with UML compliance audit.")
        skip_coverage_checks = True
    elif not has_yang_schemas:
        print("Note: No schemas found in schema directory. Skipping model coverage checks.")
        skip_coverage_checks = True
        
    # 3. Audit coverage per module
    total_defined = 0
    total_covered = 0
    coverage_gaps = {}
    
    uml_validator = UmlValidator()
    global_classes = uml_validator.build_global_classes(repo, features_dir) if features else {}
    
    if not skip_coverage_checks and features:
        # Convert FeatureFile list to list of dicts to match original build_classes_from_features signature/contract
        # or we can pass List[FeatureFile] directly. Since we refactored it, build_classes_from_features accepts List[FeatureFile]
        for module_name, definitions in sorted(modules.items()):
            matching_features = [f for f in features if module_name in f.labels]
            if not matching_features:
                continue
                
            local_classes = uml_validator.build_classes_from_features(matching_features, repo)
            
            module_defined = len(definitions)
            module_covered = 0
            missing = []
            
            for name in sorted(definitions):
                variants = {name}
                if '-' in name or '_' in name or '.' in name:
                    parts = re.split(r'[-_.]', name)
                    variants.add(parts[0] + "".join(p.capitalize() for p in parts[1:]))
                    variants.add("".join(p.capitalize() for p in parts))
                else:
                    if name:
                        variants.add(name[0].lower() + name[1:])
                        variants.add(name[0].upper() + name[1:])
                        
                found = False
                if any(v in local_classes for v in variants):
                    found = True
                else:
                    for cls_info in local_classes.values():
                        if any(attr["name"] in variants for attr in cls_info["attributes"]):
                            found = True
                            break
                        if any(method["name"] in variants for method in cls_info["methods"]):
                            found = True
                            break
                            
                if found:
                    module_covered += 1
                else:
                    missing.append(name)
                    
            total_defined += module_defined
            total_covered += module_covered
            
            if missing:
                coverage_gaps[module_name] = missing
                
            if module_defined > 0:
                pct = (module_covered / module_defined) * 100
                print(f"Module '{module_name}': {module_covered}/{module_defined} nodes covered ({pct:.2f}%)")
            else:
                print(f"Module '{module_name}': 0 nodes defined")
                
        print("\n=== Audit Summary ===")
        if total_defined > 0:
            overall_pct = (total_covered / total_defined) * 100
            print(f"Total Schema Nodes Defined: {total_defined}")
            print(f"Total Schema Nodes Covered: {total_covered}")
            print(f"Overall Model Coverage:     {overall_pct:.2f}%")
        else:
            print("No target schema nodes found to verify.")
            sys.exit(1)
            
    print("\n=== UML Diagrams Compliance Audit ===")
    uml_errors = []
    if not features:
        print("Note: No feature specifications found. Skipping UML Diagrams Compliance Audit.")
    else:
        uml_errors = uml_validator.validate(repo, global_classes=global_classes)
        
    if uml_errors:
        print("[!] UML Compliance Violations Identified:")
        for err in uml_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        if features:
            print("Success: All specification files are fully UML-compliant (no ERDs or invalid syntax found).")
            
    if coverage_gaps:
        print("\n[!] Coverage Gaps Identified:")
        for module_name, missing in sorted(coverage_gaps.items()):
            print(f"  Module '{module_name}' is missing {len(missing)} nodes:")
            print(f"    Missing: {', '.join(missing)}")
        print("\nError: 100% model coverage validation failed.")
        has_failed = True
    else:
        if not skip_coverage_checks and features:
            print("\nSuccess: 100% model coverage verified across all specification files.")
            
    print("\n=== Behavioral Coverage Triggers Audit ===")
    behavioral_validator = BehavioralValidator()
    behavioral_errors = []
    if not features:
        print("Note: No feature specifications found. Skipping Behavioral Coverage Triggers Audit.")
    else:
        behavioral_errors = behavioral_validator.validate(repo, schema_dir=schema_dir, modules=modules)
        
    if behavioral_errors:
        print("[!] Behavioral Coverage Violations Identified:")
        for err in behavioral_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: All behavioral coverage triggers passed.")
        
    print("\n=== Codebase AST / Compliance Audit ===")
    codebase_validator = CodebaseValidator()
    codebase_errors = codebase_validator.validate(repo)
    
    if codebase_errors:
        print("[!] Codebase Compliance Violations Identified:")
        for err in codebase_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: Codebase compliance checks passed.")
        
    print("\n=== Documentation Consistency Audit ===")
    docs_validator = DocsValidator()
    doc_errors = docs_validator.validate(repo)
    
    if doc_errors:
        print("[!] Documentation Consistency Violations Identified:")
        for err in doc_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: Documentation consistency checks passed.")
        
    if has_failed:
        upstream_repo = rules.meta.upstream_repository
        if not upstream_repo:
            raise ValueError("Missing 'meta.upstream_repository' in codebase_rules.json")
        print("\n[!] If you believe this failure is due to a bug or limitation in the pipeline tooling, please report it upstream:")
        print(f"    gh issue create --repo {upstream_repo} --title \"Tooling Bug: [Brief description]\" --body \"Context: UML/Coverage validation failed in downstream execution.\"")
        sys.exit(1)
    else:
        print("\nSuccess: All verification checks passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
