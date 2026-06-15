# Copyright Gint Atkinson, gint.atkinson@gmail.com

#!/usr/bin/env python3
import os
import re
import subprocess
import json
import sys
import yaml

def normalize_title(title):
    if not title:
        return ""
    # Strip quotes and leading/trailing whitespace
    title = title.strip().strip('"\'')
    # Strip common prefixes (e.g., epic-01:, feat-02:, us-03:, uc-04:, etc.)
    title = re.sub(r'^(epic|feat|us|uc|feature|user[- ]story|use[- ]case)[s]?(?:[- ]*\d+\s*[:\-]?|:)\s*', '', title, flags=re.IGNORECASE)
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

def get_all_issues():
    print("Fetching active and closed issues from GitHub...")
    # Fetch up to 1000 issues covering all states
    cmd = ["gh", "issue", "list", "--limit", "1000", "--state", "all", "--json", "number,title,state,labels"]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise Exception(f"Failed to fetch issues: {res.stderr.strip()}")
    return json.loads(res.stdout)

def update_checklist_in_file(filepath, issue_dict):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Match both checked and unchecked boxes: e.g., - [ ] #123 or - [x] #123
    pattern = r"(-\s*\[\s*([ xX])\s*\]\s*(?:#|#\[|\#\s*)(\d+))"
    
    updated_content = content
    all_deps_closed = True
    has_deps = False
    
    matches = re.findall(pattern, content)
    for full_match, mark, dep_num_str in matches:
        has_deps = True
        dep_num = int(dep_num_str)
        dep_issue = issue_dict.get(dep_num)
        
        if dep_issue is None:
            print(f"Error: Invalid/hallucinated dependency reference #{dep_num} in {os.path.basename(filepath)}")
            sys.exit(1)
            
        is_closed = (dep_issue["state"].upper() == "CLOSED")
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

def sync_issue_body_to_github(issue_num, filepath, issue_type="Issue"):
    print(f"  [{issue_type} Sync] Syncing #{issue_num} body to GitHub...")
    temp_path = filepath + ".tmp_body"
    try:
        with open(filepath, "r", encoding="utf-8") as sf:
            content = sf.read()
        
        # Convert YAML frontmatter to a Markdown table for GitHub issue body
        content = convert_frontmatter_to_table(content)
        
        # Prevent GraphQL: Body is too long (updateIssue) errors (limit is 65536 characters)
        if len(content) > 60000:
            trunc_index = content.rfind("\n", 0, 60000)
            if trunc_index == -1:
                trunc_index = 60000
            
            project_root = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
            rel_path = os.path.relpath(filepath, project_root)
            
            content = content[:trunc_index] + (
                f"\n\n---\n> [!NOTE]\n"
                f"> This issue body has been truncated because it exceeds GitHub's size limit of 65,536 characters.\n"
                f"> Please refer to the full specification file in the repository at `{rel_path}` for the complete details (such as exhaustive auto-generated schema tables).\n"
            )
            
        with open(temp_path, "w", encoding="utf-8") as tf:
            tf.write(content)
        
        subprocess.run(["gh", "issue", "edit", str(issue_num), "--body-file", temp_path], check=True, capture_output=True)
    except Exception as e:
        print(f"  [Error] Failed to sync #{issue_num} body: {e}")
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

def close_issue_on_github(issue_num, comment):
    print(f"  [Close Issue] Closing issue #{issue_num} on GitHub...")
    try:
        subprocess.run(["gh", "issue", "close", str(issue_num), "--comment", comment], check=True, capture_output=True)
    except Exception as e:
        print(f"  [Error] Failed to close issue #{issue_num}: {e}")

