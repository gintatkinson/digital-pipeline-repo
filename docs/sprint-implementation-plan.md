# Sprint Implementation Plan - Verification, Tracking & Linter Remediation

This plan details all changes to resolve the Git tracking onboarding issues, downstream pre-push hook validation errors, and the full suite of UML linter bugs (Issues 58 to 63). 

---

## 1. Setup, Git Tracking, & Hooks Integration

### Issue A: Downstream Git Tracking (Dot-files Ignored)
*   **Symptom**: Copied configuration folders (`.pipeline/` and `.agents/`) are ignored by Git in downstream repositories and never pushed to GitHub.
*   **Impact**: Agents running in downstream projects lack the constitution and profiles necessary to enforce project rules, leading to drift.
*   **Proposed Correction**: Update `setup_git_hooks.py` to automatically append whitelist rules (e.g. `!/.pipeline/`) to the project's root `.gitignore` file, and programmatically run `git add` to stage the copied directories.
*   **Audit Skill**: `spec-implementation-auditor/SKILL.md`
*   **Debug Skill**: `debug-protocol/SKILL.md`
*   **Executing Agent**: `Git Tracking Setup Auditor` (`self`)
*   **Verification**: Run `python3 scripts/setup_git_hooks.py` and verify `.gitignore` contains the whitelist overrides and files are staged.

### Issue B: Pre-Push Hook Removal
*   **Symptom**: Running `git push` triggers a heavy, time-consuming compilation build and full test execution cycle.
*   **Impact**: Wastes computational resources, developer time, and API tokens on redundant local runs that should be deferred to CI/CD.
*   **Proposed Correction**: Modify `setup_git_hooks.py` to remove the pre-push hook configuration and delete `.git/hooks/pre-push` from the workspace.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `Git Hook Cleanup Worker` (`self`)
*   **Verification**: Verify that `.git/hooks/pre-push` is deleted and pushing code does not trigger tests.

### Issue C: Config-Driven Downstream Verification (Bypass Pre-Push Crash)
*   **Symptom**: Pre-push verification crashes with missing file errors (`repository_resolver.dart`, etc.) if a downstream project was bootstrapped without a domain layer.
*   **Impact**: Blocks all Git pushes on `--no-domain` projects, halting development.
*   **Proposed Correction**: Modify `verify_downstream_baseline.py` to read local config JSON files (`codebase_rules.json` or `baseline_manifest.json`). If `"no_domain": true` is explicitly declared, bypass the domain layer file checks.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `Downstream Verification Auditor` (`self`)
*   **Verification**: Run `python3 scripts/verify_downstream_baseline.py app_flutter` and assert success when `"no_domain": true` is set.

### Issue D: Automated Workspace Cleanup
*   **Symptom**: Verification execution leaves behind untracked directories (`.dart_tool/`, `.flutter-plugins`) and SQLite transaction logs (`*.db-shm`, `*.db-wal`) in the workspace.
*   **Impact**: litters the workspace with junk files, causing clutter in `git status`.
*   **Proposed Correction**: Add a cleanup routine in `verify_downstream_baseline.py` that deletes all generated transient folders/files right before exiting.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `Workspace Cleanup Worker` (`self`)
*   **Verification**: Run the validator script and assert `git status` remains clean.

### Issue E: Auto-Tag Restoration Point
*   **Symptom**: Developers cannot easily roll back their workspace to the last successful verification point when subsequent changes fail.
*   **Impact**: Recovery from code or config violations requires manual git reverts and troubleshooting.
*   **Proposed Correction**: Automatically tag the current commit as `restoration-point` locally upon successful completion of the verification script.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `Restoration Point Tagging Agent` (`self`)
*   **Verification**: Verify `git describe --tags` outputs `restoration-point` pointing to the latest verified commit.

---

## 2. Parity Auditor & Linter Refactor (Issues 58 to 63)

