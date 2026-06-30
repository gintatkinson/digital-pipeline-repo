#!/usr/bin/env python3
import os
import re
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DENYLIST_FILE = os.path.join(BASE_DIR, "config", "domain_denylist.txt")
SCAN_DIRS = ["app_flutter/lib", "web_react/src", "scripts"]
SKIP_DIRS = {".git", "node_modules", "build", ".dart_tool", "__pycache__"}
# Config files are the authorized source of truth — skip them
SKIP_FILES = {"app_config.dart", "app_config.ts"}
EXTENSIONS = {".dart", ".ts", ".tsx", ".py", ".yaml"}


def load_denylist(path):
    terms = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            term = line.strip()
            if term:
                terms.append(term)
    return terms


def make_regex_patterns(ext):
    patterns = [
        r"'(?:[^'\\]|\\.)*'",
        r'"(?:[^"\\]|\\.)*"',
        r'`(?:[^`\\]|\\.)*`',
        r'/\*[\s\S]*?\*/',
        r'//[^\n]*',
    ]
    if ext == ".py":
        patterns.extend([
            r'"""[\s\S]*?"""',
            r"'''[\s\S]*?'''",
            r'#[^\n]*',
        ])
    elif ext == ".yaml":
        patterns.append(r'#[^\n]*')
    return patterns


def strip_delimiters(text):
    if len(text) < 2:
        return text
    if text[:3] == "'''" and text[-3:] == "'''":
        return text[3:-3]
    if text[:3] == '"""' and text[-3:] == '"""':
        return text[3:-3]
    if text[:2] == "//" or text[:2] == "/*":
        return text[2:] if text[:2] == "//" else text[2:-2]
    if text[0] == "#":
        return text[1:]
    if len(text) >= 2 and text[0] in ("'", '"', "`") and text[0] == text[-1]:
        return text[1:-1]
    return text


def extract_substrings(filepath, content):
    patterns = make_regex_patterns(os.path.splitext(filepath)[1])
    combined = re.compile("|".join(f"(?:{p})" for p in patterns))
    for match in combined.finditer(content):
        yield match.start(), match.group(0)


def scan_file(filepath, denylist_lower, denylist_terms):
    matches = []
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except Exception:
        return matches

    for start_idx, substring in extract_substrings(filepath, content):
        stripped = strip_delimiters(substring)
        stripped_lower = stripped.lower()
        for term, term_lower in zip(denylist_terms, denylist_lower):
            if term_lower not in stripped_lower:
                continue
            line_num = content[:start_idx].count("\n") + 1
            col_num = start_idx - content.rfind("\n", 0, start_idx)
            if col_num <= 0:
                col_num = start_idx + 1 - content.rfind("\n", 0, max(start_idx - 1, 0))
            matches.append((line_num, col_num, term))
    return matches


def main():
    if not os.path.isfile(DENYLIST_FILE):
        print(f"Error: denylist file not found at {DENYLIST_FILE}", file=sys.stderr)
        sys.exit(1)

    denylist_terms = load_denylist(DENYLIST_FILE)
    denylist_lower = [t.lower() for t in denylist_terms]

    all_matches = []
    for scan_dir in SCAN_DIRS:
        scan_path = os.path.join(BASE_DIR, scan_dir)
        if not os.path.isdir(scan_path):
            continue
        for root, dirs, files in os.walk(scan_path):
            dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
            for fname in files:
                ext = os.path.splitext(fname)[1]
                if ext not in EXTENSIONS:
                    continue
                fpath = os.path.join(root, fname)
                if fname in SKIP_FILES:
                    continue
                matches = scan_file(fpath, denylist_lower, denylist_terms)
                for line_num, col_num, term in matches:
                    rel = os.path.relpath(fpath, BASE_DIR)
                    all_matches.append((rel, line_num, col_num, term))

    for rel, line_num, col_num, term in all_matches:
        print(f"{rel}:{line_num}:{col_num}: {term}")

    if all_matches:
        sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
