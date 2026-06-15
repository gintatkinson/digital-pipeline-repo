# Copyright Gint Atkinson, gint.atkinson@gmail.com

#!/usr/bin/env python3
import os
import re
import sys
import json

def parse_lifeline_label(label):
    if not label:
        return None, None
    if ':' in label:
        parts = label.split(':', 1)
        return parts[0].strip(), parts[1].strip()
    return label.strip(), None

def extract_guard(guard_str):
    guard_str = guard_str.strip()
    if guard_str.startswith('[') and guard_str.endswith(']'):
        return guard_str[1:-1].strip()
    return guard_str

def extract_node_from_part(part):
    part = part.strip()
    pattern = r'^([a-zA-Z0-9_\-.:]+)\s*(\(\[|\[\(|\(\(|\[\[|\{\{|\[\/|\[\\|\[|\(|>|\{)\s*(?:\"([^\"]*)\"|([^\"]*?))\s*(\]\)|\)\]|\)\)|\]\]|\}\}|\/\]|\\\]|\]|\)|\})$'
    match = re.match(pattern, part)
    if match:
        node_id = match.group(1)
        open_bracket = match.group(2)
        label = match.group(3) if match.group(3) is not None else match.group(4)
        if label:
            label = label.strip()
        shape_map = {
            '([': 'stadium',
            '[(': 'database',
            '((': 'circle',
            '[[': 'subroutine',
            '{{': 'hexagon',
            '[/': 'parallelogram',
            '[\\': 'parallelogram_alt',
            '[': 'rectangle',
            '(': 'round',
            '{': 'rhombus',
            '>': 'asymmetric',
        }
        shape = shape_map.get(open_bracket, 'unknown')
        return node_id, shape, label
    return part, None, None

def parse_connection_line(line):
    line = line.strip()
    
    match = re.match(r'^(.*?)\s*-\.\s*(.+?)\s*\.-\s*>\s*(.*)$', line)
    if match:
        return match.group(1), match.group(3), "dotted_arrow", match.group(2).strip()
        
    match = re.match(r'^(.*?)\s*(-->|-\.-*->|==>)\s*\|([^|]+)\|\s*(.*)$', line)
    if match:
        arrow = match.group(2)
        label = match.group(3).strip()
        target = match.group(4)
        style = "solid_arrow"
        if "-.-" in arrow:
            style = "dotted_arrow"
        elif "==" in arrow:
            style = "thick_arrow"
        return match.group(1), target, style, label
        
    match = re.match(r'^(.*?)\s*(--|==)\s*([^-\s=].*?)\s*(-->|==>)\s*(.*)$', line)
    if match:
        connector = match.group(2)
        label = match.group(3).strip()
        target = match.group(5)
        style = "solid_arrow" if connector == "--" else "thick_arrow"
        return match.group(1), target, style, label

    match = re.match(r'^(.*?)\s*(-\.-*->|-\.-)\s*(.*)$', line)
    if match:
        arrow = match.group(2)
        style = "dotted_arrow" if "-->" in arrow or "->" in arrow else "dotted_line"
        return match.group(1), match.group(3), style, None

    match = re.match(r'^(.*?)\s*(-->|---|==>|==)\s*(.*)$', line)
    if match:
        arrow = match.group(2)
        style = "solid_arrow"
        if arrow == "---":
            style = "solid_line"
        elif arrow == "==>":
            style = "thick_arrow"
        elif arrow == "==":
            style = "thick_line"
        return match.group(1), match.group(3), style, None

    return None

def parse_mermaid_flowchart(mermaid_code):
    """
    Parses a Mermaid flowchart or graph diagram.
    Extracts subgraphs, nodes, and connections.
    """
    nodes = {}
    connections = []
    subgraphs = {}
    
    subgraph_stack = []
    
    lines = mermaid_code.splitlines()
    for line in lines:
        line = re.sub(r'%%.*$', '', line).strip()
        if not line or line.lower() in ("flowchart", "graph td", "graph lr", "graph", "flowchart td", "flowchart lr"):
            continue
            
        subgraph_match = re.match(r'^subgraph\s+([^\s\[\"\(]+)(?:\s+\[\s*\"([^\"]*)\"\s*\]|\s+\[([^\]]*)\]|\s+\"([^\"]*)\"|\s+(\S+))?', line, re.IGNORECASE)
        if subgraph_match:
            sub_id = subgraph_match.group(1)
            label = None
            for g in (subgraph_match.group(2), subgraph_match.group(3), subgraph_match.group(4), subgraph_match.group(5)):
                if g is not None:
                    label = g.strip()
                    break
            if not label:
                label = sub_id
                
            sub_info = {
                "id": sub_id,
                "label": label,
                "parent": subgraph_stack[-1] if subgraph_stack else None,
                "nodes": []
            }
            subgraphs[sub_id] = sub_info
            subgraph_stack.append(sub_id)
            continue
            
        if line.lower() == "end":
            if subgraph_stack:
                subgraph_stack.pop()
            continue
            
        if line.startswith(("direction ", "style ", "classDef ", "class ", "linkStyle ", "click ")):
            continue
            
        conn_res = parse_connection_line(line)
        if conn_res:
            src_part, tgt_part, style, label = conn_res
            src_id, src_shape, src_label = extract_node_from_part(src_part)
            tgt_id, tgt_shape, tgt_label = extract_node_from_part(tgt_part)
            
            if src_id not in nodes:
                nodes[src_id] = {
                    "id": src_id,
                    "shape": src_shape,
                    "label": src_label or src_id,
                    "subgraph": subgraph_stack[-1] if subgraph_stack else None
                }
            else:
                if src_shape:
                    nodes[src_id]["shape"] = src_shape
                if src_label:
                    nodes[src_id]["label"] = src_label
                    
            if tgt_id not in nodes:
                nodes[tgt_id] = {
                    "id": tgt_id,
                    "shape": tgt_shape,
                    "label": tgt_label or tgt_id,
                    "subgraph": subgraph_stack[-1] if subgraph_stack else None
                }
            else:
                if tgt_shape:
                    nodes[tgt_id]["shape"] = tgt_shape
                if tgt_label:
                    nodes[tgt_id]["label"] = tgt_label
                    
            if subgraph_stack:
                current_sub = subgraph_stack[-1]
                if src_id not in subgraphs[current_sub]["nodes"]:
                    subgraphs[current_sub]["nodes"].append(src_id)
                if tgt_id not in subgraphs[current_sub]["nodes"]:
                    subgraphs[current_sub]["nodes"].append(tgt_id)
                    
            connections.append({
                "from": src_id,
                "to": tgt_id,
                "style": style,
                "label": label
            })
        else:
            node_id, shape, label = extract_node_from_part(line)
            if node_id and (shape or label):
                if node_id not in nodes:
                    nodes[node_id] = {
                        "id": node_id,
                        "shape": shape,
                        "label": label or node_id,
                        "subgraph": subgraph_stack[-1] if subgraph_stack else None
                    }
                else:
                    if shape:
                        nodes[node_id]["shape"] = shape
                    if label:
                        nodes[node_id]["label"] = label
                        
                if subgraph_stack:
                    current_sub = subgraph_stack[-1]
                    if node_id not in subgraphs[current_sub]["nodes"]:
                        subgraphs[current_sub]["nodes"].append(node_id)
                        
    return {
        "nodes": nodes,
        "connections": connections,
        "subgraphs": subgraphs
    }

