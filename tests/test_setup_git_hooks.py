import os
import shutil
import subprocess
import sys
import pytest


INFRA_DIRS = ["/skills", "/rules", "/.pipeline", "/.agents", "/scripts"]
WHITELIST_ENTRIES = [f"!{d}{s}" for d in INFRA_DIRS for s in ("/", "/**")]


def _make_repo(tmp_path, init_git=True):
    gitignore = tmp_path / ".gitignore"
    gitignore.write_text(".*\n")
    if init_git:
        subprocess.run(["git", "init"], capture_output=True, cwd=str(tmp_path))
    else:
        (tmp_path / ".git").mkdir()
        (tmp_path / ".git" / "hooks").mkdir()

    scripts_dir = tmp_path / "scripts"
    scripts_dir.mkdir()
    src = os.path.join(os.path.dirname(__file__), "..", "scripts", "setup_git_hooks.py")
    shutil.copy2(src, scripts_dir / "setup_git_hooks.py")

    for d in [".pipeline", ".agents", "skills", "rules", "scripts"]:
        (tmp_path / d).mkdir(exist_ok=True)
        (tmp_path / d / ".gitkeep").write_text("")

    return scripts_dir / "setup_git_hooks.py"


def _run_script(script_path, cwd):
    return subprocess.run(
        [sys.executable, str(script_path)],
        capture_output=True, text=True, cwd=str(cwd)
    )


def test_whitelist_appended_to_gitignore(tmp_path):
    script = _make_repo(tmp_path, init_git=False)
    result = _run_script(script, tmp_path)
    assert result.returncode == 0, result.stderr

    content = (tmp_path / ".gitignore").read_text()
    for entry in WHITELIST_ENTRIES:
        assert entry in content, f"Missing whitelist entry: {entry}"


def test_pipeline_dirs_staged_after_setup(tmp_path):
    script = _make_repo(tmp_path, init_git=True)
    result = _run_script(script, tmp_path)
    assert result.returncode == 0, result.stderr

    staged = subprocess.run(
        ["git", "diff", "--cached", "--name-only"],
        capture_output=True, text=True, cwd=str(tmp_path)
    )
    staged_files = staged.stdout.strip().split("\n") if staged.stdout.strip() else []
    for d in [".pipeline", ".agents", "skills", "rules", "scripts"]:
        found = any(f.startswith(d + "/") or f == d for f in staged_files)
        assert found, f"Directory not staged: {d}"
