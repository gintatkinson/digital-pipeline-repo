import os
import sys
import tempfile
import json
import shutil

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from parity_auditor.validators.profile_compliance_validator import ProfileComplianceValidator
from parity_auditor.core.workspace import WorkspaceRepository


def test_profile_compliance_validator_detects_missing_traceability_tags():
    tmpdir = tempfile.mkdtemp()
    try:
        pipeline_dir = os.path.join(tmpdir, ".pipeline", "logical-ui")
        os.makedirs(pipeline_dir, exist_ok=True)
        rules = {
            "meta": {"upstream_repository": "gintatkinson/digital-pipeline-repo"},
            "target_directories": {
                "flutter": "app_flutter"
            },
            "flutter_rules": {
                "file_extensions": [".dart"],
                "exclusions": []
            }
        }
        with open(os.path.join(pipeline_dir, "codebase_rules.json"), "w", encoding="utf-8") as f:
            json.dump(rules, f)

        app_dir = os.path.join(tmpdir, "app_flutter")
        os.makedirs(app_dir, exist_ok=True)

        # File without Realises tag
        with open(os.path.join(app_dir, "unregistered.dart"), "w", encoding="utf-8") as f:
            f.write("/// Documented class\nclass UnregisteredClass {}\n")

        # File with Realises tag
        with open(os.path.join(app_dir, "registered.dart"), "w", encoding="utf-8") as f:
            f.write("/// Realises: [Feat-002/RegisteredClass]\n/// Documented class\nclass RegisteredClass {}\n")

        # Private class without tag (should be ignored)
        with open(os.path.join(app_dir, "private.dart"), "w", encoding="utf-8") as f:
            f.write("class _PrivateClass {}\n")

        repo = WorkspaceRepository(tmpdir)
        validator = ProfileComplianceValidator()
        errors = validator.validate(repo)

        assert any("UnregisteredClass" in str(err) for err in errors)
        assert not any("RegisteredClass" in str(err) for err in errors)
        assert not any("_PrivateClass" in str(err) for err in errors)
    finally:
        shutil.rmtree(tmpdir)
