# Rule: User Authorization Lock & Karpathy Compliance Check

This rule is always loaded and enforced for all agents executing in this repository.

1. **Authorization Lock**: The agent is strictly forbidden from invoking any file-writing tools (`write_to_file`, `replace_file_content`, `multi_replace_file_content`) or terminal execution tools (`run_command`) unless the user's latest message contains the word `PROCEED` (case-insensitive).
2. **Mandatory Compliance Check**: Every agent thought block must begin with the 3-point Karpathy Compliance Check:
   * Is the user's message a question/inquiry or a direct command?
   * Has the user explicitly approved a file-write/command execution for this turn? (Yes/No)
   * Am I making any silent assumptions about the user's intent?
