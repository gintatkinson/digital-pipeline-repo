import pytest
from parity_auditor.validators.uml import UmlValidator
from parity_auditor.core.findings import Finding

def test_mermaid_state_diagram_escaping():
    validator = UmlValidator()
    
    valid_content = """
---
generation_mode: subagent
---
# Feature
```mermaid
stateDiagram-v2
    state if_state <<choice>>
    [*] --> Active
    Active --> Active : "increment [value < maxBound]"
    Active --> Inactive : "timeout > 50"
    Inactive --> [*]
```
"""

    invalid_content_1 = """
---
generation_mode: subagent
---
# Feature
```mermaid
stateDiagram-v2
    [*] --> Active
    Active --> Active : increment [value < maxBound]
```
"""

    invalid_content_2 = """
---
generation_mode: subagent
---
# Feature
```mermaid
stateDiagram-v2
    [*] --> Active
    Active --> Inactive : x > 10
```
"""

    invalid_content_3 = """
---
generation_mode: subagent
---
# Feature
```mermaid
stateDiagram-v2
    state A < B as state1
```
"""

    errors_valid = []
    validator._validate_state_diagram_escaping(valid_content, "Feature", "test.md", errors_valid)
    assert not errors_valid

    errors_inv1 = []
    validator._validate_state_diagram_escaping(invalid_content_1, "Feature", "test1.md", errors_inv1)
    assert len(errors_inv1) == 1
    assert "unquoted '<' character" in str(errors_inv1[0])

    errors_inv2 = []
    validator._validate_state_diagram_escaping(invalid_content_2, "Feature", "test2.md", errors_inv2)
    assert len(errors_inv2) == 1
    assert "unquoted '>'" in str(errors_inv2[0])

    errors_inv3 = []
    validator._validate_state_diagram_escaping(invalid_content_3, "Feature", "test3.md", errors_inv3)
    assert len(errors_inv3) == 1
    assert "unquoted '<'" in str(errors_inv3[0])
