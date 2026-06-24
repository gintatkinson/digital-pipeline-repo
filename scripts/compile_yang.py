import sys
import json
import os
import re
from pyang.context import Context
from pyang.repository import FileRepository

def parse_yang_to_json(yang_file_path, json_file_path):
    # Setup context
    repo = FileRepository()
    ctx = Context(repo)

    # Read YANG content
    with open(yang_file_path, 'r') as f:
        text = f.read()

    # Parse module
    module = ctx.add_module(yang_file_path, text)
    if not module:
        print("Failed to parse YANG module.")
        sys.exit(1)

    # Validate the module
    ctx.validate()

    # Walk the tree to find leaf nodes and construct AttributeDefinitions
    attributes = []

    def get_child_stmt(stmt, keyword):
        for s in stmt.substmts:
            if s.keyword == keyword:
                return s
        return None

    def get_all_children(stmt, keyword):
        return [s for s in stmt.substmts if s.keyword == keyword]

    def parse_range(range_str):
        # range can be in the form "68..9216" or single value, etc.
        # We want to extract min and max values.
        match = re.match(r'^\s*([0-9\-+\.]+)\s*\.\.\s*([0-9\-+\.]+)\s*$', range_str)
        if match:
            try:
                return int(match.group(1)), int(match.group(2))
            except ValueError:
                try:
                    return float(match.group(1)), float(match.group(2))
                except ValueError:
                    pass
        else:
            # Maybe single value
            try:
                val = int(range_str.strip())
                return val, val
            except ValueError:
                try:
                    val = float(range_str.strip())
                    return val, val
                except ValueError:
                    pass
        return None, None

    def walk(stmt, path_parts, parent_group=None):
        keyword = stmt.keyword
        name = stmt.arg

        # Determine path and group
        new_path_parts = list(path_parts)
        if keyword in ('container', 'list', 'leaf', 'leaf-list'):
            new_path_parts.append(name)
            new_parent_group = name
        else:
            new_parent_group = parent_group

        if keyword == 'leaf':
            # Extract attributes for this leaf
            key_path = "/".join(new_path_parts)
            
            # Find description
            desc_stmt = get_child_stmt(stmt, 'description')
            label = desc_stmt.arg if desc_stmt else name

            # Find type
            type_stmt = get_child_stmt(stmt, 'type')
            yang_type = type_stmt.arg if type_stmt else 'string'
            
            # Map type
            if yang_type in ('int8', 'int16', 'int32', 'int64', 'uint8', 'uint16', 'uint32', 'uint64', 'decimal64'):
                mapped_type = 'int'
            elif yang_type == 'string':
                mapped_type = 'string'
            elif yang_type == 'enumeration':
                mapped_type = 'enumeration'
            else:
                mapped_type = yang_type

            # Check if mandatory
            mandatory_stmt = get_child_stmt(stmt, 'mandatory')
            is_required = True if (mandatory_stmt and mandatory_stmt.arg == 'true') else False

            attr = {
                "key": key_path,
                "label": label,
                "type": mapped_type,
                "sectionGroup": parent_group,
                "isRequired": is_required
            }

            # Extract options if type is enumeration
            if yang_type == 'enumeration' and type_stmt:
                enum_stmts = get_all_children(type_stmt, 'enum')
                options = [e.arg for e in enum_stmts]
                attr["options"] = options

            # Extract ranges if numerical
            if type_stmt:
                range_stmt = get_child_stmt(type_stmt, 'range')
                if range_stmt:
                    min_val, max_val = parse_range(range_stmt.arg)
                    if min_val is not None:
                        attr["minValue"] = min_val
                    if max_val is not None:
                        attr["maxValue"] = max_val

            attributes.append(attr)
            return

        # Recursively walk sub-statements
        for substmt in stmt.substmts:
            walk(substmt, new_path_parts, new_parent_group)

    # Walk from the module level
    for substmt in module.substmts:
        walk(substmt, [], None)

    # Load existing JSON layout file or fallback to .pipeline/logical-ui/logical-layout.json
    layout_data = None
    if os.path.exists(json_file_path):
        try:
            with open(json_file_path, 'r') as f:
                layout_data = json.load(f)
                if not isinstance(layout_data, dict):
                    layout_data = None
        except Exception:
            layout_data = None

    if layout_data is None:
        fallback_paths = [
            os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), '.pipeline', 'logical-ui', 'logical-layout.json'),
            '.pipeline/logical-ui/logical-layout.json'
        ]
        for fp in fallback_paths:
            if os.path.exists(fp):
                try:
                    with open(fp, 'r') as f:
                        loaded = json.load(f)
                        if isinstance(loaded, dict):
                            layout_data = loaded
                            break
                except Exception:
                    pass

    if layout_data is None:
        layout_data = {}

    layout_data["attributes"] = attributes

    # Write output to json_file_path
    os.makedirs(os.path.dirname(json_file_path), exist_ok=True)
    with open(json_file_path, 'w') as f:
        json.dump(layout_data, f, indent=2)

    print(f"Successfully compiled YANG schema and merged into {json_file_path}")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python compile_yang.py <input_yang_path> <output_json_path>")
        sys.exit(1)
    parse_yang_to_json(sys.argv[1], sys.argv[2])
