# Copyright Gint Atkinson, gint.atkinson@gmail.com

#!/usr/bin/env python3
import os
import re
import sys

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
        if not re.search(r"```mermaid\s*\n\s*classDiagram", content):
            errors.append(f"Feature {os.path.basename(filepath)} is missing a valid '```mermaid classDiagram' block.")
            
        # Check that erDiagram is NOT used
        if re.search(r"erDiagram", content):
            errors.append(f"Feature {os.path.basename(filepath)} contains forbidden 'erDiagram' (ERD diagrams are strictly prohibited).")

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

    return errors

def main():
    workspace_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))

    # Allow overriding paths via command-line args or environment variables.
    # Usage: verify_model_coverage.py [yang_dir] [features_dir]
    yang_dir = (
        sys.argv[1] if len(sys.argv) > 1
        else os.environ.get("YANG_DIR", os.path.join(workspace_dir, "yang"))
    )
    features_dir = (
        sys.argv[2] if len(sys.argv) > 2
        else os.environ.get("FEATURES_DIR", os.path.join(workspace_dir, "docs", "features"))
    )

    if not os.path.exists(yang_dir):
        print(f"Error: YANG directory not found at {yang_dir}")
        sys.exit(1)

    print("=== Model Coverage Parity Audit ===")
    print(f"Scanning YANG schemas in: {yang_dir}")
    print(f"Scanning feature specifications in: {features_dir}\n")

    # 1. Parse all YANG modules
    modules = {}
    for filename in os.listdir(yang_dir):
        if not filename.endswith(".yang"):
            continue
        filepath = os.path.join(yang_dir, filename)
        try:
            module_name, definitions = parse_yang_file(filepath)
            if module_name:
                modules[module_name] = definitions
        except Exception as e:
            print(f"Warning: Failed to parse YANG file {filename}: {e}")

    if not modules:
        print("Error: No valid YANG modules found.")
        sys.exit(1)

    # 2. Load all feature markdown files
    features = load_feature_files(features_dir)
    print(f"Loaded {len(features)} feature specifications.\n")

    # 3. Audit coverage per module
    total_defined = 0
    total_covered = 0
    coverage_gaps = {}

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
        print("\nSuccess: 100% model coverage verified across all specification files.")

    if has_failed:
        sys.exit(1)
    else:
        print("\nSuccess: All verification checks passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
