import re
import sys
import os
import pytest
from typing import List

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from parity_auditor.utils.comment_utils import strip_c_style_comments

common_words = { "id", "name", "type", "status", "value", "height", "width", "time", "x", "y", "z", "t", "date", "info", "data", "key", "code", "save", "edit", "view", "vector" }

def is_present_in_codebase(v: str, codebase: List[str]) -> bool:
    v_escaped = re.escape(v)
    if v.lower() not in common_words:
        return any(re.search(r'\b' + v_escaped + r'\b', strip_c_style_comments(content)) for content in codebase)

    patterns = [
        r'\.\s*' + v_escaped + r'\b',
        r'\bthis\s*\.\s*' + v_escaped + r'\b',
        r'\b[a-zA-Z_][a-zA-Z0-9_<>\s]*\s+' + v_escaped + r'\b',
        r'\b' + v_escaped + r'\s*:',
        r'\bconst\s*\{\s*[^}]*\b' + v_escaped + r'\b[^}]*\}\s*=',
        r'\blet\s*\{\s*[^}]*\b' + v_escaped + r'\b[^}]*\}\s*=',
    ]
    return any(any(re.search(pat, strip_c_style_comments(content)) for pat in patterns) for content in codebase)


class TestIsPresentInCodebase:

    def test_non_common_word_matches_in_code_not_comment(self):
        """A non-common property name in actual code should be found."""
        code = ["const widget = new MyWidget();\nwidget.userId = 123;"]
        assert is_present_in_codebase("userId", code) is True

    def test_non_common_word_only_in_comment_returns_false(self):
        """A non-common property name only in a comment should NOT be found."""
        code = ["// This component uses the userId field from the API response\nconst widget = new MyWidget();"]
        assert is_present_in_codebase("userId", code) is False, (
            "userId appearing only in a comment was incorrectly matched as present in codebase"
        )

    def test_non_common_word_only_in_block_comment_returns_false(self):
        """A non-common property name only in a block comment should NOT be found."""
        code = ["/*\n * The userId is derived from the session token.\n */\nconst widget = new MyWidget();"]
        assert is_present_in_codebase("userId", code) is False, (
            "userId appearing only in a block comment was incorrectly matched"
        )

    def test_non_common_word_only_in_string_currently_matches(self):
        """String literal false positive is a separate issue from comment matching."""
        code = ["const label = 'userId';"]
        result = is_present_in_codebase("userId", code)
        assert result is True

    def test_common_word_in_comment_not_matched_as_code(self):
        """Common word 'id' in a line comment should not be matched with strict patterns."""
        code = ["// Assign a unique id to each item\nconst item = new Item();\nitem.id = generateId();"]
        result = is_present_in_codebase("id", code)
        assert result is True, (
            "id is used in real code (item.id), so it should be found"
        )

    def test_common_word_only_in_comment_returns_false(self):
        """Common word 'id' only in a comment should NOT be matched."""
        code = ["// The record id is important for tracking\nfunction process() {\n  return true;\n}"]
        result = is_present_in_codebase("id", code)
        assert result is False, (
            "id appearing only in a comment was incorrectly matched as present in codebase"
        )

    def test_common_word_in_block_comment_only_returns_false(self):
        """Common word 'name' only in a block comment should NOT be matched."""
        code = ["/*\n * The component name is derived from metadata.\n */\nfunction render() {\n  return <div />;\n}"]
        result = is_present_in_codebase("name", code)
        assert result is False, (
            "name appearing only in a block comment was incorrectly matched"
        )

    def test_common_word_in_actual_code_matches(self):
        """Common word 'name' used as property in code should be found."""
        code = ["class User {\n  String name;\n  User(this.name);\n}"]
        result = is_present_in_codebase("name", code)
        assert result is True, (
            "name used as a real code declaration should be found"
        )
