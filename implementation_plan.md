# Detailed Engineering Implementation Plan: Debug Protocol and Adversarial Auditor Fixes

This implementation plan resolves GitHub Issues #56 and #57 by enforcing a strict mechanical proof gate for issue closure in `debug-protocol` and adding the "Semantic Traceability" pillar to `adversarial-code-auditor`.

---

## 1. Target Files & Code Diffs

### Component: Debug Protocol (Recursive Debugging Loop)

#### [MODIFY] [SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/debug-protocol/SKILL.md)

##### Change 1: Enforce Three-Proof Gate in Step 7 (L58-59)
Modify Step 7 instructions to require fix presence grep check, raw test output, and git diff verification:
```markdown
<<<<
## Step 7 — Verification Subagent
Dispatch a subagent to: Confirm bug is fixed using original reproduction steps. Test edge cases. Verify no regressions (test suite must pass). Once verified, comment on and close the GitHub issue to mark it as resolved. Return pass/fail result.
====
## Step 7 — Verification Subagent
Dispatch a subagent to:
1. Confirm bug is fixed using original reproduction steps from Step 1.
2. Grep the fix location (FILE_LOCATION from issue body) and confirm the fix code is present.
3. Run the full test suite and paste raw terminal output.
4. Show `git diff` of the fix commit to confirm only expected changes.
5. If all three proofs pass, comment on the GitHub issue with the evidence and close it.
Return: grep output, raw test output, git diff output. Do NOT return a pass/fail summary without evidence.
>>>>
```

##### Change 2: Update Checklist Item for Step 7 (L88)
Update the verification checklist item to reflect the three-proof validation:
```markdown
<<<<
- [ ] Step 7 subagent dispatched, tests pass, issue closed
====
- [ ] Step 7: Verification subagent dispatched, three proofs validated, issue closed with mechanical proof
>>>>
```

---

### Component: Adversarial Code Auditor

#### [MODIFY] [SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/adversarial-code-auditor/SKILL.md)

##### Change 1: Add Semantic Traceability to Pillars Table (L27-32)
Insert the new "Semantic Traceability" pillar to enforce defect-to-test mapping:
```markdown
<<<<
| Test Integrity | FFI/DB-dependent tests, sleep loops, bare assert(), missing testWidgets, duplicated fakes, flaky assertions |
====
| Test Integrity | FFI/DB-dependent tests, sleep loops, bare assert(), missing testWidgets, duplicated fakes, flaky assertions |
| Semantic Traceability | Test assertions mapped to defect invariants from issue body. Tests that pass without exercising the reported symptom. Tests whose assertions don't match the invariants violated. |
>>>>
```

##### Change 2: Include Semantic Traceability in Skeleton Output (L67)
Update the pillar selection placeholder options in Section 2 skeleton:
```markdown
<<<<
* **Pillar**: [Memory Safety | Resource Lifecycle | Concurrency | Test Integrity]
====
* **Pillar**: [Memory Safety | Resource Lifecycle | Concurrency | Test Integrity | Semantic Traceability]
>>>>
```

---

## 2. Verification Plan

### Automated Verification
* Verify that the markdown files render correctly without broken formatting or unclosed code blocks.

### Manual Verification
* Coordinator inspects the updated skills to confirm the three-proof gate and the fifth audit pillar are correctly documented.
