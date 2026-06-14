# Copyright Gint Atkinson, gint.atkinson@gmail.com

#!/usr/bin/env python3
import os
import re
import sys
import json

def parse_yang_file(filepath):
    """
    Parses a YANG file and extracts all defined names (typedefs, containers, lists, leaves, choices, cases, identities).
    """
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract module name
    module_match = re.search(r'\bmodule\s+([a-zA-Z0-9_\-]+)', content)
    if not module_match:
        return None, set()

    module_name = module_match.group(1)

    # Patterns to match definitions
    # Covers all primary YANG statement types that define named schema nodes
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
        r'\banyxml\s+([a-zA-Z0-9_\-]+)'
    ]

    definitions = set()
    for pattern in patterns:
        for match in re.finditer(pattern, content):
            name = match.group(1)
            # Filter out any accidental matches with common keywords if matched
            if name not in {"description", "reference", "organization", "contact", "revision", "import", "prefix", "namespace", "yang-version"}:
                definitions.add(name)

    return module_name, definitions

def parse_schema_file(filepath):
    """
    Parses a schema file and extracts definitions depending on file extension.
    Supported extensions: .yang (YANG). Extensible to other formats.
    """
    ext = os.path.splitext(filepath)[1].lower()
    if ext == ".yang":
        return parse_yang_file(filepath)
    # Extensible to other formats (e.g. .yaml, .proto)
    print(f"Warning: Extensible schema parser not yet implemented for extension '{ext}' in {os.path.basename(filepath)}")
    return os.path.basename(filepath), set()

def load_behavioral_triggers(schema_dir, script_dir):
    workspace_dir = os.path.abspath(os.path.join(script_dir, "..", "..", ".."))
    search_paths = [
        os.path.join(schema_dir, "behavioral_triggers.json"),
        os.path.join(workspace_dir, "rules", "behavioral_triggers.json"),
        os.path.join(script_dir, "behavioral_triggers.json")
    ]
    for path in search_paths:
        if os.path.exists(path):
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
    return []

