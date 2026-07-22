"""Tests for UML class diagram method return multiplicity validation."""
import os
import sys
import tempfile
import json
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from parity_auditor.validators.uml import UmlValidator
from parity_auditor.core.workspace import WorkspaceRepository


def _setup_workspace(class_diagram_body: str) -> str:
    tmpdir = tempfile.mkdtemp()
    pipeline_dir = os.path.join(tmpdir, ".pipeline", "logical-ui")
    os.makedirs(pipeline_dir, exist_ok=True)
    rules = {
        "meta": {},
        "backlog_directories": {"features": "features", "user_stories": "user_stories", "use_cases": "use_cases"},
        "target_directories": {},
        "flutter_rules": {},
        "python_rules": {},
        "spec_rules": {},
        "validation_rules": {
            "visibility_prefixes": ["+", "-", "#", "~"],
            "multiplicity_regex": "\\[[^\\]]+\\]",
            "uml_primitives": ["String", "Integer", "Real", "Boolean"],
            "relationship_connectors": "(\\*--|o--|<\\|--|--|-->)",
            "choice_stereotypes": ["<<choice>>"],
            "required_sections": {
                "feature_ui": [
                    ["## 1. Overview", "Overview"],
                    ["## 2. Requirements", "Requirements"],
                    ["## 3. Validation", "Validation"],
                    ["## 4. Diagrams", "Diagrams"]
                ]
            },
            "required_diagrams": {"feature": ["classDiagram"]}
        }
    }
    with open(os.path.join(pipeline_dir, "codebase_rules.json"), "w") as f:
        json.dump(rules, f)

    features_dir = os.path.join(tmpdir, "features")
    user_stories_dir = os.path.join(tmpdir, "user_stories")
    use_cases_dir = os.path.join(tmpdir, "use_cases")
    os.makedirs(features_dir, exist_ok=True)
    os.makedirs(user_stories_dir, exist_ok=True)
    os.makedirs(use_cases_dir, exist_ok=True)

    md_content = f"""---
title: Test
interface_type: ui
---

## 1. Overview
test

## 2. Requirements & Checklist
- [ ] test

## 3. Validation & Constraints
- test

## 4. Diagrams

```mermaid
{class_diagram_body}
```
"""
    with open(os.path.join(features_dir, "feat-01-test.md"), "w") as f:
        f.write(md_content)
    return tmpdir


def test_method_return_without_multiplicity_rejected():
    """+Node fetch() without [1] should be rejected for missing multiplicity."""
    tmpdir = _setup_workspace("""classDiagram
    class Node {{
        +String id [1]
        +Node fetch()
    }}
    class Container {{
        +String name [1]
    }}
    Container *-- Node : contains
""")
    try:
        repo = WorkspaceRepository(tmpdir)
        validator = UmlValidator()
        errors = validator.validate(repo)
        multiplicity_errors = [e for e in errors if "fetch" in e and "multiplicity" in e]
        assert len(multiplicity_errors) >= 1, f"Expected multiplicity error for +Node fetch(), got errors: {errors}"
    finally:
        import shutil
        shutil.rmtree(tmpdir)


def test_method_return_with_multiplicity_accepted():
    """+Node[] fetch() with [1] on return should be accepted."""
    tmpdir = _setup_workspace("""classDiagram
    class Node {{
        +String id [1]
        +Node [] fetch()
    }}
    class Container {{
        +String name [1]
    }}
    Container *-- Node : contains
""")
    try:
        repo = WorkspaceRepository(tmpdir)
        validator = UmlValidator()
        errors = validator.validate(repo)
        multiplicity_errors = [e for e in errors if "fetch" in e and "multiplicity" in e]
        assert len(multiplicity_errors) == 0, f"Expected NO multiplicity error for +Node[] fetch(), got: {errors}"
    finally:
        import shutil
        shutil.rmtree(tmpdir)


def test_method_return_void_skipped():
    """void methods should skip multiplicity check entirely."""
    tmpdir = _setup_workspace("""classDiagram
    class Node {{
        +String id [1]
        +void save()
    }}
    class Container {{
        +String name [1]
    }}
    Container *-- Node : contains
""")
    try:
        repo = WorkspaceRepository(tmpdir)
        validator = UmlValidator()
        errors = validator.validate(repo)
        multiplicity_errors = [e for e in errors if "save" in e and "multiplicity" in e]
        assert len(multiplicity_errors) == 0, f"void method should not trigger multiplicity error, got: {errors}"
    finally:
        import shutil
        shutil.rmtree(tmpdir)
