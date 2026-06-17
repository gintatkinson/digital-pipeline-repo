# Copyright Gint Atkinson, gint.atkinson@gmail.com

#!/usr/bin/env python3
import os
import re
import subprocess
import json
import sys
import yaml

def load_codebase_rules(workspace_dir):
    rules_path = os.path.join(workspace_dir, ".pipeline", "logical-ui", "codebase_rules.json")
    if os.path.exists(rules_path):
        try:
            with open(rules_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"Warning: Failed to load codebase_rules.json: {e}")
    return {}

def normalize_title(title, rules=None):
    if not title:
        return ""
    # Strip quotes and leading/trailing whitespace
    title = title.strip().strip('"\'')
    # Strip common prefixes (e.g., epic-01:, feat-02:, us-03:, uc-04:, etc.)
    regex = None
    if rules:
        regex = rules.get("tracker_rules", {}).get("prefix_normalization_regex")
    if not regex:
        regex = r'^(epic|feat|us|uc|feature|user[- ]story|use[- ]case)[s]?(?:[- ]*\d+\s*[:\-]?|:)\s*'
    title = re.sub(regex, '', title, flags=re.IGNORECASE)
    # Normalize hyphens to spaces to handle typographic variations
    title = title.replace("-", " ")
    # Strip any remaining punctuation and normalize spacing
    title = re.sub(r'[^\w\s]', '', title)
    title = " ".join(title.split())
    return title.lower()

def extract_title(filepath):
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read(2048)  # Read first 2KB
        
        # Try finding title in YAML frontmatter
        title_match = re.search(r'^title:\s*(["\']?)(.*?)\1\s*$', content, re.MULTILINE)
        if title_match:
            return title_match.group(2).strip()
            
        # Fallback to # H1 title
        h1_match = re.search(r'^#\s+(.*?)$', content, re.MULTILINE)
        if h1_match:
            return h1_match.group(1).strip()
    except Exception as e:
        print(f"Error reading title from {filepath}: {e}")
    return None

def get_all_issues(rules=None):
    if not rules:
        raise ValueError("Configuration rules are missing.")
    tracker_rules = rules.get("tracker_rules")
    if not tracker_rules:
        raise ValueError("Missing 'tracker_rules' in codebase_rules.json")
    provider = tracker_rules.get("provider")
    if not provider:
        raise ValueError("Missing 'tracker_rules.provider' in codebase_rules.json")
    commands = tracker_rules.get("commands")
    if not commands or "list_issues" not in commands:
        raise ValueError("Missing 'tracker_rules.commands.list_issues' in codebase_rules.json")
    
    print(f"Fetching active and closed issues from tracker provider '{provider}'...")
    cmd = commands["list_issues"]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise Exception(f"Failed to fetch issues: {res.stderr.strip()}")
    return json.loads(res.stdout)

def update_checklist_in_file(filepath, issue_dict, rules=None):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Match both checked and unchecked boxes: e.g., - [ ] #123 or - [x] #123 or - [ ] #PROJ-123
    pattern = r"(-\s*\[\s*([ xX])\s*\]\s*(?:#|#\[|\#\s*)([A-Za-z0-9\-]+))"
    
    updated_content = content
    all_deps_closed = True
    has_deps = False
    
    tracker_rules = rules.get("tracker_rules", {}) if rules else {}
    keys = tracker_rules.get("keys", {})
    state_key = keys.get("state", "state")
    closed_state = keys.get("closed_state_value", "CLOSED").upper()
    
    matches = re.findall(pattern, content)
    for full_match, mark, dep_num_str in matches:
        has_deps = True
        dep_num = int(dep_num_str) if dep_num_str.isdigit() else dep_num_str
        dep_issue = issue_dict.get(dep_num)
        
        if dep_issue is None:
            print(f"Error: Invalid/hallucinated dependency reference #{dep_num} in {os.path.basename(filepath)}")
            upstream_repo = rules.get("meta", {}).get("upstream_repository", "unknown") if rules else "unknown"
            troubleshooting = rules.get("meta", {}).get("troubleshooting_instruction", "Please report this issue to upstream repository {upstream_repo}") if rules else "Report to {upstream_repo}"
            print(f"\n[!] {troubleshooting.format(upstream_repo=upstream_repo)}")
            sys.exit(1)
            
        is_closed = (str(dep_issue[state_key]).upper() == closed_state)
        target_mark = 'x' if is_closed else ' '
        
        if mark != target_mark:
            # Replace the specific checkbox character
            old_box = f"[{mark}]"
            new_box = f"[{target_mark}]"
            updated_content = updated_content.replace(full_match, full_match.replace(old_box, new_box, 1), 1)
            print(f"  [Checklist] Updated dependency #{dep_num} to [{target_mark}] in {os.path.basename(filepath)}")
            
        if not is_closed:
            all_deps_closed = False

    if updated_content != content:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(updated_content)
            
    return updated_content, (has_deps and all_deps_closed)

