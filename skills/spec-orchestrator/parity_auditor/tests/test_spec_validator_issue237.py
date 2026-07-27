import os
import sys
import tempfile
import json
import shutil
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from parity_auditor.validators.dependency_validator import DependencyValidator
from parity_auditor.core.workspace import WorkspaceRepository

def test_validate_epic_prerequisite_links_issue237():
    tmpdir = tempfile.mkdtemp()
    try:
        pipeline_dir = os.path.join(tmpdir, ".pipeline", "logical-ui")
        os.makedirs(pipeline_dir, exist_ok=True)
        
        rules = {
            "meta": {},
            "target_directories": {},
            "flutter_rules": {},
            "python_rules": {},
            "backlog_directories": {
                "schemas": "schema",
                "epics": "docs/epics",
                "features": "docs/features"
            },
            "spec_rules": {},
            "validation_rules": {}
        }
        with open(os.path.join(pipeline_dir, "codebase_rules.json"), "w") as f:
            json.dump(rules, f)
            
        schema_dir = os.path.join(tmpdir, "schema")
        epics_dir = os.path.join(tmpdir, "docs", "epics")
        os.makedirs(schema_dir, exist_ok=True)
        os.makedirs(epics_dir, exist_ok=True)
        
        # Base schema file
        with open(os.path.join(schema_dir, "ietf-base.yang"), "w") as f:
            f.write("module ietf-base {\n  namespace 'urn:ietf:params:xml:ns:yang:ietf-base';\n  prefix b;\n}\n")
            
        # Sub schema importing base schema
        with open(os.path.join(schema_dir, "ietf-sub.yang"), "w") as f:
            f.write("module ietf-sub {\n  namespace 'urn:ietf:params:xml:ns:yang:ietf-sub';\n  prefix s;\n  import ietf-base {\n    prefix b;\n  }\n}\n")
            
        # Epic 1: Parent epic declaring base schema
        with open(os.path.join(epics_dir, "epic-001-base.md"), "w") as f:
            f.write("# Epic 1: Base Schema Epic\nParent Epic: N/A\n\nDefines `ietf-base`.\n")
            
        # Epic 2: Invalid sub epic referencing imported schema ietf-base WITHOUT explicit parent epic link
        with open(os.path.join(epics_dir, "epic-002-orphaned-sub.md"), "w") as f:
            f.write("# Epic 2: Orphaned Sub Epic\n\nReferences imported schema `ietf-base` but missing parent link.\n")
            
        # Epic 3: Valid sub epic referencing imported schema ietf-base WITH explicit parent epic link
        with open(os.path.join(epics_dir, "epic-003-valid-sub.md"), "w") as f:
            f.write("# Epic 3: Valid Sub Epic\nParent Epic: [Epic 1: Base Schema Epic](./epic-001-base.md)\n\nReferences imported schema `ietf-base` with explicit parent link.\n")
            
        repo = WorkspaceRepository(tmpdir)
        validator = DependencyValidator()
        
        # Check validate_epic_prerequisite_links exists and returns errors
        assert hasattr(validator, "validate_epic_prerequisite_links"), "DependencyValidator missing validate_epic_prerequisite_links"
        
        prereq_errors = validator.validate_epic_prerequisite_links(repo)
        assert any("epic-002-orphaned-sub.md" in err and "ietf-base" in err for err in prereq_errors), \
            f"Expected error for epic-002-orphaned-sub.md referencing ietf-base, got: {prereq_errors}"
        assert not any("epic-003-valid-sub.md" in err for err in prereq_errors), \
            f"Did not expect error for epic-003-valid-sub.md, got: {prereq_errors}"
            
        all_errors = validator.validate(repo)
        assert any("epic-002-orphaned-sub.md" in err and "ietf-base" in err for err in all_errors), \
            f"Expected error in validate() for epic-002-orphaned-sub.md, got: {all_errors}"
    finally:
        shutil.rmtree(tmpdir)
