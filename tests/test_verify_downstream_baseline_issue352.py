import os
import sys
import unittest.mock as mock
import pytest

# Ensure scripts directory is on sys.path
SCRIPTS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "scripts"))
if SCRIPTS_DIR not in sys.path:
    sys.path.insert(0, SCRIPTS_DIR)

import verify_downstream_baseline

def test_verify_downstream_baseline_detects_both_flutter_and_react_from_root(tmp_path):
    """
    Issue #352 Reproduction:
    When running verify_downstream_baseline from repository root against a target directory
    containing both app_flutter/pubspec.yaml and web_react/package.json,
    the path mutation of `dest` to `app_flutter` causes `web_react` to be skipped (`is_react` = False).
    """
    root_dir = tmp_path / "downstream_repo"
    root_dir.mkdir()
    
    app_flutter = root_dir / "app_flutter"
    app_flutter.mkdir()
    (app_flutter / "pubspec.yaml").write_text("name: test_flutter\n")
    
    web_react = root_dir / "web_react"
    web_react.mkdir()
    (web_react / "package.json").write_text('{"name": "test_react"}\n')

    captured_args = {}

    def mock_run_verification(args, dest, repo_root, is_flutter, is_react):
        captured_args["dest"] = dest
        captured_args["repo_root"] = repo_root
        captured_args["is_flutter"] = is_flutter
        captured_args["is_react"] = is_react
        return

    def mock_tag_restoration_point():
        return True

    def mock_cleanup_workspace(dest):
        pass

    with mock.patch.object(sys, "argv", ["verify_downstream_baseline.py", "--no-domain", str(root_dir)]), \
         mock.patch.object(verify_downstream_baseline, "_run_verification", side_effect=mock_run_verification), \
         mock.patch.object(verify_downstream_baseline, "tag_restoration_point", side_effect=mock_tag_restoration_point), \
         mock.patch.object(verify_downstream_baseline, "cleanup_workspace", side_effect=mock_cleanup_workspace):
        
        try:
            verify_downstream_baseline.main()
        except SystemExit as e:
            assert e.code == 0, f"main() exited with code {e.code}"

    # Expectation: when root contains both app_flutter and web_react, is_react MUST be True
    assert captured_args.get("is_flutter") is True, "Flutter should be detected"
    assert captured_args.get("is_react") is True, f"React was skipped! captured_args={captured_args}"