def convert_frontmatter_to_table(content):
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
    if not match:
        return content
    
    frontmatter_text = match.group(1)
    body_text = content[match.end():]
    
    try:
        data = yaml.safe_load(frontmatter_text)
        if not isinstance(data, dict):
            return content
    except Exception as e:
        print(f"Error parsing frontmatter YAML: {e}")
        return content
    
    table_lines = [
        "| Metadata | Value |",
        "| --- | --- |"
    ]
    
    for key, value in data.items():
        if isinstance(value, list):
            val = ", ".join(str(item) for item in value)
        elif value is None:
            val = ""
        else:
            val = str(value)
        table_lines.append(f"| **{key}** | {val} |")
        
    table_text = "\n".join(table_lines) + "\n\n"
    return table_text + body_text

def sync_issue_body_to_tracker(issue_num, filepath, issue_type="Feature", rules=None):
    print(f"  [Sync Issue Body] Syncing #{issue_num} ({issue_type}) to tracker...")
    
    # Check issue body size limit and truncate if needed
    temp_path = filepath + ".temp-body"
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            
        val_rules = rules.get("validation_rules", {}) if rules else {}
        max_body_chars = val_rules.get("max_body_characters", 65536)
        trunc_limit = max_body_chars - 5536
        
        if len(content) > trunc_limit:
            # Add a message pointing to the repository file
            tracker_rules = rules.get("tracker_rules", {}) if rules else {}
            truncation_headers = tracker_rules.get("truncation_headers", ["## Acceptance Criteria", "## User Stories"])
            trunc_index = -1
            for header in truncation_headers:
                trunc_index = content.find(header)
                if trunc_index != -1:
                    break
            if trunc_index == -1:
                trunc_index = trunc_limit
            
            project_root = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
            rel_path = os.path.relpath(filepath, project_root)
            
            content = content[:trunc_index] + (
                f"\n\n---\n> [!NOTE]\n"
                f"> This issue body has been truncated because it exceeds tracker size limit of {max_body_chars} characters.\n"
                f"> Please refer to the full specification file in the repository at `{rel_path}` for the complete details.\n"
            )
            
        with open(temp_path, "w", encoding="utf-8") as tf:
            tf.write(content)
        
        tracker_rules = rules.get("tracker_rules", {}) if rules else {}
        edit_cmd_template = tracker_rules.get("commands", {}).get("edit_issue")
        if not edit_cmd_template:
            raise ValueError("Missing 'tracker_rules.commands.edit_issue' in codebase_rules.json")
        cmd = [str(issue_num) if c == "{number}" else (temp_path if c == "{temp_path}" else c) for c in edit_cmd_template]
        subprocess.run(cmd, check=True, capture_output=True)
    except Exception as e:
        print(f"  [Error] Failed to sync #{issue_num} body: {e}")
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)
 
def close_issue_on_tracker(issue_num, comment, rules=None):
    print(f"  [Close Issue] Closing issue #{issue_num} on tracker...")
    try:
        tracker_rules = rules.get("tracker_rules", {}) if rules else {}
        close_cmd_template = tracker_rules.get("commands", {}).get("close_issue")
        if not close_cmd_template:
            raise ValueError("Missing 'tracker_rules.commands.close_issue' in codebase_rules.json")
        cmd = [str(issue_num) if c == "{number}" else (comment if c == "{comment}" else c) for c in close_cmd_template]
        subprocess.run(cmd, check=True, capture_output=True)
    except Exception as e:
        print(f"  [Error] Failed to close issue #{issue_num}: {e}")

