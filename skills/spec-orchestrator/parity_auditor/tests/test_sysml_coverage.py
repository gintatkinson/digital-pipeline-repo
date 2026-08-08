import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from unittest.mock import patch, MagicMock
from parity_auditor.validators.cardinality_validator import SchemaCardinalityValidator
from parity_auditor.core.workspace import WorkspaceRepository

def test_sysml_coverage_validation():
    repo = MagicMock(spec=WorkspaceRepository)
    repo.workspace_dir = "/dummy"
    rules = MagicMock()
    rules.backlog_directories.schemas = "schemas"
    rules.backlog_directories.features = "features"
    repo.get_codebase_rules.return_value = rules

    with patch('os.path.exists', return_value=True), \
         patch('os.listdir', side_effect=lambda d: ['test.sysml'] if 'schemas' in d else ['feat.md']), \
         patch('builtins.open') as mock_open:
         
        mock_file = MagicMock()
        # The first open is for sysml, the second for markdown
        mock_file.__enter__.side_effect = [
            MagicMock(read=lambda: "part def MyPart {} attribute def MyAttr {}"),
            MagicMock(read=lambda: "This feature implements MyPart.")
        ]
        mock_open.return_value = mock_file
        
        validator = SchemaCardinalityValidator()
        errors = validator.validate(repo, is_sysml=True)
        
        # MyAttr should be missing
        assert len(errors) == 1
        assert "MyAttr" in errors[0]
        assert "MyPart" not in errors[0]


def test_sysml_coverage_no_sysml_files_produces_finding(tmp_path):
    workspace_dir = str(tmp_path)
    schemas_dir = os.path.join(workspace_dir, "schemas")
    features_dir = os.path.join(workspace_dir, "features")
    os.makedirs(schemas_dir, exist_ok=True)
    os.makedirs(features_dir, exist_ok=True)

    repo_mock = MagicMock()
    repo_mock.workspace_dir = workspace_dir
    rules = MagicMock()
    rules.backlog_directories.schemas = "schemas"
    rules.backlog_directories.features = "features"
    repo_mock.get_codebase_rules.return_value = rules

    validator = SchemaCardinalityValidator()
    errors = validator.validate(repo_mock, is_sysml=True)

    assert len(errors) == 1
    assert errors[0].rule_id == "sysml-model-not-readable"
    assert "no .sysml file was found" in errors[0]


def test_sysml_coverage_unreadable_sysml_file_produces_finding(tmp_path):
    workspace_dir = str(tmp_path)
    schemas_dir = os.path.join(workspace_dir, "schemas")
    features_dir = os.path.join(workspace_dir, "features")
    os.makedirs(schemas_dir, exist_ok=True)
    os.makedirs(features_dir, exist_ok=True)

    sysml_file = os.path.join(schemas_dir, "corrupt.sysml")
    with open(sysml_file, "w") as f:
        f.write("part def TestPart {}")

    repo_mock = MagicMock()
    repo_mock.workspace_dir = workspace_dir
    rules = MagicMock()
    rules.backlog_directories.schemas = "schemas"
    rules.backlog_directories.features = "features"
    repo_mock.get_codebase_rules.return_value = rules

    validator = SchemaCardinalityValidator()
    with patch("builtins.open", side_effect=OSError("Read error")):
        errors = validator.validate(repo_mock, is_sysml=True)

    assert len(errors) == 1
    assert errors[0].rule_id == "sysml-model-not-readable"
    assert "Failed to read SysML model file" in errors[0]


def test_sysml_coverage_unreadable_feature_file_produces_finding(tmp_path):
    workspace_dir = str(tmp_path)
    schemas_dir = os.path.join(workspace_dir, "schemas")
    features_dir = os.path.join(workspace_dir, "features")
    os.makedirs(schemas_dir, exist_ok=True)
    os.makedirs(features_dir, exist_ok=True)

    sysml_file = os.path.join(schemas_dir, "model.sysml")
    with open(sysml_file, "w") as f:
        f.write("part def TestPart {}")

    feat_file = os.path.join(features_dir, "feat.md")
    with open(feat_file, "w") as f:
        f.write("Feature content")

    repo_mock = MagicMock()
    repo_mock.workspace_dir = workspace_dir
    rules = MagicMock()
    rules.backlog_directories.schemas = "schemas"
    rules.backlog_directories.features = "features"
    repo_mock.get_codebase_rules.return_value = rules

    validator = SchemaCardinalityValidator()

    original_open = open
    def mock_open_func(file, *args, **kwargs):
        if str(file).endswith("feat.md"):
            raise OSError("Feature read error")
        return original_open(file, *args, **kwargs)

    with patch("builtins.open", side_effect=mock_open_func):
        errors = validator.validate(repo_mock, is_sysml=True)

    finding_ids = [e.rule_id for e in errors]
    assert "sysml-feature-not-readable" in finding_ids


def test_sysml_coverage_word_boundary_negative_control(tmp_path):
    workspace_dir = str(tmp_path)
    schemas_dir = os.path.join(workspace_dir, "schemas")
    features_dir = os.path.join(workspace_dir, "features")
    os.makedirs(schemas_dir, exist_ok=True)
    os.makedirs(features_dir, exist_ok=True)

    sysml_file = os.path.join(schemas_dir, "model.sysml")
    with open(sysml_file, "w") as f:
        f.write("port def Port {}")

    feat_file = os.path.join(features_dir, "feat.md")
    with open(feat_file, "w") as f:
        f.write("This feature uses Portal and Passport.")

    repo_mock = MagicMock()
    repo_mock.workspace_dir = workspace_dir
    rules = MagicMock()
    rules.backlog_directories.schemas = "schemas"
    rules.backlog_directories.features = "features"
    repo_mock.get_codebase_rules.return_value = rules

    validator = SchemaCardinalityValidator()
    errors = validator.validate(repo_mock, is_sysml=True)

    assert len(errors) == 1
    assert errors[0].rule_id == "sysml-extraction-missing"
    assert "SysML node 'Port' is not extracted into any feature specification." in str(errors[0])


def test_sysml_coverage_word_boundary_positive_control(tmp_path):
    workspace_dir = str(tmp_path)
    schemas_dir = os.path.join(workspace_dir, "schemas")
    features_dir = os.path.join(workspace_dir, "features")
    os.makedirs(schemas_dir, exist_ok=True)
    os.makedirs(features_dir, exist_ok=True)

    sysml_file = os.path.join(schemas_dir, "model.sysml")
    with open(sysml_file, "w") as f:
        f.write("port def Port {}")

    feat_file = os.path.join(features_dir, "feat.md")
    with open(feat_file, "w") as f:
        f.write("This feature configures Port 80.")

    repo_mock = MagicMock()
    repo_mock.workspace_dir = workspace_dir
    rules = MagicMock()
    rules.backlog_directories.schemas = "schemas"
    rules.backlog_directories.features = "features"
    repo_mock.get_codebase_rules.return_value = rules

    validator = SchemaCardinalityValidator()
    errors = validator.validate(repo_mock, is_sysml=True)

    assert len(errors) == 0