def parse_mermaid_class_diagram(mermaid_code):
    """
    Parses a Mermaid classDiagram code block.
    Extracts classes, attributes, methods, relationships, and namespaces.
    """
    classes = {}
    relationships = []
    namespaces = {}
    
    block_stack = []
    
    def parse_attribute_signature(sig):
        sig = sig.strip()
        constraints = []
        constraint_match = re.search(r'\{([^}]+)\}', sig)
        if constraint_match:
            constraints = [c.strip() for c in constraint_match.group(1).split(',')]
            sig = re.sub(r'\{([^}]+)\}', '', sig).strip()
            
        visibility = None
        vis_match = re.match(r'^([+\-#~])\s*(.*)$', sig)
        if vis_match:
            visibility = vis_match.group(1)
            sig = vis_match.group(2).strip()
            
        multiplicity = None
        mult_match = re.search(r'\[([^\]]+)\]$', sig)
        if mult_match:
            multiplicity = mult_match.group(1).strip()
            sig = re.sub(r'\[([^\]]+)\]$', '', sig).strip()
            
        name = sig
        attr_type = None
        if ':' in sig:
            parts = sig.split(':', 1)
            name = parts[0].strip()
            attr_type = parts[1].strip()
        else:
            parts = sig.split()
            if len(parts) > 1:
                name = parts[-1].strip()
                attr_type = ' '.join(parts[:-1]).strip()
                
        return {
            "visibility": visibility,
            "name": name,
            "type": attr_type,
            "multiplicity": multiplicity,
            "constraints": constraints,
            "raw": sig
        }

    def parse_method_signature(sig):
        sig = sig.strip()
        constraints = []
        constraint_match = re.search(r'\{([^}]+)\}', sig)
        if constraint_match:
            constraints = [c.strip() for c in constraint_match.group(1).split(',')]
            sig = re.sub(r'\{([^}]+)\}', '', sig).strip()
            
        visibility = None
        vis_match = re.match(r'^([+\-#~])\s*(.*)$', sig)
        if vis_match:
            visibility = vis_match.group(1)
            sig = vis_match.group(2).strip()
            
        param_match = re.search(r'\(([^)]*)\)', sig)
        parameters = []
        method_name = sig
        return_type = None
        
        if param_match:
            param_text = param_match.group(1).strip()
            if param_text:
                raw_params = param_text.split(',')
                for rp in raw_params:
                    rp = rp.strip()
                    if ':' in rp:
                        p_parts = rp.split(':', 1)
                        parameters.append({"name": p_parts[0].strip(), "type": p_parts[1].strip()})
                    else:
                        p_parts = rp.split()
                        if len(p_parts) > 1:
                            parameters.append({"name": p_parts[-1].strip(), "type": ' '.join(p_parts[:-1]).strip()})
                        else:
                            parameters.append({"name": rp, "type": None})
                            
            left_part = sig[:param_match.start()].strip()
            right_part = sig[param_match.end():].strip()
            
            if right_part.startswith(':'):
                return_type = right_part[1:].strip()
                method_name = left_part
            elif right_part:
                return_type = right_part
                method_name = left_part
            else:
                left_parts = left_part.split()
                if len(left_parts) > 1:
                    method_name = left_parts[-1].strip()
                    return_type = ' '.join(left_parts[:-1]).strip()
                else:
                    method_name = left_part
                    
        return {
            "visibility": visibility,
            "name": method_name,
            "parameters": parameters,
            "return_type": return_type,
            "constraints": constraints,
            "raw": sig
        }

    lines = mermaid_code.splitlines()
    for line in lines:
        line = re.sub(r'%%.*$', '', line).strip()
        if not line or line.lower() == "classdiagram":
            continue
            
        namespace_match = re.match(r'^namespace\s+([a-zA-Z0-9_\-]+)\s*\{', line, re.IGNORECASE)
        if namespace_match:
            ns_name = namespace_match.group(1)
            namespaces[ns_name] = {
                "name": ns_name,
                "classes": []
            }
            block_stack.append({"type": "namespace", "name": ns_name})
            continue
            
        class_block_match = re.match(r'^class\s+([a-zA-Z0-9_\-.:]+)\s*\{', line, re.IGNORECASE)
        if class_block_match:
            cls_name = class_block_match.group(1)
            current_ns = next((b["name"] for b in reversed(block_stack) if b["type"] == "namespace"), None)
            classes[cls_name] = {
                "name": cls_name,
                "namespace": current_ns,
                "attributes": [],
                "methods": []
            }
            if current_ns:
                namespaces[current_ns]["classes"].append(cls_name)
            block_stack.append({"type": "class", "name": cls_name})
            continue
            
        if line == "}":
            if block_stack:
                block_stack.pop()
            continue
            
        class_decl_match = re.match(r'^class\s+([a-zA-Z0-9_\-.:]+)$', line, re.IGNORECASE)
        if class_decl_match:
            cls_name = class_decl_match.group(1)
            if cls_name not in classes:
                current_ns = next((b["name"] for b in reversed(block_stack) if b["type"] == "namespace"), None)
                classes[cls_name] = {
                    "name": cls_name,
                    "namespace": current_ns,
                    "attributes": [],
                    "methods": []
                }
                if current_ns:
                    namespaces[current_ns]["classes"].append(cls_name)
            continue
            
        rel_match = re.match(
            r'^\s*([a-zA-Z0-9_\-.:]+)\s*(?:\"([^\"]*)\")?\s*(\*--|\*..|o--|o..|<\|--|<\|..|--\|>|\.\.\|>|-->|\.\.>|<--|<\.\.|--|\.\.|--\*|\.\.\*|--o|\.\.o)\s*(?:\"([^\"]*)\")?\s*([a-zA-Z0-9_\-.:]+)(?:\s*:\s*(.*))?$',
            line
        )
        if rel_match:
            from_cls = rel_match.group(1)
            from_mult = rel_match.group(2)
            rel_symbol = rel_match.group(3)
            to_mult = rel_match.group(4)
            to_cls = rel_match.group(5)
            label = rel_match.group(6)
            if label:
                label = label.strip()
                
            for cls_name in (from_cls, to_cls):
                if cls_name not in classes:
                    current_ns = next((b["name"] for b in reversed(block_stack) if b["type"] == "namespace"), None)
                    classes[cls_name] = {
                        "name": cls_name,
                        "namespace": current_ns,
                        "attributes": [],
                        "methods": []
                    }
                    if current_ns:
                        namespaces[current_ns]["classes"].append(cls_name)
                        
            rel_type = "association"
            direction = "none"
            if rel_symbol in ("*--", "--*", "*..", "..*"):
                rel_type = "composition"
            elif rel_symbol in ("o--", "--o", "o..", "..o"):
                rel_type = "aggregation"
            elif rel_symbol in ("<|--", "--|>", "<|..", "..|>"):
                rel_type = "generalization"
            elif rel_symbol in ("-->", "<--", "..>", "<.."):
                rel_type = "dependency"
                
            if rel_symbol in ("-->", "..>", "--|>", "..|>", "--*", "..*", "--o", "..o"):
                direction = "forward"
            elif rel_symbol in ("<--", "<..", "<|--", "<|..", "*--", "*..", "o--", "o.."):
                direction = "backward"
                
            relationships.append({
                "type": rel_type,
                "from_class": from_cls,
                "to_class": to_cls,
                "from_multiplicity": from_mult,
                "to_multiplicity": to_mult,
                "direction": direction,
                "label": label,
                "raw": line
            })
            continue
            
        member_match = re.match(r'^([a-zA-Z0-9_\-.:]+)\s*:\s*(.*)$', line)
        if member_match:
            cls_name = member_match.group(1)
            member_sig = member_match.group(2).strip()
            
            if cls_name not in classes:
                current_ns = next((b["name"] for b in reversed(block_stack) if b["type"] == "namespace"), None)
                classes[cls_name] = {
                    "name": cls_name,
                    "namespace": current_ns,
                    "attributes": [],
                    "methods": []
                }
                if current_ns:
                    namespaces[current_ns]["classes"].append(cls_name)
                    
            if '(' in member_sig:
                classes[cls_name]["methods"].append(parse_method_signature(member_sig))
            else:
                classes[cls_name]["attributes"].append(parse_attribute_signature(member_sig))
            continue
            
        if block_stack and block_stack[-1]["type"] == "class":
            cls_name = block_stack[-1]["name"]
            if '(' in line:
                classes[cls_name]["methods"].append(parse_method_signature(line))
            else:
                classes[cls_name]["attributes"].append(parse_attribute_signature(line))
                
    return {
        "classes": classes,
        "relationships": relationships,
        "namespaces": namespaces
    }