def load_feature_files(features_dir):
    """
    Loads all feature markdown files, returns a list of dicts with frontmatter and full text.
    """
    features = []
    if not os.path.exists(features_dir):
        return features

    for filename in os.listdir(features_dir):
        if not filename.endswith(".md"):
            continue
        filepath = os.path.join(features_dir, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        # Parse simple frontmatter
        labels = []
        frontmatter_match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
        if frontmatter_match:
            frontmatter_text = frontmatter_match.group(1)
            for line in frontmatter_text.splitlines():
                if line.startswith("labels:"):
                    # Parse list of labels e.g. ["feature", "ietf-geo-location"]
                    labels_match = re.search(r"\[(.*?)\]", line)
                    if labels_match:
                        labels = [lbl.strip().strip('"').strip("'") for lbl in labels_match.group(1).split(",")]
        
        features.append({
            "filename": filename,
            "labels": labels,
            "content": content
        })
    return features

def verify_uml_diagrams(features_dir):
    """
    Validates that UML diagrams exist in all generated specs and conform to UML-only rules.
    """
    docs_dir = os.path.dirname(features_dir)
    user_stories_dir = os.path.join(docs_dir, "user-stories")
    use_cases_dir = os.path.join(docs_dir, "use-cases")
    epics_dir = os.path.join(docs_dir, "epics")

    errors = []

    def get_md_files(d):
        if not os.path.exists(d):
            return []
        return [os.path.join(d, f) for f in os.listdir(d) if f.endswith(".md")]

    # 1. Verify Features
    feature_files = get_md_files(features_dir)
    for filepath in feature_files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Check for invalid Mermaid dotted link syntax
        if re.search(r"-\.-*->\s*\|", content):
            errors.append(f"Feature {os.path.basename(filepath)} contains invalid Mermaid dotted link label syntax (e.g. '-.->|' or '-.-->|'). Use '-. label .->' instead.")

        # Check for UML Class Diagram header
        if not re.search(r"##\s+UML\s+Class\s+Diagram", content, re.IGNORECASE):
            errors.append(f"Feature {os.path.basename(filepath)} is missing a '## UML Class Diagram' header.")
            continue
        
        # Check for Mermaid classDiagram block
        class_diagram_match = re.search(r"```mermaid\s*\n\s*classDiagram(.*?)(?=```|\Z)", content, re.DOTALL)
        if not class_diagram_match:
            errors.append(f"Feature {os.path.basename(filepath)} is missing a valid '```mermaid classDiagram' block.")
        elif not re.search(r"(\*--|o--|<\|--|--|-->)", class_diagram_match.group(1)):
            errors.append(f"Feature {os.path.basename(filepath)} contains a UML Class Diagram with no relationships. Isolated classes are prohibited; you must illustrate containment/inheritance/choice composition.")
            
        # Check that erDiagram is NOT used
        if re.search(r"erDiagram", content):
            errors.append(f"Feature {os.path.basename(filepath)} contains forbidden 'erDiagram' (ERD diagrams are strictly prohibited).")

        # Check for JSON payload example under Functional UI Requirements
        if not re.search(r"##\s+Functional\s+UI\s+Requirements.*```json", content, re.DOTALL | re.IGNORECASE):
            errors.append(f"Feature {os.path.basename(filepath)} is missing a JSON payload example (```json block) under Functional UI Requirements.")

    # 2. Verify User Stories
    story_files = get_md_files(user_stories_dir)
    for filepath in story_files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Check for invalid Mermaid dotted link syntax
        if re.search(r"-\.-*->\s*\|", content):
            errors.append(f"User Story {os.path.basename(filepath)} contains invalid Mermaid dotted link label syntax (e.g. '-.->|' or '-.-->|'). Use '-. label .->' instead.")

        if not re.search(r"##\s+UML\s+Sequence\s+Diagram", content, re.IGNORECASE):
            errors.append(f"User Story {os.path.basename(filepath)} is missing a '## UML Sequence Diagram' header.")
            continue
            
        if not re.search(r"```mermaid\s*\n\s*sequenceDiagram", content):
            errors.append(f"User Story {os.path.basename(filepath)} is missing a valid '```mermaid sequenceDiagram' block.")

    # 3. Verify Use Cases
    usecase_files = get_md_files(use_cases_dir)
    for filepath in usecase_files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Check for invalid Mermaid dotted link syntax
        if re.search(r"-\.-*->\s*\|", content):
            errors.append(f"Use Case {os.path.basename(filepath)} contains invalid Mermaid dotted link label syntax (e.g. '-.->|' or '-.-->|'). Use '-. label .->' instead.")

        if not re.search(r"##\s+UML\s+Diagrams", content, re.IGNORECASE):
            errors.append(f"Use Case {os.path.basename(filepath)} is missing a '## UML Diagrams' header.")
            continue
            
        # Check for Use Case Diagram (flowchart graph)
        if not re.search(r"```mermaid\s*\n\s*(graph|flowchart)", content):
            errors.append(f"Use Case {os.path.basename(filepath)} is missing a UML Use Case diagram ('```mermaid graph' or 'flowchart').")
            
        # Check for State Machine Diagram
        if not re.search(r"```mermaid\s*\n\s*stateDiagram", content):
            errors.append(f"Use Case {os.path.basename(filepath)} is missing a UML State Machine diagram ('```mermaid stateDiagram').")

        # Check for ERD
        if re.search(r"erDiagram", content):
            errors.append(f"Use Case {os.path.basename(filepath)} contains forbidden 'erDiagram' (ERD diagrams are strictly prohibited).")

        # Check for Cockburn sections
        required_sections = [
            (r"##\s+1\.\s+Actors", "## 1. Actors"),
            (r"##\s+2\.\s+Preconditions", "## 2. Preconditions"),
            (r"##\s+3\.\s+Trigger", "## 3. Trigger"),
            (r"##\s+4\.\s+Main\s+Success\s+Scenario", "## 4. Main Success Scenario"),
            (r"##\s+5\.\s+Alternate\s+(?:and|&)\s+Exception\s+Flows", "## 5. Alternate and Exception Flows"),
            (r"##\s+6\.\s+Postconditions", "## 6. Postconditions"),
            (r"##\s+8\.\s+Realization\s+Matrix", "## 8. Realization Matrix")
        ]
        for pattern, header_name in required_sections:
            if not re.search(pattern, content, re.IGNORECASE):
                errors.append(f"Use Case {os.path.basename(filepath)} is missing mandated section '{header_name}'.")

        # Enforce at least 2 alternate flows with at least 2 numbered steps
        flows_block_match = re.search(r"##\s+5\.\s+Alternate\s+(?:and|&)\s+Exception\s+Flows(.*?)(?=##\s+6\.\s+Postconditions|\Z)", content, re.DOTALL | re.IGNORECASE)
        if flows_block_match:
            flows_block = flows_block_match.group(1)
            flows = re.findall(r"-\s+\*\*\d[a-zA-Z]\..*?(?=-\s+\*\*\d[a-zA-Z]\.|\Z)", flows_block, re.DOTALL)
            if len(flows) < 2:
                errors.append(f"Use Case {os.path.basename(filepath)} must contain at least 2 detailed Alternate/Exception flows.")
            else:
                for idx, flow in enumerate(flows):
                    steps = re.findall(r"\b\d+\.\s+\S+", flow)
                    if len(steps) < 2:
                        errors.append(f"Use Case {os.path.basename(filepath)} alternate flow {idx+1} is too thin (must contain at least 2 numbered steps).")
        else:
            errors.append(f"Use Case {os.path.basename(filepath)} is missing '## 5. Alternate and Exception Flows' content block.")

        # Validate the Realization Matrix checklist and absolute URLs
        if re.search(r"##\s+8\.\s+Realization\s+Matrix", content, re.IGNORECASE):
            if not re.search(r"###\s+Required\s+User\s+Stories", content, re.IGNORECASE):
                errors.append(f"Use Case {os.path.basename(filepath)} is missing '### Required User Stories' under Realization Matrix.")
            if not re.search(r"###\s+Required\s+Features", content, re.IGNORECASE):
                errors.append(f"Use Case {os.path.basename(filepath)} is missing '### Required Features' under Realization Matrix.")
            
            checkboxes = re.findall(r"-\s+\[[ x]\]\s+.*", content)
            for cb in checkboxes:
                if "(" in cb and ")" in cb:
                    link_match = re.search(r"\((.*?)\)", cb)
                    if link_match:
                        link = link_match.group(1)
                        if not re.match(r"^https?://[a-zA-Z0-9.-]+/", link):
                            errors.append(f"Use Case {os.path.basename(filepath)} contains a non-absolute/invalid URL in realization matrix: '{link}'.")

    # 4. Verify Epics
    epic_files = get_md_files(epics_dir)
    for filepath in epic_files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        # Check for invalid Mermaid dotted link syntax
        if re.search(r"-\.-*->\s*\|", content):
            errors.append(f"Epic {os.path.basename(filepath)} contains invalid Mermaid dotted link label syntax (e.g. '-.->|' or '-.-->|'). Use '-. label .->' instead.")

        # Check for ## System-Level UML Class Diagram header
        if not re.search(r"##\s+System-Level\s+UML\s+Class\s+Diagram", content, re.IGNORECASE):
            errors.append(f"Epic {os.path.basename(filepath)} is missing a '## System-Level UML Class Diagram' header.")

        # Check for Mermaid classDiagram block
        if not re.search(r"```mermaid\s*\n\s*classDiagram", content):
            errors.append(f"Epic {os.path.basename(filepath)} is missing a valid '```mermaid classDiagram' block.")

        # Check for ## System State Machine Diagram header
        if not re.search(r"##\s+System\s+State\s+Machine\s+Diagram", content, re.IGNORECASE):
            errors.append(f"Epic {os.path.basename(filepath)} is missing a '## System State Machine Diagram' header.")

        # Check for Mermaid stateDiagram-v2 block
        if not re.search(r"```mermaid\s*\n\s*stateDiagram-v2", content):
            errors.append(f"Epic {os.path.basename(filepath)} is missing a valid '```mermaid stateDiagram-v2' block.")

    return errors

def verify_behavioral_triggers(schema_dir, features_dir, modules):
    docs_dir = os.path.dirname(features_dir)
    user_stories_dir = os.path.join(docs_dir, "user-stories")
    use_cases_dir = os.path.join(docs_dir, "use-cases")
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    triggers = load_behavioral_triggers(schema_dir, script_dir)
    
    # Collect all definitions from all modules
    all_nodes = set()
    for defs in modules.values():
        all_nodes.update(defs)
        
    errors = []
    for trigger in triggers:
        trigger_nodes = trigger.get("trigger_nodes", [])
        # Check if the schema contains any of the trigger nodes
        if not any(node in all_nodes for node in trigger_nodes):
            continue
            
        for rule in trigger.get("rules", []):
            target_type = rule.get("target_type")
            target_dir = user_stories_dir if target_type == "user-story" else use_cases_dir
            
            found_match = False
            files = []
            if os.path.exists(target_dir):
                files = [os.path.join(target_dir, f) for f in os.listdir(target_dir) if f.endswith(".md")]

            for filepath in files:
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()

                # Check mermaid block requirement if specified
                mermaid_type = rule.get("requires_mermaid_block")
                if mermaid_type:
                    mermaid_matches = re.findall(rf"```mermaid\s*\n\s*{mermaid_type}(.*?)\n```", content, re.DOTALL)
                    if not mermaid_matches:
                        continue
                    
                    mermaid_terms = rule.get("match_terms_in_mermaid", [])
                    if mermaid_terms:
                        if not any(any(term in m_content for term in mermaid_terms) for m_content in mermaid_matches):
                            continue

                # Check terms in body
                body_terms = rule.get("match_terms_in_body", [])
                if body_terms:
                    if not any(term in content.lower() for term in body_terms):
                        continue

                # Check secondary terms in body if specified
                body_terms_sec = rule.get("match_terms_in_body_secondary", [])
                if body_terms_sec:
                    if not any(term in content.lower() for term in body_terms_sec):
                        continue

                found_match = True
                break

            if not found_match:
                errors.append(rule.get("error_message", f"Failed validation rule in {trigger.get('name')}"))

    return errors

def main():
    workspace_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))

    # Allow overriding paths via command-line args or environment variables.
    schema_dir = (
        sys.argv[1] if len(sys.argv) > 1
        else os.environ.get("SCHEMA_DIR", os.environ.get("YANG_DIR", None))
    )
    if not schema_dir:
        schema_path = os.path.join(workspace_dir, "schema")
        yang_path = os.path.join(workspace_dir, "yang")
        if os.path.exists(schema_path):
            schema_dir = schema_path
        else:
            schema_dir = yang_path

    features_dir = (
        sys.argv[2] if len(sys.argv) > 2
        else os.environ.get("FEATURES_DIR", os.path.join(workspace_dir, "docs", "features"))
    )

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

    skip_coverage_checks = False
    if not modules:
        non_yang_extensions = {".yaml", ".yml", ".json", ".proto"}
        has_non_yang_schemas = False
        if os.path.exists(schema_dir):
            for filename in os.listdir(schema_dir):
                ext = os.path.splitext(filename)[1].lower()
                if ext in non_yang_extensions:
                    has_non_yang_schemas = True
                    break
        if has_non_yang_schemas:
            print("Warning: Deep AST node coverage parity audit is currently optimized for YANG schemas. Skipping strict coverage percentage check for OpenAPI/Protobuf, but proceeding with UML compliance audit.")
            skip_coverage_checks = True
        else:
            print("Error: No valid modules/schemas found.")
            sys.exit(1)

    # 2. Load all feature markdown files
    features = load_feature_files(features_dir)
    print(f"Loaded {len(features)} feature specifications.\n")

    # 3. Audit coverage per module
    total_defined = 0
    total_covered = 0
    coverage_gaps = {}

    if not skip_coverage_checks:
        for module_name, definitions in sorted(modules.items()):
            # Find all feature files that explicitly list this module name in their labels
            matching_features = [f for f in features if module_name in f["labels"]]
            
            # If no features target this module explicitly, it is an auxiliary/unused schema and not a target epic.
            if not matching_features:
                continue

            # Combine content of all features globally (definitions can be documented in other features that import them)
            combined_text = "\n".join([f["content"] for f in features])

            module_defined = len(definitions)
            module_covered = 0
            missing = []

            for name in sorted(definitions):
                # Require the name to appear in a structured context to reduce false positives.
                # Match: `name`, **name**, |name|, - name, or preceded by YANG keywords.
                # Short names (<=3 chars) require backtick or bold wrapping to avoid prose matches.
                if len(name) <= 3:
                    pattern = rf"(`{re.escape(name)}`|\*\*{re.escape(name)}\*\*)"
                else:
                    pattern = rf"\b{re.escape(name)}\b"
                if re.search(pattern, combined_text):
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
    uml_errors = verify_uml_diagrams(features_dir)
    
    has_failed = False

    if uml_errors:
        print("[!] UML Compliance Violations Identified:")
        for err in uml_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: All specification files are fully UML-compliant (no ERDs or invalid syntax found).")

    if coverage_gaps:
        print("\n[!] Coverage Gaps Identified:")
        for module_name, missing in sorted(coverage_gaps.items()):
            print(f"  Module '{module_name}' is missing {len(missing)} nodes:")
            print(f"    Missing: {', '.join(missing)}")
        print("\nError: 100% model coverage validation failed.")
        has_failed = True
    else:
        if not skip_coverage_checks:
            print("\nSuccess: 100% model coverage verified across all specification files.")

    print("\n=== Behavioral Coverage Triggers Audit ===")
    behavioral_errors = verify_behavioral_triggers(schema_dir, features_dir, modules)

    if behavioral_errors:
        print("[!] Behavioral Coverage Violations Identified:")
        for err in behavioral_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: All behavioral coverage triggers passed.")

    if has_failed:
        sys.exit(1)
    else:
        print("\nSuccess: All verification checks passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