def resolve_issue_ids_in_file(filepath, combined_titles, rules=None):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
        
    tracker_rules = rules.get("tracker_rules", {}) if rules else {}
    placeholder = tracker_rules.get("issue_id_placeholder", "#[IssueID]")
    title_extraction_prefixes_regex = tracker_rules.get("title_extraction_prefixes_regex", r"(?:Feature\s+\d+\s*:\s*|Use\s+Case\s+\d+\s*:\s*|User\s+Story\s+\d+\s*:\s*)?")
    
    if placeholder not in content:
        return content
        
    lines = content.splitlines()
    updated = False
    
    # Escape placeholder for safe regex search
    escaped_placeholder = re.escape(placeholder)
    
    for i, line in enumerate(lines):
        if placeholder not in line:
            continue
            
        title = None
        link_label_match = re.search(r'\[([^\]]+)\]\(', line)
        if link_label_match:
            title = link_label_match.group(1).strip()
        else:
            pattern = r'-\s*\[[ xX]\]\s*' + escaped_placeholder + r'\s*-\s*' + title_extraction_prefixes_regex + r'(.*)$'
            dash_match = re.search(pattern, line)
            if dash_match:
                title = dash_match.group(1).strip()
                title = re.sub(r'\(.*?\)', '', title).strip()
                title = title.strip('[]-* ')
                
        if title:
            norm = normalize_title(title, rules)
            issue_num = combined_titles.get(norm)
            if issue_num:
                lines[i] = line.replace(placeholder, f"#{issue_num}")
                updated = True
                print(f"  [Resolve ID] Resolved {placeholder} to #{issue_num} for '{title}' in {os.path.basename(filepath)}")
            else:
                print(f"  [Warning] Could not resolve {placeholder} for title '{title}' in {os.path.basename(filepath)}")
                
    if updated:
        new_content = "\n".join(lines) + "\n"
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(new_content)
        return new_content
        
    return content

