import os
import json
import sys
from unittest.mock import patch

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from scripts.install_pipeline import install

def test_install_pipeline(tmp_path):
    with patch("os.getcwd", return_value=str(tmp_path)):
        os.chdir(str(tmp_path))
        install("backend-api")
        config_path = os.path.join(".pipeline", "profile_config.json")
        assert os.path.exists(config_path)
        with open(config_path, "r") as f:
            data = json.load(f)
            assert data["active_profile"] == "backend-api"


def test_install_pipeline_sh_exists_and_executable():
    script_path = os.path.join(os.path.dirname(__file__), "..", "scripts", "install_pipeline.sh")
    assert os.path.exists(script_path), "scripts/install_pipeline.sh must exist"
    assert os.access(script_path, os.X_OK), "scripts/install_pipeline.sh must be executable"
    
    with open(script_path, "r", encoding="utf-8") as f:
        content = f.read()

    assert '!= "upstream"' in content
    assert "rm -rf ./.pipeline/upstream" not in content
    assert "git clone" in content
    assert ".tmp-pipeline-install" in content
    assert "skills/" in content
    assert "rules/" in content
    assert ".pipeline/" in content
    assert ".agents/" in content
    assert "scripts/" in content
    assert "app_flutter/" in content
    assert "web_react/" in content
    assert "AGENTS.md" in content
    assert ".gitignore" in content
    assert "setup_git_hooks.py" in content
    assert "bootstrap_tracker_labels.py" in content
    assert ".venv" in content
    assert "python3.12 -m venv" in content
    assert "pip install" in content
    assert "pytest" in content
    assert "compile_sysml.py" in content


def test_turnkey_install_instructions_and_downstream_compatibility_in_docs():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    docs_to_check = [
        os.path.join(repo_root, "install-guide.md"),
        os.path.join(repo_root, "README.md"),
    ]
    turnkey_cmd = "curl -sSL https://raw.githubusercontent.com/gintatkinson/digital-pipeline-repo/main/scripts/install_pipeline.sh | bash"
    downstream_repos = ["DEAP-uas-infrastructure-safety", "DEAP-avionic-flight-safety"]

    for doc_path in docs_to_check:
        assert os.path.exists(doc_path), f"{doc_path} must exist"
        with open(doc_path, "r", encoding="utf-8") as f:
            content = f.read()

        assert turnkey_cmd in content, f"{doc_path} must contain turnkey install command"
        assert "Primary Single-Step Standard" in content or "primary single-step standard" in content.lower(), (
            f"{doc_path} must position turnkey installer as primary single-step standard"
        )
        assert "Fallback Reference Steps" in content or "fallback reference" in content.lower(), (
            f"{doc_path} must designate manual copy instructions as fallback reference steps"
        )
        for repo in downstream_repos:
            assert repo in content, f"{doc_path} must reference downstream repo compatibility for '{repo}'"


