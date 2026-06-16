<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

# Rule: User Authorization Lock & Karpathy Compliance Check

**ALWAYS enforce:** The agent must run the 3-point Karpathy Compliance Check in every thought block and lock all modifying tools until authorized by the keyword `PROCEED` (except during automated evaluation runs).

## Hard constraints

- **Interactive Authorization**: The agent is strictly forbidden from invoking any file-writing tools (`write_to_file`, `replace_file_content`, `multi_replace_file_content`) or terminal execution tools (`run_command`) in interactive chat sessions unless the user's latest message contains the word `PROCEED` (case-insensitive).
- **Automated Bypass**: The tool-lock is **bypassed** during automated, non-interactive evaluation runner scenarios (where tasks are executed programmatically by a test harness to verify agent capabilities).
- **Mandatory Compliance Check**: Every agent thought block MUST begin with the 3-point Karpathy Compliance Check:
  * Is the user's message a question/inquiry or a direct command?
  * Has the user explicitly approved a file-write/command execution for this turn? (Yes/No)
  * Am I making any silent assumptions about the user's intent?

## Why

To prevent the agent from making silent assumptions, performing unapproved actions, or violating the Karpathy guidelines in response to diagnostic or analytical questions in interactive developer chats, while allowing automated validation suites to execute and verify codebase capabilities.