def parse_sequence_message_text(text, is_reply):
    text = text.strip()
    assignment = None
    operation_part = text
    
    if not is_reply:
        assign_match = re.match(r'^([a-zA-Z0-9_\-.]+)\s*(?:=|:=)\s*(.*)$', text)
        if assign_match:
            assignment = assign_match.group(1).strip()
            operation_part = assign_match.group(2).strip()
            
    param_match = re.search(r'\(([^)]*)\)', operation_part)
    operation = operation_part
    parameters = []
    
    if param_match:
        operation = operation_part[:param_match.start()].strip()
        param_text = param_match.group(1).strip()
        if param_text:
            raw_params = param_text.split(',')
            for rp in raw_params:
                rp = rp.strip()
                if ':' in rp:
                    p_parts = rp.split(':', 1)
                    parameters.append({"name": p_parts[0].strip(), "type": p_parts[1].strip()})
                else:
                    p_parts = rp.split()
                    if len(p_parts) > 1:
                        parameters.append({"name": p_parts[-1].strip(), "type": ' '.join(p_parts[:-1]).strip()})
                    else:
                        parameters.append({"name": rp, "type": None})
    else:
        if is_reply:
            assignment = operation_part
            operation = None
            
    return {
        "operation": operation,
        "parameters": parameters,
        "assignment": assignment,
        "raw": text
    }

def parse_mermaid_sequence_diagram(mermaid_code):
    """
    Parses a Mermaid sequenceDiagram code block.
    Extracts lifelines, messages, combined fragments, and nested structure.
    """
    lifelines = {}
    messages = []
    fragments = []
    
    fragment_stack = []
    
    lines = mermaid_code.splitlines()
    for line in lines:
        line = re.sub(r'%%.*$', '', line).strip()
        if not line or line.lower() == "sequencediagram":
            continue
            
        lifeline_match = re.match(
            r'^\s*(actor|participant)\s+([a-zA-Z0-9_\-.:]+)(?:\s+as\s+(?:\"([^\"]*)\"|([^\s]+)))?$',
            line,
            re.IGNORECASE
        )
        if lifeline_match:
            role = lifeline_match.group(1).lower()
            alias = lifeline_match.group(2)
            label = lifeline_match.group(3) if lifeline_match.group(3) is not None else lifeline_match.group(4)
            
            if not label:
                label = alias
                
            inst_name, class_name = parse_lifeline_label(label)
            if not inst_name:
                inst_name = alias
                
            lifelines[alias] = {
                "name": alias,
                "role": role,
                "instance_name": inst_name,
                "classifier_name": class_name,
                "label": label
            }
            continue
            
        frag_start_match = re.match(r'^\s*(alt|loop|opt|par|critical)\s*(.*)$', line, re.IGNORECASE)
        if frag_start_match:
            frag_type = frag_start_match.group(1).lower()
            guard = extract_guard(frag_start_match.group(2))
            
            branch = {"guard": guard, "messages": []}
            frag_node = {
                "type": frag_type,
                "branches": [branch],
                "nested": []
            }
            
            if fragment_stack:
                fragment_stack[-1]["nested"].append(frag_node)
            else:
                fragments.append(frag_node)
                
            fragment_stack.append(frag_node)
            continue
            
        frag_branch_match = re.match(r'^\s*(else|option)\s*(.*)$', line, re.IGNORECASE)
        if frag_branch_match:
            guard = extract_guard(frag_branch_match.group(2))
            if fragment_stack:
                parent_frag = fragment_stack[-1]
                branch = {"guard": guard, "messages": []}
                parent_frag["branches"].append(branch)
            continue
            
        if line.lower() == "end":
            if fragment_stack:
                fragment_stack.pop()
            continue
            
        msg_match = re.match(
            r'^\s*([a-zA-Z0-9_.:]+(?:-[a-zA-Z0-9_.:]+)*)\s*(-->>|->>|-->|->|--x|-x)([+-]?)\s*([a-zA-Z0-9_.:]+(?:-[a-zA-Z0-9_.:]+)*)([+-]?)\s*:\s*(.*)$',
            line
        )
        if msg_match:
            sender = msg_match.group(1)
            arrow = msg_match.group(2)
            act1 = msg_match.group(3)
            receiver = msg_match.group(4)
            act2 = msg_match.group(5)
            msg_text = msg_match.group(6).strip()
            
            for participant in (sender, receiver):
                if participant not in lifelines:
                    lifelines[participant] = {
                        "name": participant,
                        "role": "participant",
                        "instance_name": participant,
                        "classifier_name": None,
                        "label": participant
                    }
                    
            is_reply = arrow in ("-->", "-->>")
            msg_details = parse_sequence_message_text(msg_text, is_reply)
            
            arrow_type = "other"
            if arrow == "->>":
                arrow_type = "sync"
            elif arrow == "->":
                arrow_type = "async"
            elif arrow in ("-->", "-->>"):
                arrow_type = "reply"
                
            msg_record = {
                "sender": sender,
                "receiver": receiver,
                "arrow": arrow,
                "arrow_type": arrow_type,
                "activation": (act1 or act2 or None),
                "operation": msg_details["operation"],
                "parameters": msg_details["parameters"],
                "assignment": msg_details["assignment"],
                "raw": line,
                "fragment_context": [
                    {
                        "type": f["type"],
                        "guard": f["branches"][-1]["guard"]
                    } for f in fragment_stack
                ]
            }
            
            messages.append(msg_record)
            
            if fragment_stack:
                fragment_stack[-1]["branches"][-1]["messages"].append(msg_record)
            continue
            
    return {
        "lifelines": lifelines,
        "messages": messages,
        "fragments": fragments
    }

def parse_yang_file(filepath):
    """
    Parses a YANG file and extracts all defined names (typedefs, containers, lists, leaves, choices, cases, identities).
    """
    with open(filepath, "r", encoding="utf-8") as f:
        raw_content = f.read()

    # Extract module name from raw content first
    module_match = re.search(r'\bmodule\s+([a-zA-Z0-9_\-]+)', raw_content)
    if not module_match:
        return None, set()

    module_name = module_match.group(1)

    # Clean the content by removing comments and string literals to prevent parsing prose
    pattern = r'(/\*.*?\*/)|(//[^\n]*)|("(?:\\.|[^"\\])*")|(\'(?:\\.|[^\'\\])*\')'
    def replacer(match):
        if match.group(1): return " "  # block comment -> space
        if match.group(2): return "\n" # line comment -> newline
        return ""                      # string literal -> strip
    content = re.sub(pattern, replacer, raw_content, flags=re.DOTALL)

    # Patterns to match definitions
    # Covers all primary YANG statement types that define named schema nodes
    patterns = [
        r'\btypedef\s+([a-zA-Z0-9_\-]+)',
        r'\bleaf\s+([a-zA-Z0-9_\-]+)',
        r'\bleaf-list\s+([a-zA-Z0-9_\-]+)',
        r'\bcontainer\s+([a-zA-Z0-9_\-]+)',
        r'\blist\s+([a-zA-Z0-9_\-]+)',
        r'\bgrouping\s+([a-zA-Z0-9_\-]+)',
        r'\bchoice\s+([a-zA-Z0-9_\-]+)',
        r'\bcase\s+([a-zA-Z0-9_\-]+)',
        r'\bidentity\s+([a-zA-Z0-9_\-]+)',
        r'\banydata\s+([a-zA-Z0-9_\-]+)',
        r'\banyxml\s+([a-zA-Z0-9_\-]+)',
        r'\brpc\s+([a-zA-Z0-9_\-]+)',
        r'\bnotification\s+([a-zA-Z0-9_\-]+)',
        r'\baction\s+([a-zA-Z0-9_\-]+)'
    ]

    definitions = set()
    for pattern in patterns:
        for match in re.finditer(pattern, content):
            name = match.group(1)
            # Filter out any accidental matches with common keywords if matched
            if name not in {"description", "reference", "organization", "contact", "revision", "import", "prefix", "namespace", "yang-version"}:
                definitions.add(name)

    return module_name, definitions