def main():
    # Verify GitHub CLI authentication
    try:
        issues = get_all_issues()
    except Exception as e:
        print(f"Error fetching GitHub issues: {e}")
        print("Please ensure gh CLI is authenticated and configured.")
        sys.exit(1)

    # Convert to issue lookup dictionary by issue number
    issue_dict = {issue["number"]: issue for issue in issues}

    # Map normalized titles to issue numbers, segregated by labels
    epic_titles = {}
    story_titles = {}
    usecase_titles = {}
    feature_titles = {}

    for num, issue in issue_dict.items():
        norm_title = normalize_title(issue["title"])
        labels = [l["name"].lower() for l in issue.get("labels", [])]
        
        if "epic" in labels:
            epic_titles[norm_title] = num
        elif "user-story" in labels:
            story_titles[norm_title] = num
        elif "use-case" in labels:
            usecase_titles[norm_title] = num
        elif "feature" in labels:
            feature_titles[norm_title] = num

    # Locate the docs directory
    if len(sys.argv) > 1:
        docs_dir = os.path.abspath(sys.argv[1])
    else:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        docs_dir = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "docs"))
    if not os.path.exists(docs_dir):
        print(f"Docs directory not found at: {docs_dir}")
        sys.exit(1)

    print(f"Scanning backlog files in {docs_dir}...")

    # Process Epics
    epics_dir = os.path.join(docs_dir, "epics")
    if os.path.exists(epics_dir):
        for filename in sorted(os.listdir(epics_dir)):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(epics_dir, filename)
            title = extract_title(filepath)
            if not title:
                continue
            
            norm = normalize_title(title)
            issue_num = epic_titles.get(norm)
            if issue_num:
                updated_content, completed = update_checklist_in_file(filepath, issue_dict)
                is_open = issue_dict[issue_num]["state"].upper() == "OPEN"
                if is_open:
                    # Sync to keep checkbox states updated on GitHub UI
                    sync_issue_body_to_github(issue_num, filepath, issue_type="Epic")
                    if completed:
                        close_issue_on_github(
                            issue_num, 
                            "Epic completed. All constituent features successfully delivered and verified."
                        )
                        issue_dict[issue_num]["state"] = "CLOSED"
            else:
                print(f"Warning: No GitHub Epic issue found matching: '{title}'")

    # Process Features
    features_dir = os.path.join(docs_dir, "features")
    if os.path.exists(features_dir):
        for filename in sorted(os.listdir(features_dir)):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(features_dir, filename)
            title = extract_title(filepath)
            if not title:
                continue
            
            norm = normalize_title(title)
            issue_num = feature_titles.get(norm)
            if issue_num:
                is_open = issue_dict[issue_num]["state"].upper() == "OPEN"
                if is_open:
                    # Sync to keep feature definition/acceptance criteria updated on GitHub UI
                    sync_issue_body_to_github(issue_num, filepath, issue_type="Feature")
            else:
                print(f"Warning: No GitHub Feature issue found matching: '{title}'")

    # Process User Stories
    stories_dir = os.path.join(docs_dir, "user-stories")
    if os.path.exists(stories_dir):
        for filename in sorted(os.listdir(stories_dir)):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(stories_dir, filename)
            title = extract_title(filepath)
            if not title:
                continue
            
            norm = normalize_title(title)
            issue_num = story_titles.get(norm)
            if issue_num:
                _, completed = update_checklist_in_file(filepath, issue_dict)
                is_open = issue_dict[issue_num]["state"].upper() == "OPEN"
                if is_open:
                    sync_issue_body_to_github(issue_num, filepath, issue_type="User Story")
                    if completed:
                        close_issue_on_github(
                            issue_num,
                            f"Resolved. All dependent features/tasks for BDD scenario '{title}' have been completed and verified."
                        )
                        issue_dict[issue_num]["state"] = "CLOSED"
            else:
                print(f"Warning: No GitHub User Story issue found matching: '{title}'")

    # Process Use Cases
    usecases_dir = os.path.join(docs_dir, "use-cases")
    if os.path.exists(usecases_dir):
        for filename in sorted(os.listdir(usecases_dir)):
            if not filename.endswith(".md"):
                continue
            filepath = os.path.join(usecases_dir, filename)
            title = extract_title(filepath)
            if not title:
                continue
            
            norm = normalize_title(title)
            issue_num = usecase_titles.get(norm)
            if issue_num:
                _, completed = update_checklist_in_file(filepath, issue_dict)
                is_open = issue_dict[issue_num]["state"].upper() == "OPEN"
                if is_open:
                    sync_issue_body_to_github(issue_num, filepath, issue_type="Use Case")
                    if completed:
                        close_issue_on_github(
                            issue_num,
                            f"Resolved. All dependent user stories and features for use case '{title}' are completed."
                        )
                        issue_dict[issue_num]["state"] = "CLOSED"
            else:
                print(f"Warning: No GitHub Use Case issue found matching: '{title}'")

    print("Backlog reconciliation complete.")

if __name__ == "__main__":
    main()