def main():
    # Locate the workspace directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    workspace_dir = os.path.abspath(os.path.join(script_dir, "..", "..", ".."))

    # Load codebase rules
    rules = load_codebase_rules(workspace_dir)
    if not rules:
        raise ValueError("codebase_rules.json is empty or could not be loaded")

    # Verify tracker/CLI authentication
    try:
        issues = get_all_issues(rules)
    except Exception as e:
        print(f"Error fetching issues: {e}")
        print("Please ensure issue tracker CLI is authenticated and configured.")
        sys.exit(1)

    tracker_rules = rules.get("tracker_rules", {}) if rules else {}
    keys = tracker_rules.get("keys", {})
    id_key = keys.get("issue_id", "number")
    title_key = keys.get("title", "title")
    labels_key = keys.get("labels", "labels")

    # Convert to issue lookup dictionary by issue identifier
    issue_dict = {}
    for issue in issues:
        raw_id = issue[id_key]
        issue_dict[raw_id] = issue
        if isinstance(raw_id, str) and raw_id.isdigit():
            issue_dict[int(raw_id)] = issue
        elif isinstance(raw_id, int):
            issue_dict[str(raw_id)] = issue

    # Map normalized titles to issue numbers, segregated by labels
    epic_titles = {}
    story_titles = {}
    usecase_titles = {}
    feature_titles = {}

    labels_config = tracker_rules.get("labels", {})
    epic_label = labels_config.get("epic", "epic").lower()
    story_label = labels_config.get("user_story", "user-story").lower()
    usecase_label = labels_config.get("use_case", "use-case").lower()
    feature_label = labels_config.get("feature", "feature").lower()

    for num, issue in issue_dict.items():
        # Map raw issue keys correctly to prevent duplicate lookups
        if isinstance(num, str) and num.isdigit() and int(num) in epic_titles:
            continue
        norm_title = normalize_title(issue[title_key], rules)
        labels = []
        for l in issue.get(labels_key, []):
            if isinstance(l, dict):
                labels.append(l.get("name", "").lower())
            elif isinstance(l, str):
                labels.append(l.lower())
        
        if epic_label in labels:
            epic_titles[norm_title] = num
        elif story_label in labels:
            story_titles[norm_title] = num
        elif usecase_label in labels:
            usecase_titles[norm_title] = num
        elif feature_label in labels:
            feature_titles[norm_title] = num

    combined_titles = {}
    combined_titles.update(epic_titles)
    combined_titles.update(feature_titles)
    combined_titles.update(story_titles)
    combined_titles.update(usecase_titles)
        
    backlog_dirs = rules.get("backlog_directories")
    if not backlog_dirs:
        raise ValueError("Missing 'backlog_directories' in codebase_rules.json")
        
    epics_rel = backlog_dirs.get("epics")
    features_rel = backlog_dirs.get("features")
    stories_rel = backlog_dirs.get("user_stories")
    usecases_rel = backlog_dirs.get("use_cases")
    
    if not all([epics_rel, features_rel, stories_rel, usecases_rel]):
        raise ValueError("Missing epic, features, user_stories, or use_cases path in backlog_directories configuration")
        
    upstream_repo = rules.get("meta", {}).get("upstream_repository")
    if not upstream_repo:
        raise ValueError("Missing 'meta.upstream_repository' in codebase_rules.json")

    if len(sys.argv) > 1:
        docs_dir = os.path.abspath(sys.argv[1])
        epics_dir = os.path.join(docs_dir, os.path.basename(epics_rel))
        features_dir = os.path.join(docs_dir, os.path.basename(features_rel))
        stories_dir = os.path.join(docs_dir, os.path.basename(stories_rel))
        usecases_dir = os.path.join(docs_dir, os.path.basename(usecases_rel))
        print(f"Scanning backlog files in {docs_dir}...")
    else:
        epics_dir = os.path.join(workspace_dir, epics_rel)
        features_dir = os.path.join(workspace_dir, features_rel)
        stories_dir = os.path.join(workspace_dir, stories_rel)
        usecases_dir = os.path.join(workspace_dir, usecases_rel)
        print(f"Scanning backlog files...")

    # Process Epics
    if os.path.exists(epics_dir):
        for filename in sorted(os.listdir(epics_dir)):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(epics_dir, filename)
            resolve_issue_ids_in_file(filepath, combined_titles, rules=rules)
            title = extract_title(filepath)
            if not title:
                continue
            
            norm = normalize_title(title, rules=rules)
            issue_num = epic_titles.get(norm)
            if issue_num:
                updated_content, completed = update_checklist_in_file(filepath, issue_dict, rules)
                is_open = str(issue_dict[issue_num][state_key]).upper() == keys.get("open_state_value", "OPEN").upper()
                if is_open:
                    # Sync to keep checkbox states updated on tracker UI
                    sync_issue_body_to_tracker(issue_num, filepath, issue_type="Epic", rules=rules)
                    if completed:
                        close_issue_on_tracker(
                            issue_num, 
                            "Epic completed. All constituent features successfully delivered and verified.",
                            rules=rules
                        )
                        issue_dict[issue_num][state_key] = closed_state
            else:
                print(f"Warning: No Epic issue found on tracker matching: '{title}'")

    # Process Features
    if os.path.exists(features_dir):
        for filename in sorted(os.listdir(features_dir)):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(features_dir, filename)
            resolve_issue_ids_in_file(filepath, combined_titles, rules=rules)
            title = extract_title(filepath)
            if not title:
                continue
            
            norm = normalize_title(title, rules=rules)
            issue_num = feature_titles.get(norm)
            if issue_num:
                is_open = str(issue_dict[issue_num][state_key]).upper() == keys.get("open_state_value", "OPEN").upper()
                if is_open:
                    # Sync to keep feature definition/acceptance criteria updated on tracker UI
                    sync_issue_body_to_tracker(issue_num, filepath, issue_type="Feature", rules=rules)
            else:
                print(f"Warning: No Feature issue found on tracker matching: '{title}'")

    # Process User Stories
    if os.path.exists(stories_dir):
        for filename in sorted(os.listdir(stories_dir)):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(stories_dir, filename)
            resolve_issue_ids_in_file(filepath, combined_titles, rules=rules)
            title = extract_title(filepath)
            if not title:
                continue
            
            norm = normalize_title(title, rules=rules)
            issue_num = story_titles.get(norm)
            if issue_num:
                _, completed = update_checklist_in_file(filepath, issue_dict, rules)
                is_open = str(issue_dict[issue_num][state_key]).upper() == keys.get("open_state_value", "OPEN").upper()
                if is_open:
                    sync_issue_body_to_tracker(issue_num, filepath, issue_type="User Story", rules=rules)
                    if completed:
                        close_issue_on_tracker(
                            issue_num,
                            f"Resolved. All dependent features/tasks for BDD scenario '{title}' have been completed and verified.",
                            rules=rules
                        )
                        issue_dict[issue_num][state_key] = closed_state
            else:
                print(f"Warning: No User Story issue found on tracker matching: '{title}'")

    # Process Use Cases
    if os.path.exists(usecases_dir):
        for filename in sorted(os.listdir(usecases_dir)):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(usecases_dir, filename)
            resolve_issue_ids_in_file(filepath, combined_titles, rules=rules)
            title = extract_title(filepath)
            if not title:
                continue
            
            norm = normalize_title(title, rules=rules)
            issue_num = usecase_titles.get(norm)
            if issue_num:
                _, completed = update_checklist_in_file(filepath, issue_dict, rules)
                is_open = str(issue_dict[issue_num][state_key]).upper() == keys.get("open_state_value", "OPEN").upper()
                if is_open:
                    sync_issue_body_to_tracker(issue_num, filepath, issue_type="Use Case", rules=rules)
                    if completed:
                        close_issue_on_tracker(
                            issue_num,
                            f"Resolved. All dependent user stories and features for use case '{title}' are completed.",
                            rules=rules
                        )
                        issue_dict[issue_num][state_key] = closed_state
            else:
                print(f"Warning: No Use Case issue found on tracker matching: '{title}'")

    print("Backlog reconciliation complete.")

if __name__ == "__main__":
    main()