### Issue 58: Programmatic validate() ignores Epic diagrams [EPIC-LNT-01]
*   **Symptom**: Programmatic calls to `validate()` in `uml.py` do not scan the epic specification diagrams.
*   **Impact**: Validations pass programmatically even if epic diagrams contain severe UML syntax errors, leading to false negatives.
*   **Proposed Correction**: Pass `epics_dir` to `build_global_classes` inside `uml.py` to compile Epic diagrams during programmatic validation checks.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `UML Epic Validator Auditor` (`self`)
*   **Verification**: Run the Python test suite and verify no regressions in programmatic validations.

### Issue 59: Epic class compilation bypassed when features list empty [EPIC-LNT-02]
*   **Symptom**: If the features specification folder is empty, the linter completely skips scanning and validating Epic-level UML diagrams.
*   **Impact**: Repositories containing only Epic-level specifications cannot enforce codebase coverage or UML syntax compliance.
*   **Proposed Correction**: Update `cli.py` to skip coverage checks only if *both* feature files and epic files are missing, ensuring epics are compiled regardless of feature counts.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `CLI Epic Compiler Auditor` (`self`)
*   **Verification**: Run the linter with an empty feature folder and check that Epic diagrams are still processed.

### Issue 60: Multiplicity parsed strictly at end of attribute lines [LNT-UML-01]
*   **Symptom**: The parser fails to extract multiplicity from type-bound notation like `+String[0..*] name`, leaving the type as `String[0..*]`.
*   **Impact**: Valid UML class diagrams are rejected by the linter because `String[0..*]` is not a recognized primitive type.
*   **Proposed Correction**: Refactor the regex in `mermaid.py`'s `parse_attribute_signature()` to search for brackets `[...]` anywhere in the signature string and isolate it from the type.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `Mermaid Parser Auditor` (`self`)
*   **Verification**: Assert that `+String[0..*] name` parses correctly with `multiplicity="0..*"` and `type="String"`.

### Issue 61: Return validator incorrectly requires multiplicity [LNT-UML-02]
*   **Symptom**: The method return validator rejects methods that do not explicitly define multiplicity (e.g. `+Node fetch()`).
*   **Impact**: Throws false positive validation failures on standard method signatures that return single objects or are void.
*   **Proposed Correction**: Update `_validate_class_diagram` in `uml.py` to default method returns to a multiplicity of `[1]` unless brackets `[...]` are explicitly present in the signature.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `Method Signature Auditor` (`self`)
*   **Verification**: Verify that `+save()` and `+Node fetch()` validate successfully.

### Issue 62: Codebase coverage checked via naive substring matching [LNT-UML-03]
*   **Symptom**: Property coverage is checked by searching for the property name as a raw substring across the entire codebase.
*   **Impact**: Properties named `id` or `name` match occurrences inside comments or strings, creating false positives that mask missing code implementations.
*   **Proposed Correction**: Implement `is_present_in_codebase()` in `cli.py` to match common words strictly against actual code structures (like constructor bindings or type assignments), ignoring comments.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `AST Coverage Auditor` (`self`)
*   **Verification**: Ensure properties in comments do not trigger false positive coverage flags.

### Issue 63: Link and diagram checks run on raw file content [LNT-UML-04]
*   **Symptom**: Linter checks for invalid dotted link syntax are run against the raw, full text of specification Markdown files.
*   **Impact**: Normal markdown prose or standard links containing matching character patterns are falsely rejected by the linter.
*   **Proposed Correction**: Extract only the ````mermaid ... ```` blocks from the file content before running Mermaid dotted-link validations in `uml.py`.
*   **Audit/Debug Skills**: `spec-implementation-auditor/SKILL.md` & `debug-protocol/SKILL.md`
*   **Executing Agent**: `Prose Validator Auditor` (`self`)
*   **Verification**: Assert that specification files containing standard markdown prose links pass verification.