def parse_schema_file(filepath):
    """
    Parses a schema file and extracts definitions depending on file extension.
    Supported extensions: .yang (YANG). Extensible to other formats.
    """
    ext = os.path.splitext(filepath)[1].lower()
    if ext == ".yang":
        return parse_yang_file(filepath)
    # Extensible to other formats (e.g. .yaml, .proto)
    print(f"Warning: Extensible schema parser not yet implemented for extension '{ext}' in {os.path.basename(filepath)}")
    return os.path.basename(filepath), set()

def load_behavioral_triggers(schema_dir, script_dir):
    workspace_dir = os.path.abspath(os.path.join(script_dir, "..", "..", ".."))
    search_paths = [
        os.path.join(schema_dir, "behavioral_triggers.json"),
        os.path.join(workspace_dir, "rules", "behavioral_triggers.json"),
        os.path.join(script_dir, "behavioral_triggers.json")
    ]
    for path in search_paths:
        if os.path.exists(path):
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
    return []

def load_feature_files(features_dir):
    """
    Loads all feature markdown files, returns a list of dicts with frontmatter and full text.
    """
    features = []
    if not os.path.exists(features_dir):
        return features

    for filename in os.listdir(features_dir):
        if not filename.endswith(".md"):
            continue
        filepath = os.path.join(features_dir, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        # Parse simple frontmatter
        labels = []
        frontmatter_match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
        if frontmatter_match:
            frontmatter_text = frontmatter_match.group(1)
            for line in frontmatter_text.splitlines():
                if line.startswith("labels:"):
                    # Parse list of labels e.g. ["feature", "ietf-geo-location"]
                    labels_match = re.search(r"\[(.*?)\]", line)
                    if labels_match:
                        labels = [lbl.strip().strip('"').strip("'") for lbl in labels_match.group(1).split(",")]
        
        features.append({
            "filename": filename,
            "labels": labels,
            "content": content
        })
    return features

def build_global_classes(features_dir):
    global_classes = {}
    if not os.path.exists(features_dir):
        return global_classes
    for filename in os.listdir(features_dir):
        if not filename.endswith(".md"):
            continue
        filepath = os.path.join(features_dir, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        class_diagram_matches = re.finditer(r"```mermaid\s*\n\s*classDiagram(.*?)(?=```|\Z)", content, re.DOTALL)
        for match in class_diagram_matches:
            parsed_cd = parse_mermaid_class_diagram(match.group(0))
            for class_name, class_info in parsed_cd["classes"].items():
                if class_name not in global_classes:
                    global_classes[class_name] = {
                        "name": class_name,
                        "attributes": [],
                        "methods": []
                    }
                # Merge attributes and methods avoiding duplicates
                existing_attrs = {a["name"] for a in global_classes[class_name]["attributes"]}
                for attr in class_info["attributes"]:
                    if attr["name"] not in existing_attrs:
                        global_classes[class_name]["attributes"].append(attr)
                existing_methods = {m["name"] for m in global_classes[class_name]["methods"]}
                for method in class_info["methods"]:
                    if method["name"] not in existing_methods:
                        global_classes[class_name]["methods"].append(method)
    return global_classes

def verify_uml_diagrams(features_dir, global_classes=None):
    """
    Validates that UML diagrams exist in all generated specs and conform to UML-only rules.
    """
    docs_dir = os.path.dirname(features_dir)
    user_stories_dir = os.path.join(docs_dir, "user-stories")
    use_cases_dir = os.path.join(docs_dir, "use-cases")
    epics_dir = os.path.join(docs_dir, "epics")

    errors = []

    def get_md_files(d):
        if not os.path.exists(d):
            return []
        return [os.path.join(d, f) for f in os.listdir(d) if f.endswith(".md")]

    # Scan all feature files to build global class symbol table
    feature_files = get_md_files(features_dir)
    if global_classes is None:
        global_classes = build_global_classes(features_dir)

    # 1. Verify Features
    for filepath in feature_files:
        filename = os.path.basename(filepath)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Check for invalid Mermaid dotted link syntax
        if re.search(r"-\.-*->\s*\|", content):
            errors.append(f"Feature {filename} contains invalid Mermaid dotted link label syntax (e.g. '-.->|' or '-.-->|'). Use '-. label .->' instead.")

        # Check for UML Class Diagram header
        if not re.search(r"##\s+UML\s+Class\s+Diagram", content, re.IGNORECASE):
            errors.append(f"Feature {filename} is missing a '## UML Class Diagram' header.")
            continue
        
        # Check for Mermaid classDiagram block
        class_diagram_match = re.search(r"```mermaid\s*\n\s*classDiagram(.*?)(?=```|\Z)", content, re.DOTALL)
        if not class_diagram_match:
            errors.append(f"Feature {filename} is missing a valid '```mermaid classDiagram' block.")
            continue
            
        if not re.search(r"(\*--|o--|<\|--|--|-->)", class_diagram_match.group(1)):
            errors.append(f"Feature {filename} contains a UML Class Diagram with no relationships. Isolated classes are prohibited; you must illustrate containment/inheritance/choice composition.")

        # Semantic Class Diagram Validation
        parsed_cd = parse_mermaid_class_diagram(class_diagram_match.group(0))
        classes = parsed_cd["classes"]
        relationships = parsed_cd["relationships"]

        # Check for isolated classes
        adj = {c: set() for c in classes}
        for rel in relationships:
            u = rel["from_class"]
            v = rel["to_class"]
            if u not in adj:
                adj[u] = set()
            if v not in adj:
                adj[v] = set()
            adj[u].add(v)
            adj[v].add(u)

        for c, neighbors in adj.items():
            if len(neighbors) == 0:
                errors.append(f"Feature {filename} contains class '{c}' with zero relationships. Isolated classes are prohibited.")

        if classes:
            start_node = next(iter(classes))
            visited = set()
            queue = [start_node]
            visited.add(start_node)
            while queue:
                curr = queue.pop(0)
                for neighbor in adj.get(curr, []):
                    if neighbor not in visited:
                        visited.add(neighbor)
                        queue.append(neighbor)
            unvisited = set(classes.keys()) - visited
            if unvisited:
                errors.append(f"Feature {filename} contains a disconnected UML Class Diagram. Classes {list(unvisited)} are not structurally connected to '{start_node}'.")

        # Primitives check
        valid_primitives = {"String", "Integer", "Real", "Boolean"}
        for cls_name, cls_info in classes.items():
            for attr in cls_info["attributes"]:
                if attr["raw"] and "<<" in attr["raw"] and ">>" in attr["raw"]:
                    continue
                attr_type = attr["type"]
                if not attr_type:
                    errors.append(f"Feature {filename} class '{cls_name}' attribute '{attr['name']}' is missing a type.")
                    continue
                if attr_type not in valid_primitives and attr_type not in classes:
                    errors.append(f"Feature {filename} class '{cls_name}' attribute '{attr['name']}' has invalid type '{attr_type}'. UML primitive types must be String, Integer, Real, or Boolean (case-sensitive), or reference another class.")

        # Stereotype & Generalization check
        choice_classes = set()
        for line in class_diagram_match.group(0).splitlines():
            line_clean = line.strip()
            m1 = re.search(r"<<choice>>\s*([a-zA-Z0-9_\-.:]+)", line_clean, re.IGNORECASE)
            if m1:
                choice_classes.add(m1.group(1))
            m2 = re.search(r"class\s+([a-zA-Z0-9_\-.:]+)\s+.*<<choice>>", line_clean, re.IGNORECASE)
            if m2:
                choice_classes.add(m2.group(1))
        for cls_name, cls_info in classes.items():
            if "<<choice>>" in cls_name:
                choice_classes.add(cls_name)
            for attr in cls_info["attributes"]:
                if attr["raw"] and "<<choice>>" in attr["raw"]:
                    choice_classes.add(cls_name)

        for choice_cls in choice_classes:
            has_subclass = False
            for rel in relationships:
                if rel["type"] == "generalization":
                    is_parent = False
                    if rel["direction"] == "backward" and rel["from_class"] == choice_cls:
                        is_parent = True
                    elif rel["direction"] == "forward" and rel["to_class"] == choice_cls:
                        is_parent = True
                    if is_parent:
                        has_subclass = True
                        break
            if not has_subclass:
                errors.append(f"Feature {filename} choice class '{choice_cls}' must have at least one subclass inheriting from it via generalization (<|--).")

        # Multiplicity & Visibility check
        for cls_name, cls_info in classes.items():
            for attr in cls_info["attributes"]:
                if attr["raw"] and "<<" in attr["raw"] and ">>" in attr["raw"]:
                    continue
                if attr["visibility"] not in {"+", "-", "#", "~"}:
                    errors.append(f"Feature {filename} class '{cls_name}' attribute '{attr['name']}' is missing a valid UML visibility prefix (+, -, #, ~).")
                if not attr["multiplicity"]:
                    errors.append(f"Feature {filename} class '{cls_name}' attribute '{attr['name']}' is missing a multiplicity (e.g. [1], [0..1], [0..*]).")

            for method in cls_info["methods"]:
                if method["visibility"] not in {"+", "-", "#", "~"}:
                    errors.append(f"Feature {filename} class '{cls_name}' method '{method['name']}' is missing a valid UML visibility prefix (+, -, #, ~).")
                has_mult = False
                if method["return_type"] and re.search(r'\[[^\]]+\]', method["return_type"]):
                    has_mult = True
                elif re.search(r'\)\s*\[[^\]]+\]', method["raw"]) or re.search(r'\]\s*$', method["raw"]):
                    has_mult = True
                if not has_mult:
                    errors.append(f"Feature {filename} class '{cls_name}' method '{method['name']}' is missing a multiplicity (e.g. [1], [0..1], [0..*]) in its return signature.")

        # Check that erDiagram is NOT used
        if re.search(r"erDiagram", content):
            errors.append(f"Feature {filename} contains forbidden 'erDiagram' (ERD diagrams are strictly prohibited).")

        # Enforce the structured Functional UI Requirements sub-sections
        if not re.search(r"##\s+Functional\s+UI\s+Requirements", content, re.IGNORECASE):
            errors.append(f"Feature {filename} is missing '## Functional UI Requirements' section.")
        else:
            if not re.search(r"###\s+1\.\s+Test\s+Data\s+Shape", content, re.IGNORECASE):
                errors.append(f"Feature {filename} is missing structured sub-section '### 1. Test Data Shape (JSON Payload Example)'.")
            elif not re.search(r"###\s+1\.\s+Test\s+Data\s+Shape.*```json", content, re.DOTALL | re.IGNORECASE):
                errors.append(f"Feature {filename} is missing a JSON payload example (```json block) under Test Data Shape.")
            if not re.search(r"###\s+4\.\s+Interactive\s+Flow\s+&\s+States", content, re.IGNORECASE):
                errors.append(f"Feature {filename} is missing structured sub-section '### 4. Interactive Flow & States'.")

    # 2. Verify User Stories
    story_files = get_md_files(user_stories_dir)
    for filepath in story_files:
        filename = os.path.basename(filepath)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Check for invalid Mermaid dotted link syntax
        if re.search(r"-\.-*->\s*\|", content):
            errors.append(f"User Story {filename} contains invalid Mermaid dotted link label syntax (e.g. '-.->|' or '-.-->|'). Use '-. label .->' instead.")

        if not re.search(r"##\s+UML\s+Sequence\s+Diagram", content, re.IGNORECASE):
            errors.append(f"User Story {filename} is missing a '## UML Sequence Diagram' header.")
            continue
            
        # Check for Mermaid sequenceDiagram block(s)
        seq_diagram_matches = re.finditer(r"```mermaid\s*\n\s*sequenceDiagram(.*?)(?=```|\Z)", content, re.DOTALL)
        has_seq = False
        for seq_match in seq_diagram_matches:
            has_seq = True
            seq_code = seq_match.group(0)
            parsed_sd = parse_mermaid_sequence_diagram(seq_code)
            lifelines = parsed_sd["lifelines"]
            messages = parsed_sd["messages"]

            # Lifeline Notation: Verify all lifelines match the alias-label syntax with name : Classifier
            for alias, lf in lifelines.items():
                label = lf["label"]
                if not lf["classifier_name"]:
                    errors.append(f"User Story {filename} sequence diagram lifeline '{alias}' is missing the name : Classifier pattern in its label: '{label}'")
                else:
                    # Cross-View Classifier Check
                    cls_name = lf["classifier_name"]
                    if cls_name not in global_classes:
                        errors.append(f"User Story {filename} sequence diagram lifeline '{alias}' specifies classifier '{cls_name}' which is not defined in any feature class diagram.")

            # Message operations checks
            for msg in messages:
                # Cross-View Operation Check
                if msg["arrow_type"] in ("sync", "async"):
                    op_name = msg["operation"]
                    if not op_name:
                        errors.append(f"User Story {filename} sequence diagram message '{msg['raw']}' is missing an operation signature.")
                        continue
                    receiver = msg["receiver"]
                    rx_lf = lifelines.get(receiver)
                    rx_cls = rx_lf["classifier_name"] if rx_lf else None
                    if rx_cls:
                        if rx_cls in global_classes:
                            cls_methods = global_classes[rx_cls]["methods"]
                            method_found = None
                            for m in cls_methods:
                                if m["name"] == op_name:
                                    method_found = m
                                    break
                            if not method_found:
                                errors.append(f"User Story {filename} sequence diagram message '{msg['raw']}' calls operation '{op_name}' which is not defined on class '{rx_cls}' in any class diagram.")
                            elif method_found["visibility"] != "+":
                                errors.append(f"User Story {filename} sequence diagram message '{msg['raw']}' calls non-public operation '{op_name}' on class '{rx_cls}' (visibility must be '+').")

                # Return Arrow Check
                if msg["arrow_type"] == "reply":
                    if msg["arrow"] != "-->":
                        errors.append(f"User Story {filename} sequence diagram return message '{msg['raw']}' uses invalid reply arrow '{msg['arrow']}'. Return arrows must strictly use standard open arrowhead '-->'.")
                    
                    # Return Signature Check
                    raw_msg_text = msg["raw"].split(":", 1)[1].strip() if ":" in msg["raw"] else msg["raw"]
                    if "(" in raw_msg_text or ")" in raw_msg_text:
                        errors.append(f"User Story {filename} sequence diagram return message '{msg['raw']}' looks like an operation call (contains parentheses). Return messages must be simple assignments or return values (e.g. status : Status).")

            # Combined Fragment Guards
            for line in seq_code.splitlines():
                line_clean = line.strip()
                line_clean = re.sub(r'%%.*$', '', line_clean).strip()
                if not line_clean:
                    continue
                frag_match = re.match(r'^\s*(alt|loop|opt|par|critical|else|option)(?:\s+(.*))?$', line_clean, re.IGNORECASE)
                if frag_match:
                    keyword = frag_match.group(1).lower()
                    guard_part = frag_match.group(2)
                    if guard_part:
                        guard_part = guard_part.strip()
                        if guard_part and not (guard_part.startswith('[') and guard_part.endswith(']')):
                            errors.append(f"User Story {filename} sequence diagram contains a combined fragment '{keyword}' with guard '{guard_part}' that is not enclosed in square brackets [].")

        if not has_seq:
            errors.append(f"User Story {filename} is missing a valid '```mermaid sequenceDiagram' block.")

        # Enforce BDD Scenario or Story Statement
        bdd_scenario_present = (
            re.search(r"\bGiven\b.*?\bWhen\b.*?\bThen\b", content, re.DOTALL | re.IGNORECASE) or
            re.search(r"\bAs a\b.*?\bI want to\b.*?\bSo that\b", content, re.DOTALL | re.IGNORECASE) or
            re.search(r"\bAs an\b.*?\bI want to\b.*?\bSo that\b", content, re.DOTALL | re.IGNORECASE)
        )
        if not bdd_scenario_present:
            errors.append(f"User Story {filename} must contain a valid BDD scenario (Given-When-Then or As a/I want to/So that).")
            
        # Enforce Required Features Matrix & Checklist format
        rf_match = re.search(r"##\s+Required\s+Features(?:\s+Matrix)?(.*?)(?=##|\Z)", content, re.DOTALL | re.IGNORECASE)
        if not rf_match:
            errors.append(f"User Story {filename} is missing '## Required Features Matrix' section.")
        else:
            rf_section = rf_match.group(1)
            checkboxes = re.findall(r"-\s+\[[ xX]\]\s+.*", rf_section)
            if not checkboxes:
                errors.append(f"User Story {filename} must have at least one feature reference checklist item in its Required Features Matrix.")
            for cb in checkboxes:
                url_match = re.search(r"\]\((https?://[^)]+)\)", cb)
                if not url_match:
                    errors.append(f"User Story {filename} contains a checklist item with a missing or non-absolute URL: '{cb.strip()}'.")
                else:
                    link = url_match.group(1)
                    if not re.match(r"^https?://[a-zA-Z0-9.-]+/", link):
                        errors.append(f"User Story {filename} contains a non-absolute/invalid URL in Required Features Matrix: '{link}'.")
                
                # Extract semantic linkage justification: must be in parentheses at the end of the line
                justification_match = re.search(r"\s+\(([^)]+)\)$", cb)
                if not justification_match or (url_match and justification_match.group(1) == url_match.group(1)):
                    errors.append(f"User Story {filename} contains a checklist item with a missing or invalid parenthetical semantic justification at the end: '{cb.strip()}'.")

    # 3. Verify Use Cases
    usecase_files = get_md_files(use_cases_dir)
    for filepath in usecase_files:
        basename = os.path.basename(filepath)
        
        # Enforce naming convention
        if not re.match(r"^uc-\d{2}-[a-z0-9\-]+\.md$", basename):
            errors.append(f"Use Case file '{basename}' does not follow the naming convention 'uc-[XX]-[name].md' (zero-padded, lowercase, dash-separated).")

        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Check for invalid Mermaid dotted link syntax
        if re.search(r"-\.-*->\s*\|", content):
            errors.append(f"Use Case {basename} contains invalid Mermaid dotted link label syntax (e.g. '-.->|' or '-.-->|'). Use '-. label .->' instead.")

        if not re.search(r"##\s+UML\s+Diagrams", content, re.IGNORECASE):
            errors.append(f"Use Case {basename} is missing a '## UML Diagrams' header.")
            continue
            
        # Check for Use Case Diagram (flowchart graph)
        usecase_diagram_matches = list(re.finditer(r"```mermaid\s*\n\s*(?:graph|flowchart)(.*?)(?=```|\Z)", content, re.DOTALL))
        if not usecase_diagram_matches:
            errors.append(f"Use Case {basename} is missing a UML Use Case diagram ('```mermaid graph' or 'flowchart').")
        else:
            for match in usecase_diagram_matches:
                diagram_code = match.group(0)
                parsed = parse_mermaid_flowchart(diagram_code)
                
                # 1. Subject Boundary
                boundary_sub = None
                for sub_id, sub_info in parsed["subgraphs"].items():
                    if "boundary" in sub_id.lower() or "system" in sub_id.lower() or \
                       (sub_info["label"] and ("boundary" in sub_info["label"].lower() or "system" in sub_info["label"].lower())):
                        boundary_sub = sub_info
                        break
                
                if not boundary_sub:
                    errors.append(f"Use Case {basename} is missing a system boundary subgraph (e.g. ID or label containing 'boundary' or 'system').")
                    continue
                    
                boundary_sub_id = boundary_sub["id"]
                
                # Helper to check if a node is an actor
                def is_actor_node(node):
                    if not node:
                        return False
                    return (node.get("shape") == "circle") or \
                           ("actor" in node["id"].lower()) or \
                           (node.get("label") and "actor" in node["label"].lower())
                
                # Assert all usecase / actor nodes placements and shapes
                for node_id, node in parsed["nodes"].items():
                    is_actor = is_actor_node(node)
                    if is_actor:
                        # Assert actor node is outside boundary_sub (not in any subgraph's nodes)
                        if node.get("subgraph") is not None:
                            errors.append(f"Use Case {basename} actor node '{node_id}' must be placed outside the system boundary subgraph (found in subgraph '{node['subgraph']}').")
                    else:
                        # Assert usecase node is inside boundary_sub
                        if node.get("subgraph") != boundary_sub_id:
                            errors.append(f"Use Case {basename} use case node '{node_id}' must be defined inside the system boundary subgraph '{boundary_sub_id}'.")
                        # Assert all use case nodes use stadium/oval shape
                        if node.get("shape") != "stadium":
                            errors.append(f"Use Case {basename} use case node '{node_id}' must use the Mermaid stadium/oval shape ('stadium').")
                
                # Assert connections
                for conn in parsed["connections"]:
                    src_id = conn["from"]
                    tgt_id = conn["to"]
                    src_node = parsed["nodes"].get(src_id)
                    tgt_node = parsed["nodes"].get(tgt_id)
                    
                    src_is_actor = is_actor_node(src_node)
                    tgt_is_actor = is_actor_node(tgt_node)
                    
                    # Undirected Actor Links
                    if (src_is_actor and not tgt_is_actor) or (not src_is_actor and tgt_is_actor):
                        if "arrow" in conn["style"]:
                            errors.append(f"Use Case {basename} connection from '{src_id}' to '{tgt_id}' between Actor and Use Case must use an undirected link, not '{conn['style']}'.")
                    
                    # Extend Arrow Direction
                    if conn["label"] and "extend" in conn["label"].lower():
                        src_has_ext = "extend" in src_id.lower() or "ext" in src_id.lower() or (src_node and src_node.get("label") and ("extend" in src_node["label"].lower() or "ext" in src_node["label"].lower()))
                        tgt_has_ext = "extend" in tgt_id.lower() or "ext" in tgt_id.lower() or (tgt_node and tgt_node.get("label") and ("extend" in tgt_node["label"].lower() or "ext" in tgt_node["label"].lower()))
                        if tgt_has_ext and not src_has_ext:
                            errors.append(f"Use Case {basename} extend arrow from '{src_id}' to '{tgt_id}' is reversed. Extend arrows must point from the extending Use Case (client) to the base Use Case (supplier).")
            
        # Check for State Machine Diagram
        if not re.search(r"```mermaid\s*\n\s*stateDiagram", content):
            errors.append(f"Use Case {basename} is missing a UML State Machine diagram ('```mermaid stateDiagram').")
 
        # Check for ERD
        if re.search(r"erDiagram", content):
            errors.append(f"Use Case {basename} contains forbidden 'erDiagram' (ERD diagrams are strictly prohibited).")

        # Check for Cockburn sections
        required_sections = [
            (r"##\s+1\.\s+Actors", "## 1. Actors"),
            (r"##\s+2\.\s+Preconditions", "## 2. Preconditions"),
            (r"##\s+3\.\s+Trigger", "## 3. Trigger"),
            (r"##\s+4\.\s+Main\s+Success\s+Scenario", "## 4. Main Success Scenario"),
            (r"##\s+5\.\s+Alternate\s+(?:and|&)\s+Exception\s+Flows", "## 5. Alternate and Exception Flows"),
            (r"##\s+6\.\s+Postconditions", "## 6. Postconditions"),
            (r"##\s+8\.\s+Realization\s+Matrix", "## 8. Realization Matrix")
        ]
        for pattern, header_name in required_sections:
            if not re.search(pattern, content, re.IGNORECASE):
                errors.append(f"Use Case {basename} is missing mandated section '{header_name}'.")

        # Enforce at least 2 alternate flows with at least 2 numbered steps
        flows_block_match = re.search(r"##\s+5\.\s+Alternate\s+(?:and|&)\s+Exception\s+Flows(.*?)(?=##\s+6\.\s+Postconditions|\Z)", content, re.DOTALL | re.IGNORECASE)
        if flows_block_match:
            flows_block = flows_block_match.group(1)
            flows = re.findall(r"-\s+\*\*\d[a-zA-Z]\..*?(?=-\s+\*\*\d[a-zA-Z]\.|\Z)", flows_block, re.DOTALL)
            if len(flows) < 2:
                errors.append(f"Use Case {basename} must contain at least 2 detailed Alternate/Exception flows.")
            else:
                for idx, flow in enumerate(flows):
                    steps = re.findall(r"\b\d+\.\s+\S+", flow)
                    if len(steps) < 2:
                        errors.append(f"Use Case {basename} alternate flow {idx+1} is too thin (must contain at least 2 numbered steps).")
        else:
            errors.append(f"Use Case {basename} is missing '## 5. Alternate and Exception Flows' content block.")

        # Validate the Realization Matrix checklist and absolute URLs
        if re.search(r"##\s+8\.\s+Realization\s+Matrix", content, re.IGNORECASE):
            if not re.search(r"###\s+Required\s+User\s+Stories", content, re.IGNORECASE):
                errors.append(f"Use Case {basename} is missing '### Required User Stories' under Realization Matrix.")
            if not re.search(r"###\s+Required\s+Features", content, re.IGNORECASE):
                errors.append(f"Use Case {basename} is missing '### Required Features' under Realization Matrix.")
            
            # Validate checklist occupancy and contents under specific subheadings
            stories_section_match = re.search(r"###\s+Required\s+User\s+Stories(.*?)(?=###\s+Required\s+Features|##\s+Source\s+References|\Z)", content, re.DOTALL | re.IGNORECASE)
            features_section_match = re.search(r"###\s+Required\s+Features(.*?)(?=###\s+Required\s+User\s+Stories|##\s+Source\s+References|\Z)", content, re.DOTALL | re.IGNORECASE)
            
            story_checkboxes = []
            if stories_section_match:
                story_checkboxes = re.findall(r"-\s+\[[ xX]\]\s+.*", stories_section_match.group(1))
            
            feature_checkboxes = []
            if features_section_match:
                feature_checkboxes = re.findall(r"-\s+\[[ xX]\]\s+.*", features_section_match.group(1))
                
            if not story_checkboxes:
                errors.append(f"Use Case {basename} Realization Matrix contains no User Story checkboxes under '### Required User Stories'.")
            if not feature_checkboxes:
                errors.append(f"Use Case {basename} Realization Matrix contains no Feature checkboxes under '### Required Features'.")
                
            all_checkboxes = story_checkboxes + feature_checkboxes
            for cb in all_checkboxes:
                # Extract URL: must be in parentheses immediately following the markdown link bracket
                url_match = re.search(r"\]\((https?://[^)]+)\)", cb)
                if not url_match:
                    errors.append(f"Use Case {basename} contains a checklist item with a missing or non-absolute markdown link URL: '{cb.strip()}'.")
                else:
                    url_str = url_match.group(1)
                    if not re.match(r"^https?://[a-zA-Z0-9.-]+/", url_str):
                        errors.append(f"Use Case {basename} contains an invalid URL in realization matrix: '{url_str}'.")
                
                # Extract semantic linkage justification: must be in parentheses at the end of the line
                justification_match = re.search(r"\s+\(([^)]+)\)$", cb)
                if not justification_match or (url_match and justification_match.group(1) == url_match.group(1)):
                    errors.append(f"Use Case {basename} contains a checklist item with a missing or invalid parenthetical semantic justification at the end: '{cb.strip()}'.")

    # 4. Verify Epics
    epic_files = get_md_files(epics_dir)
    for filepath in epic_files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        # Check for invalid Mermaid dotted link syntax
        if re.search(r"-\.-*->\s*\|", content):
            errors.append(f"Epic {os.path.basename(filepath)} contains invalid Mermaid dotted link label syntax (e.g. '-.->|' or '-.-->|'). Use '-. label .->' instead.")

        # Check for mandated 6-section headers
        required_headers = [
            (r"##\s+1\.\s+Context", "## 1. Context"),
            (r"##\s+2\.\s+Requirements\s+&\s+Checklist", "## 2. Requirements & Checklist"),
            (r"##\s+3\.\s+Architecture\s+and\s+System\s+Interaction\s+Diagrams", "## 3. Architecture and System Interaction Diagrams"),
            (r"##\s+4\.\s+State\s+Machine\s+Definitions", "## 4. State Machine Definitions"),
            (r"##\s+5\.\s+Specification\s+Context", "## 5. Specification Context"),
            (r"##\s+6\.\s+Source\s+References", "## 6. Source References")
        ]
        for pattern, header_name in required_headers:
            if not re.search(pattern, content, re.IGNORECASE):
                errors.append(f"Epic {os.path.basename(filepath)} is missing mandated section '{header_name}'.")

        # Check for ## System-Level UML Class Diagram header
        if not re.search(r"##\s+System-Level\s+UML\s+Class\s+Diagram", content, re.IGNORECASE):
            errors.append(f"Epic {os.path.basename(filepath)} is missing a '## System-Level UML Class Diagram' header.")

        # Check for Mermaid classDiagram block
        if not re.search(r"```mermaid\s*\n\s*classDiagram", content):
            errors.append(f"Epic {os.path.basename(filepath)} is missing a valid '```mermaid classDiagram' block.")

        # Check for ## System State Machine Diagram header
        if not re.search(r"##\s+System\s+State\s+Machine\s+Diagram", content, re.IGNORECASE):
            errors.append(f"Epic {os.path.basename(filepath)} is missing a '## System State Machine Diagram' header.")

        # Check for Mermaid stateDiagram-v2 block
        if not re.search(r"```mermaid\s*\n\s*stateDiagram-v2", content):
            errors.append(f"Epic {os.path.basename(filepath)} is missing a valid '```mermaid stateDiagram-v2' block.")

    return errors

def verify_behavioral_triggers(schema_dir, features_dir, modules):
    docs_dir = os.path.dirname(features_dir)
    user_stories_dir = os.path.join(docs_dir, "user-stories")
    use_cases_dir = os.path.join(docs_dir, "use-cases")
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    triggers = load_behavioral_triggers(schema_dir, script_dir)
    
    # Collect all definitions from all modules
    all_nodes = set()
    for defs in modules.values():
        all_nodes.update(defs)
        
    errors = []
    for trigger in triggers:
        trigger_nodes = trigger.get("trigger_nodes", [])
        # Check if the schema contains any of the trigger nodes
        if not any(node in all_nodes for node in trigger_nodes):
            continue
            
        for rule in trigger.get("rules", []):
            target_type = rule.get("target_type")
            target_dir = user_stories_dir if target_type == "user-story" else use_cases_dir
            
            found_match = False
            files = []
            if os.path.exists(target_dir):
                files = [os.path.join(target_dir, f) for f in os.listdir(target_dir) if f.endswith(".md")]

            for filepath in files:
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()

                # Check mermaid block requirement if specified
                mermaid_type = rule.get("requires_mermaid_block")
                if mermaid_type:
                    mermaid_matches = re.findall(rf"```mermaid\s*\n\s*{mermaid_type}(.*?)\n```", content, re.DOTALL)
                    if not mermaid_matches:
                        continue
                    
                    mermaid_terms = rule.get("match_terms_in_mermaid", [])
                    if mermaid_terms:
                        if not any(any(term in m_content for term in mermaid_terms) for m_content in mermaid_matches):
                            continue

                # Check terms in body
                body_terms = rule.get("match_terms_in_body", [])
                if body_terms:
                    if not any(term in content.lower() for term in body_terms):
                        continue

                # Check secondary terms in body if specified
                body_terms_sec = rule.get("match_terms_in_body_secondary", [])
                if body_terms_sec:
                    if not any(term in content.lower() for term in body_terms_sec):
                        continue

                found_match = True
                break

            if not found_match:
                errors.append(rule.get("error_message", f"Failed validation rule in {trigger.get('name')}"))

    return errors

def main():
    workspace_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))

    # Allow overriding paths via command-line args or environment variables.
    schema_dir = (
        sys.argv[1] if len(sys.argv) > 1
        else os.environ.get("SCHEMA_DIR", os.environ.get("YANG_DIR", None))
    )
    if not schema_dir:
        schema_path = os.path.join(workspace_dir, "schema")
        yang_path = os.path.join(workspace_dir, "yang")
        if os.path.exists(schema_path):
            schema_dir = schema_path
        else:
            schema_dir = yang_path

    features_dir = (
        sys.argv[2] if len(sys.argv) > 2
        else os.environ.get("FEATURES_DIR", os.path.join(workspace_dir, "docs", "features"))
    )

    has_failed = False
    print("=== Model Coverage Parity Audit ===")
    print(f"Scanning schemas in: {schema_dir}")
    print(f"Scanning feature specifications in: {features_dir}\n")

    # 1. Parse all modules
    modules = {}
    if os.path.exists(schema_dir):
        for filename in os.listdir(schema_dir):
            filepath = os.path.join(schema_dir, filename)
            if os.path.isdir(filepath):
                continue
            try:
                module_name, definitions = parse_schema_file(filepath)
                if module_name:
                    modules[module_name] = definitions
            except Exception as e:
                print(f"Warning: Failed to parse schema file {filename}: {e}")

    skip_coverage_checks = False
    if not modules:
        non_yang_extensions = {".yaml", ".yml", ".json", ".proto"}
        has_non_yang_schemas = False
        if os.path.exists(schema_dir):
            for filename in os.listdir(schema_dir):
                ext = os.path.splitext(filename)[1].lower()
                if ext in non_yang_extensions:
                    has_non_yang_schemas = True
                    break
        if has_non_yang_schemas:
            print("Warning: Deep AST node coverage parity audit is currently optimized for YANG schemas. Skipping strict coverage percentage check for OpenAPI/Protobuf, but proceeding with UML compliance audit.")
            skip_coverage_checks = True
        else:
            print("Error: No valid modules/schemas found.")
            sys.exit(1)

    # 2. Load all feature markdown files
    features = load_feature_files(features_dir)
    print(f"Loaded {len(features)} feature specifications.\n")
    if not features:
        print("Error: No feature specifications found in directory.")
        sys.exit(1)

    # 3. Audit coverage per module
    total_defined = 0
    total_covered = 0
    coverage_gaps = {}

    global_classes = build_global_classes(features_dir)

    if not skip_coverage_checks:
        for module_name, definitions in sorted(modules.items()):
            # Find all feature files that explicitly list this module name in their labels
            matching_features = [f for f in features if module_name in f["labels"]]
            
            # If no features target this module explicitly, it is an auxiliary/unused schema and not a target epic.
            if not matching_features:
                continue

            module_defined = len(definitions)
            module_covered = 0
            missing = []

            for name in sorted(definitions):
                # Verify node coverage against class/attribute/method names in global_classes
                # Support camelCase and PascalCase variations from kebab-case / snake_case
                variants = {name}
                if '-' in name or '_' in name:
                    parts = re.split(r'[-_]', name)
                    variants.add(parts[0] + "".join(p.capitalize() for p in parts[1:]))
                    variants.add("".join(p.capitalize() for p in parts))
                else:
                    if name:
                        variants.add(name[0].lower() + name[1:])
                        variants.add(name[0].upper() + name[1:])

                found = False
                if any(v in global_classes for v in variants):
                    found = True
                else:
                    for cls_info in global_classes.values():
                        if any(attr["name"] in variants for attr in cls_info["attributes"]):
                            found = True
                            break
                        if any(method["name"] in variants for method in cls_info["methods"]):
                            found = True
                            break

                if found:
                    module_covered += 1
                else:
                    missing.append(name)

            total_defined += module_defined
            total_covered += module_covered

            if missing:
                coverage_gaps[module_name] = missing

            if module_defined > 0:
                pct = (module_covered / module_defined) * 100
                print(f"Module '{module_name}': {module_covered}/{module_defined} nodes covered ({pct:.2f}%)")
            else:
                print(f"Module '{module_name}': 0 nodes defined")

        print("\n=== Audit Summary ===")
        if total_defined > 0:
            overall_pct = (total_covered / total_defined) * 100
            print(f"Total Schema Nodes Defined: {total_defined}")
            print(f"Total Schema Nodes Covered: {total_covered}")
            print(f"Overall Model Coverage:     {overall_pct:.2f}%")
        else:
            print("No target schema nodes found to verify.")
            sys.exit(1)

    print("\n=== UML Diagrams Compliance Audit ===")
    uml_errors = verify_uml_diagrams(features_dir, global_classes)
    
    has_failed = False

    if uml_errors:
        print("[!] UML Compliance Violations Identified:")
        for err in uml_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: All specification files are fully UML-compliant (no ERDs or invalid syntax found).")

    if coverage_gaps:
        print("\n[!] Coverage Gaps Identified:")
        for module_name, missing in sorted(coverage_gaps.items()):
            print(f"  Module '{module_name}' is missing {len(missing)} nodes:")
            print(f"    Missing: {', '.join(missing)}")
        print("\nError: 100% model coverage validation failed.")
        has_failed = True
    else:
        if not skip_coverage_checks:
            print("\nSuccess: 100% model coverage verified across all specification files.")

    print("\n=== Behavioral Coverage Triggers Audit ===")
    behavioral_errors = verify_behavioral_triggers(schema_dir, features_dir, modules)

    if behavioral_errors:
        print("[!] Behavioral Coverage Violations Identified:")
        for err in behavioral_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: All behavioral coverage triggers passed.")

    if has_failed:
        sys.exit(1)
    else:
        print("\nSuccess: All verification checks passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
