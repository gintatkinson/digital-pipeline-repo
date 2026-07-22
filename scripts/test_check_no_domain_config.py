#!/usr/bin/env python3
"""Regression test: check_no_domain_config should find config at repo root
even when dest has been reassigned to a platform subdirectory."""

import json
import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from verify_downstream_baseline import check_no_domain_config


def test_config_found_when_dest_reassigned_to_app_flutter():
    """Config at repo root should be detected even after dest -> app_flutter/."""
    with tempfile.TemporaryDirectory() as tmp:
        repo_root = os.path.join(tmp, "repo")
        app_flutter = os.path.join(repo_root, "app_flutter")
        os.makedirs(app_flutter)

        config = {"validation_rules": {"no_domain": True}}
        with open(os.path.join(repo_root, "codebase_rules.json"), "w") as f:
            json.dump(config, f)

        with open(os.path.join(app_flutter, "pubspec.yaml"), "w") as f:
            f.write("name: test\n")

        dest = os.path.abspath(repo_root)
        repo_root_saved = dest

        is_flutter = os.path.exists(os.path.join(dest, "pubspec.yaml"))
        if not is_flutter and os.path.isdir(os.path.join(dest, "app_flutter")):
            dest_flutter = os.path.join(dest, "app_flutter")
            if os.path.exists(os.path.join(dest_flutter, "pubspec.yaml")):
                dest = dest_flutter
                is_flutter = True

        # BUG: checking dest (app_flutter/) misses config at repo root
        assert not check_no_domain_config(dest), (
            "Precondition: dest=app_flutter should NOT find config (it lives at repo root)"
        )

        # FIX: checking repo_root_saved should find config
        assert check_no_domain_config(repo_root_saved), (
            "FAIL: check_no_domain_config(repo_root) should detect no_domain config at repo root"
        )


def test_config_not_found_when_no_config_exists():
    """No false positive when config doesn't exist anywhere."""
    with tempfile.TemporaryDirectory() as tmp:
        assert not check_no_domain_config(tmp)


def test_baseline_manifest_detected():
    """baseline_manifest.json with no_domain should be detected."""
    with tempfile.TemporaryDirectory() as tmp:
        config = {"no_domain": True}
        with open(os.path.join(tmp, "baseline_manifest.json"), "w") as f:
            json.dump(config, f)
        assert check_no_domain_config(tmp)


def test_cleanup_workspace_preserves_dart_tool_cache():
    """cleanup_workspace should preserve .dart_tool/ cache directory.
    Only stale lock files (package_config.json.lock) should be cleaned, not the
    entire .dart_tool/ directory which caches resolved dependency packages.
    See Issue #91."""
    import tempfile
    import shutil
    from verify_downstream_baseline import cleanup_workspace

    tmpdir = None
    try:
        tmpdir = tempfile.mkdtemp()
        dart_tool = os.path.join(tmpdir, ".dart_tool")
        os.makedirs(dart_tool, exist_ok=True)

        lock_file = os.path.join(dart_tool, "package_config.json.lock")
        with open(lock_file, "w") as f:
            f.write("locked")

        package_config = os.path.join(dart_tool, "package_config.json")
        with open(package_config, "w") as f:
            f.write("cached")

        flutter_plugins_deps = os.path.join(tmpdir, ".flutter-plugins-dependencies")
        with open(flutter_plugins_deps, "w") as f:
            f.write("plugins")

        cleanup_workspace(tmpdir)

        assert os.path.isdir(dart_tool), (
            ".dart_tool/ cache directory was DELETED — it should be preserved"
        )
        assert not os.path.isfile(lock_file), (
            "package_config.json.lock should be cleaned (stale lock file)"
        )
        assert os.path.isfile(package_config), (
            "package_config.json should be preserved (cached dependency data)"
        )
        assert not os.path.isfile(flutter_plugins_deps), (
            ".flutter-plugins-dependencies should be cleaned (generated, not cached)"
        )
    finally:
        if tmpdir and os.path.exists(tmpdir):
            shutil.rmtree(tmpdir)


if __name__ == "__main__":
    test_config_found_when_dest_reassigned_to_app_flutter()
    test_config_not_found_when_no_config_exists()
    test_baseline_manifest_detected()
    test_cleanup_workspace_preserves_dart_tool_cache()
    print("ALL TESTS PASSED")
