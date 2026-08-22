import os
import sys
import shutil
import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "skills/spec-orchestrator/parity_auditor/src")))

@pytest.fixture(autouse=True)
def cleanup_pipeline_diagnostics():
    yield
    diag_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".pipeline", "diagnostics"))
    if os.path.exists(diag_dir):
        shutil.rmtree(diag_dir, ignore_errors=True)
