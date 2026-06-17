# Copyright Gint Atkinson, gint.atkinson@gmail.com

#!/usr/bin/env python3
import os
import re
import sys
import json
import ast

def load_codebase_rules(workspace_dir):
    rules_path = os.environ.get("CODEBASE_RULES_PATH")
    if not rules_path:
        rules_path = os.path.join(workspace_dir, ".pipeline", "logical-ui", "codebase_rules.json")
    if os.path.exists(rules_path):
        try:
            with open(rules_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"Warning: Failed to load codebase_rules.json: {e}")
    return {}


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

def parse_mermaid_class_diagram(mermaid_code, rules=None):
    """
    Parses a Mermaid classDiagram code block.
    Extracts classes, attributes, methods, relationships, and namespaces.
    """
    classes = {}
    relationships = []
    namespaces = {}
    
    block_stack = []
    
    visibility_prefixes = ["+", "-", "#", "~"]
    if rules:
        visibility_prefixes = rules.get("validation_rules", {}).get("visibility_prefixes", visibility_prefixes)
    vis_pattern = r'^(' + '|'.join(re.escape(p) for p in visibility_prefixes) + r')\s*(.*)$'
    
    rel_connectors = r'(\*--|\*..|o--|o..|<\|--|<\|..|--\|>|\.\.\|>|-->|\.\.>|<--|<\.\.|--|\.\.|--\*|\.\.\*|--o|\.\.o)'
    if rules:
        config_connectors = rules.get("validation_rules", {}).get("relationship_connectors")
        if config_connectors:
            if not config_connectors.startswith('('):
                config_connectors = f"({config_connectors})"
            rel_connectors = config_connectors
    
    def parse_attribute_signature(sig):
        sig = sig.strip()
        constraints = []
        constraint_match = re.search(r'\{([^}]+)\}', sig)
        if constraint_match:
            constraints = [c.strip() for c in constraint_match.group(1).split(',')]
            sig = re.sub(r'\{([^}]+)\}', '', sig).strip()
            
        visibility = None
        vis_match = re.match(vis_pattern, sig)
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
        vis_match = re.match(vis_pattern, sig)
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
            r'^\s*([a-zA-Z0-9_\-.:]+)\s*(?:\"([^\"]*)\")?\s*' + rel_connectors + r'\s*(?:\"([^\"]*)\")?\s*([a-zA-Z0-9_\-.:]+)(?:\s*:\s*(.*))?$',
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

def find_workspace_dir(path):
    curr = os.path.abspath(path)
    while True:
        if os.path.exists(os.path.join(curr, ".pipeline", "logical-ui", "codebase_rules.json")):
            return curr
        parent = os.path.dirname(curr)
        if parent == curr:
            break
        curr = parent
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))

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

    workspace_dir = find_workspace_dir(filepath)
    rules = load_codebase_rules(workspace_dir)
    yang_exclude_keywords = set(rules.get("validation_rules", {}).get("yang_exclude_keywords", [
        "description", "reference", "organization", "contact", "revision", "import", "prefix", "namespace", "yang-version"
    ]))

    definitions = set()
    for pattern in patterns:
        for match in re.finditer(pattern, content):
            name = match.group(1)
            # Filter out any accidental matches with common keywords if matched
            if name not in yang_exclude_keywords:
                definitions.add(name)

    return module_name, definitions

class ISchemaParser:
    def can_parse(self, filepath: str) -> bool:
        raise NotImplementedError
    def parse(self, filepath: str):
        raise NotImplementedError

class SchemaRouter:
    def __init__(self):
        self._parsers = []
    def register(self, parser: ISchemaParser):
        self._parsers.append(parser)
    def parse_schema_file(self, filepath: str):
        for parser in self._parsers:
            if parser.can_parse(filepath):
                return parser.parse(filepath)
        ext = os.path.splitext(filepath)[1].lower()
        print(f"Warning: Extensible schema parser not yet implemented for extension '{ext}' in {os.path.basename(filepath)}")
        return os.path.basename(filepath), set()

class YangSchemaParser(ISchemaParser):
    def can_parse(self, filepath: str) -> bool:
        return filepath.lower().endswith(".yang")
    def parse(self, filepath: str):
        return parse_yang_file(filepath)

schema_router = SchemaRouter()
schema_router.register(YangSchemaParser())

def parse_schema_file(filepath):
    """
    Parses a schema file and extracts definitions depending on file extension.
    Supported extensions: .yang (YANG). Extensible to other formats.
    """
    return schema_router.parse_schema_file(filepath)

def load_behavioral_triggers(schema_dir, script_dir):
    workspace_dir = os.path.abspath(os.path.join(script_dir, "..", "..", ".."))
    rules = load_codebase_rules(workspace_dir)
    meta = rules.get("meta", {})
    trig_path = meta.get("behavioral_triggers_path")
    
    search_paths = []
    if trig_path:
        search_paths.append(os.path.join(workspace_dir, trig_path))
    search_paths.extend([
        os.path.join(schema_dir, "behavioral_triggers.json"),
        os.path.join(workspace_dir, "rules", "behavioral_triggers.json"),
        os.path.join(script_dir, "behavioral_triggers.json")
    ])
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
    workspace_dir = find_workspace_dir(features_dir)
    rules = load_codebase_rules(workspace_dir)
    for filename in os.listdir(features_dir):
        if not filename.endswith(".md"):
            continue
        filepath = os.path.join(features_dir, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        class_diagram_matches = re.finditer(r"```mermaid\s*\n\s*classDiagram(.*?)(?=```|\Z)", content, re.DOTALL)
        for match in class_diagram_matches:
            parsed_cd = parse_mermaid_class_diagram(match.group(0), rules)
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

def build_classes_from_features(matching_features, rules=None):
    classes = {}
    for feat in matching_features:
        content = feat["content"]
        class_diagram_matches = re.finditer(r"```mermaid\s*\n\s*classDiagram(.*?)(?=```|\Z)", content, re.DOTALL)
        for match in class_diagram_matches:
            parsed_cd = parse_mermaid_class_diagram(match.group(0), rules)
            for class_name, class_info in parsed_cd["classes"].items():
                if class_name not in classes:
                    classes[class_name] = {
                        "name": class_name,
                        "attributes": [],
                        "methods": []
                    }
                # Merge attributes and methods avoiding duplicates
                existing_attrs = {a["name"] for a in classes[class_name]["attributes"]}
                for attr in class_info["attributes"]:
                    if attr["name"] not in existing_attrs:
                        classes[class_name]["attributes"].append(attr)
                existing_methods = {m["name"] for m in classes[class_name]["methods"]}
                for method in class_info["methods"]:
                    if method["name"] not in existing_methods:
                        classes[class_name]["methods"].append(method)
    return classes

def verify_uml_diagrams(features_dir, global_classes=None):
    """
    Validates that UML diagrams exist in all generated specs and conform to UML-only rules.
    """
    workspace_dir = os.path.abspath(os.path.join(features_dir, "..", ".."))
    rules = load_codebase_rules(workspace_dir)
    if not rules:
        raise ValueError("codebase_rules.json is empty or could not be loaded")
        
    backlog_dirs = rules.get("backlog_directories")
    if not backlog_dirs:
        raise ValueError("Missing 'backlog_directories' in codebase_rules.json")
    user_stories_dir = os.path.join(workspace_dir, backlog_dirs.get("user_stories"))
    if not user_stories_dir:
        raise ValueError("Missing 'backlog_directories.user_stories' in codebase_rules.json")
    use_cases_dir = os.path.join(workspace_dir, backlog_dirs.get("use_cases"))
    if not use_cases_dir:
        raise ValueError("Missing 'backlog_directories.use_cases' in codebase_rules.json")
    epics_dir = os.path.join(workspace_dir, backlog_dirs.get("epics"))
    if not epics_dir:
        raise ValueError("Missing 'backlog_directories.epics' in codebase_rules.json")

    errors = []

    def get_md_files(d):
        if not os.path.exists(d):
            return []
        return [os.path.join(d, f) for f in os.listdir(d) if f.endswith(".md")]

    # Scan all feature files to build global class symbol table
    feature_files = get_md_files(features_dir)
    if global_classes is None:
        global_classes = build_global_classes(features_dir)

    val_rules = rules.get("validation_rules")
    if not val_rules:
        raise ValueError("Missing 'validation_rules' in codebase_rules.json")
    dotted_link_pattern = val_rules.get("mermaid_dotted_link_regex")
    if dotted_link_pattern is None:
        raise ValueError("Missing 'validation_rules.mermaid_dotted_link_regex' in codebase_rules.json")
    forbidden_diagram_types = val_rules.get("forbidden_diagram_types")
    if forbidden_diagram_types is None:
        raise ValueError("Missing 'validation_rules.forbidden_diagram_types' in codebase_rules.json")
    required_sections = val_rules.get("required_sections")
    if required_sections is None:
        raise ValueError("Missing 'validation_rules.required_sections' in codebase_rules.json")
    required_diagrams = val_rules.get("required_diagrams")
    if required_diagrams is None:
        raise ValueError("Missing 'validation_rules.required_diagrams' in codebase_rules.json")

    uml_primitives = set(val_rules.get("uml_primitives", ["String", "Integer", "Real", "Boolean"]))
    visibility_prefixes = set(val_rules.get("visibility_prefixes", ["+", "-", "#", "~"]))
    relationship_connectors = val_rules.get("relationship_connectors", r"(\*--|o--|<\|--|--|-->)")
    choice_stereotypes = val_rules.get("choice_stereotypes", ["<<choice>>"])
    multiplicity_regex = val_rules.get("multiplicity_regex", r"\[[^\]]+\]")
    essential_feature_sections = val_rules.get("essential_feature_sections", ["Class Diagram", "Interface Requirements"])
    
    test_data_shape_regex = val_rules.get("test_data_shape_regex", r"###\s+1\.\s+Test\s+Data\s+Shape")
    test_data_block_regex = val_rules.get("test_data_block_regex", r"```json")
    bdd_scenario_regexes = val_rules.get("bdd_scenario_regexes", [r"\bGiven\b.*?\bWhen\b.*?\bThen\b", r"\bAs a\b.*?\bI want to\b.*?\bSo that\b", r"\bAs an\b.*?\bI want to\b.*?\bSo that\b"])
    required_features_matrix_regex = val_rules.get("required_features_matrix_regex", r"##\s+Required\s+Features(?:\s+Matrix)?(.*?)(?=##|\Z)")
    checkbox_syntax_regex = val_rules.get("checkbox_syntax_regex", r"-\s+\[[ xX]\]\s+.*")
    use_case_alternate_flows_header = val_rules.get("use_case_alternate_flows_header", "## 5. Alternate and Exception Flows")
    use_case_numbered_step_regex = val_rules.get("use_case_numbered_step_regex", r"\b\d+\.\s+\S+")
    use_case_flow_list_regex = val_rules.get("use_case_flow_list_regex", r"-\s+\*\*\d[a-zA-Z]\..*?")
    realization_matrix_header = val_rules.get("realization_matrix_header", "## 8. Realization Matrix")
    realization_stories_header = val_rules.get("realization_stories_header", "### Required User Stories")
    realization_features_header = val_rules.get("realization_features_header", "### Required Features")

    # 1. Verify Features
    for filepath in feature_files:
        filename = os.path.basename(filepath)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Check for invalid Mermaid dotted link syntax
        if re.search(dotted_link_pattern, content):
            errors.append(f"Feature {filename} contains invalid Mermaid dotted link label syntax. Use standard label formatting.")

        # Check for forbidden diagram types
        for ftype in forbidden_diagram_types:
            if re.search(ftype, content):
                errors.append(f"Feature {filename} contains forbidden '{ftype}' diagram type.")

        # Parse interface type from frontmatter (defaulting to ui)
        interface_type = "ui"
        frontmatter_match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
        if frontmatter_match:
            frontmatter_text = frontmatter_match.group(1)
            for fm_line in frontmatter_text.splitlines():
                if ":" in fm_line:
                    fm_parts = fm_line.split(":", 1)
                    fm_key = fm_parts[0].strip()
                    fm_val = fm_parts[1].strip().strip('"').strip("'")
                    if fm_key in ("interface_type", "interface-type"):
                        interface_type = fm_val.lower()

        req_key = f"feature_{interface_type}"
        required_feature_sections = required_sections.get(req_key)
        if required_feature_sections is None:
            required_feature_sections = required_sections.get("feature")
        if required_feature_sections is None:
            raise ValueError(f"Missing '{req_key}' or 'feature' in codebase_rules.json required_sections")
        
        has_essential_sections = True
        for pattern, header_name in required_feature_sections:
            if not re.search(pattern, content, re.IGNORECASE):
                errors.append(f"Feature {filename} is missing section '{header_name}'.")
                if any(essential in header_name for essential in essential_feature_sections):
                    has_essential_sections = False

        if not has_essential_sections:
            continue
        
        # Check required diagrams for feature
        feature_req_diagrams = required_diagrams.get("feature")
        if feature_req_diagrams is None:
            raise ValueError("Missing 'validation_rules.required_diagrams.feature' in codebase_rules.json")
        
        has_diag_error = False
        for diag_type in feature_req_diagrams:
            if not re.search(r"```mermaid\s*\n\s*" + diag_type, content):
                errors.append(f"Feature {filename} is missing a valid diagram of type '{diag_type}'.")
                has_diag_error = True
        if has_diag_error:
            continue
            
        class_diagram_match = re.search(r"```mermaid\s*\n\s*classDiagram(.*?)(?=```|\Z)", content, re.DOTALL)
        if not class_diagram_match:
            continue
            
        if not re.search(relationship_connectors, class_diagram_match.group(1)):
            errors.append(f"Feature {filename} contains a UML Class Diagram with no relationships. Isolated classes are prohibited; you must illustrate containment/inheritance/choice composition.")

        # Semantic Class Diagram Validation
        parsed_cd = parse_mermaid_class_diagram(class_diagram_match.group(0), rules)
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
        for cls_name, cls_info in classes.items():
            for attr in cls_info["attributes"]:
                if attr["raw"] and "<<" in attr["raw"] and ">>" in attr["raw"]:
                    continue
                attr_type = attr["type"]
                if not attr_type:
                    errors.append(f"Feature {filename} class '{cls_name}' attribute '{attr['name']}' is missing a type.")
                    continue
                if attr_type not in uml_primitives and attr_type not in classes:
                    errors.append(f"Feature {filename} class '{cls_name}' attribute '{attr['name']}' has invalid type '{attr_type}'. UML primitive types must be {', '.join(sorted(uml_primitives))} (case-sensitive), or reference another class.")

        # Stereotype & Generalization check
        choice_classes = set()
        for line in class_diagram_match.group(0).splitlines():
            line_clean = line.strip()
            for st in choice_stereotypes:
                st_esc = re.escape(st)
                m1 = re.search(st_esc + r"\s*([a-zA-Z0-9_\-.:]+)", line_clean, re.IGNORECASE)
                if m1:
                    choice_classes.add(m1.group(1))
                m2 = re.search(r"class\s+([a-zA-Z0-9_\-.:]+)\s+.*" + st_esc, line_clean, re.IGNORECASE)
                if m2:
                    choice_classes.add(m2.group(1))
        for cls_name, cls_info in classes.items():
            for st in choice_stereotypes:
                if st in cls_name:
                    choice_classes.add(cls_name)
                for attr in cls_info["attributes"]:
                    if attr["raw"] and st in attr["raw"]:
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
                if attr["visibility"] not in visibility_prefixes:
                    errors.append(f"Feature {filename} class '{cls_name}' attribute '{attr['name']}' is missing a valid UML visibility prefix ({', '.join(sorted(visibility_prefixes))}).")
                if not attr["multiplicity"]:
                    errors.append(f"Feature {filename} class '{cls_name}' attribute '{attr['name']}' is missing a multiplicity (e.g. [1], [0..1], [0..*]).")

            for method in cls_info["methods"]:
                if method["visibility"] not in visibility_prefixes:
                    errors.append(f"Feature {filename} class '{cls_name}' method '{method['name']}' is missing a valid UML visibility prefix ({', '.join(sorted(visibility_prefixes))}).")
                has_mult = False
                if method["return_type"] and re.search(multiplicity_regex, method["return_type"]):
                    has_mult = True
                elif re.search(r'\)\s*' + multiplicity_regex, method["raw"]) or re.search(multiplicity_regex + r'\s*$', method["raw"]):
                    has_mult = True
                if not has_mult:
                    errors.append(f"Feature {filename} class '{cls_name}' method '{method['name']}' is missing a multiplicity (e.g. [1], [0..1], [0..*]) in its return signature.")

        # Block check under Test Data Shape
        if re.search(test_data_shape_regex, content, re.IGNORECASE):
            if not re.search(test_data_shape_regex + r".*?" + test_data_block_regex, content, re.DOTALL | re.IGNORECASE):
                errors.append(f"Feature {filename} is missing a payload example ({test_data_block_regex} block) under Test Data Shape.")

    # 2. Verify User Stories
    story_files = get_md_files(user_stories_dir)
    for filepath in story_files:
        filename = os.path.basename(filepath)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Check for invalid Mermaid dotted link syntax
        if re.search(dotted_link_pattern, content):
            errors.append(f"User Story {filename} contains invalid Mermaid dotted link label syntax. Use standard label formatting.")

        # Check for forbidden diagram types
        for ftype in forbidden_diagram_types:
            if re.search(ftype, content):
                errors.append(f"User Story {filename} contains forbidden '{ftype}' diagram type.")

        # Check required sections for user story
        required_story_sections = required_sections.get("user_story")
        if required_story_sections is None:
            raise ValueError("Missing 'validation_rules.required_sections.user_story' in codebase_rules.json")
        
        has_essential_sections = True
        for pattern, header_name in required_story_sections:
            if not re.search(pattern, content, re.IGNORECASE):
                errors.append(f"User Story {filename} is missing section '{header_name}'.")
                if "Sequence Diagram" in header_name:
                    has_essential_sections = False

        if not has_essential_sections:
            continue
            
        # Check required diagrams for user story
        story_req_diagrams = required_diagrams.get("user_story")
        if story_req_diagrams is None:
            raise ValueError("Missing 'validation_rules.required_diagrams.user_story' in codebase_rules.json")
        
        has_seq = False
        seq_diagram_matches = []
        for diag_type in story_req_diagrams:
            for match in re.finditer(r"```mermaid\s*\n\s*" + diag_type + r"(.*?)(?=```|\Z)", content, re.DOTALL):
                has_seq = True
                seq_diagram_matches.append(match)
                
        for seq_match in seq_diagram_matches:
            seq_code = seq_match.group(0)
            parsed = parse_mermaid_sequence_diagram(seq_code)
            lifelines = parsed["lifelines"]
            messages = parsed["messages"]

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
                    sequence_replies = val_rules.get("sequence_replies", ["-->"])
                    if msg["arrow"] not in sequence_replies:
                        errors.append(f"User Story {filename} sequence diagram return message '{msg['raw']}' uses invalid reply arrow '{msg['arrow']}'. Return arrows must strictly use standard open arrowhead {', '.join(sequence_replies)}.")
                    
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
                fragment_keywords = val_rules.get("fragment_keywords", ["alt", "loop", "opt", "par", "critical", "else", "option"])
                frag_pattern = r'^\s*(' + '|'.join(re.escape(k) for k in fragment_keywords) + r')(?:\s+(.*))?$'
                frag_match = re.match(frag_pattern, line_clean, re.IGNORECASE)
                if frag_match:
                    keyword = frag_match.group(1).lower()
                    guard_part = frag_match.group(2)
                    if guard_part:
                        guard_part = guard_part.strip()
                        if guard_part and not (guard_part.startswith('[') and guard_part.endswith(']')):
                            errors.append(f"User Story {filename} sequence diagram contains a combined fragment '{keyword}' with guard '{guard_part}' that is not enclosed in square brackets [].")

        if not has_seq:
            errors.append(f"User Story {filename} is missing a required diagram matching pattern(s): {', '.join(story_req_diagrams)}")

        # Enforce BDD Scenario or Story Statement
        # Enforce BDD Scenario or Story Statement
        bdd_scenario_present = any(re.search(pat, content, re.DOTALL | re.IGNORECASE) for pat in bdd_scenario_regexes)
        if not bdd_scenario_present:
            errors.append(f"User Story {filename} must contain a valid BDD scenario (Given-When-Then or As a/I want to/So that).")
            
        # Enforce Required Features Matrix & Checklist format
        rf_match = re.search(required_features_matrix_regex, content, re.DOTALL | re.IGNORECASE)
        if not rf_match:
            errors.append(f"User Story {filename} is missing '## Required Features Matrix' section.")
        else:
            rf_section = rf_match.group(1)
            checkboxes = re.findall(checkbox_syntax_regex, rf_section)
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
    use_case_naming = val_rules.get("naming_conventions", {}).get("use_case", r"^uc-\d{2}-[a-z0-9\-]+\.md$")
    for filepath in usecase_files:
        basename = os.path.basename(filepath)
        
        # Enforce naming convention
        if not re.match(use_case_naming, basename):
            errors.append(f"Use Case file '{basename}' does not follow the naming convention '{use_case_naming}'.")

        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Check for invalid Mermaid dotted link syntax
        if re.search(dotted_link_pattern, content):
            errors.append(f"Use Case {basename} contains invalid Mermaid dotted link label syntax. Use standard label formatting.")

        # Check for forbidden diagram types
        for ftype in forbidden_diagram_types:
            if re.search(ftype, content):
                errors.append(f"Use Case {basename} contains forbidden '{ftype}' diagram type.")

        # Check required sections for use case
        required_usecase_sections = required_sections.get("use_case")
        if required_usecase_sections is None:
            raise ValueError("Missing 'validation_rules.required_sections.use_case' in codebase_rules.json")
        
        has_essential_sections = True
        for pattern, header_name in required_usecase_sections:
            if not re.search(pattern, content, re.IGNORECASE):
                errors.append(f"Use Case {basename} is missing section '{header_name}'.")
                if "Diagrams" in header_name:
                    has_essential_sections = False

        if not has_essential_sections:
            continue
            
        # Check required diagrams for use case
        usecase_req_diagrams = required_diagrams.get("use_case")
        if usecase_req_diagrams is None:
            raise ValueError("Missing 'validation_rules.required_diagrams.use_case' in codebase_rules.json")
            
        for diag_type in usecase_req_diagrams:
            diag_matches = list(re.finditer(r"```mermaid\s*\n\s*" + diag_type + r"(.*?)(?=```|\Z)", content, re.DOTALL))
            if not diag_matches:
                errors.append(f"Use Case {basename} is missing a valid diagram matching pattern '{diag_type}'.")
            elif "graph" in diag_type or "flowchart" in diag_type:
                for match in diag_matches:
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
                            if val_rules.get("use_case_stadium_nodes_only", True):
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
                        if val_rules.get("use_case_undirected_actor_links_only", True):
                            if (src_is_actor and not tgt_is_actor) or (not src_is_actor and tgt_is_actor):
                                if "arrow" in conn["style"]:
                                    errors.append(f"Use Case {basename} connection from '{src_id}' to '{tgt_id}' between Actor and Use Case must use an undirected link, not '{conn['style']}'.")
                        
                        # Extend Arrow Direction
                        if val_rules.get("use_case_extend_arrow_direction_check", True):
                            if conn["label"] and "extend" in conn["label"].lower():
                                src_has_ext = "extend" in src_id.lower() or "ext" in src_id.lower() or (src_node and src_node.get("label") and ("extend" in src_node["label"].lower() or "ext" in src_node["label"].lower()))
                                tgt_has_ext = "extend" in tgt_id.lower() or "ext" in tgt_id.lower() or (tgt_node and tgt_node.get("label") and ("extend" in tgt_node["label"].lower() or "ext" in tgt_node["label"].lower()))
                                if tgt_has_ext and not src_has_ext:
                                    errors.append(f"Use Case {basename} extend arrow from '{src_id}' to '{tgt_id}' is reversed. Extend arrows must point from the extending Use Case (client) to the base Use Case (supplier).")

        # Enforce at least 2 alternate flows with at least 2 numbered steps
        flows_block_match = re.search(re.escape(use_case_alternate_flows_header) + r"(.*?)(?=##\s+6\.\s+Postconditions|\Z)", content, re.DOTALL | re.IGNORECASE)
        if flows_block_match:
            flows_block = flows_block_match.group(1)
            flows = re.findall(use_case_flow_list_regex, flows_block, re.DOTALL)
            use_case_flow_limit = val_rules.get("use_case_flow_limit", 2)
            use_case_step_limit = val_rules.get("use_case_step_limit", 2)
            if len(flows) < use_case_flow_limit:
                errors.append(f"Use Case {basename} must contain at least {use_case_flow_limit} detailed Alternate/Exception flows.")
            else:
                for idx, flow in enumerate(flows):
                    steps = re.findall(use_case_numbered_step_regex, flow)
                    if len(steps) < use_case_step_limit:
                        errors.append(f"Use Case {basename} alternate flow {idx+1} is too thin (must contain at least {use_case_step_limit} numbered steps).")
        else:
            errors.append(f"Use Case {basename} is missing '{use_case_alternate_flows_header}' content block.")

        # Validate the Realization Matrix checklist and absolute URLs
        if re.search(realization_matrix_header, content, re.IGNORECASE):
            if not re.search(realization_stories_header, content, re.IGNORECASE):
                errors.append(f"Use Case {basename} is missing '{realization_stories_header}' under Realization Matrix.")
            if not re.search(realization_features_header, content, re.IGNORECASE):
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
        filename = os.path.basename(filepath)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        # Check for invalid Mermaid dotted link syntax
        if re.search(dotted_link_pattern, content):
            errors.append(f"Epic {filename} contains invalid Mermaid dotted link label syntax. Use standard label formatting.")

        # Check for forbidden diagram types
        for ftype in forbidden_diagram_types:
            if re.search(ftype, content):
                errors.append(f"Epic {filename} contains forbidden '{ftype}' diagram type.")

        # Check required sections for epic
        required_epic_sections = required_sections.get("epic")
        if required_epic_sections is None:
            raise ValueError("Missing 'validation_rules.required_sections.epic' in codebase_rules.json")
        for pattern, header_name in required_epic_sections:
            if not re.search(pattern, content, re.IGNORECASE):
                errors.append(f"Epic {filename} is missing section '{header_name}'.")

        # Check required diagrams for epic
        epic_req_diagrams = required_diagrams.get("epic")
        if epic_req_diagrams is None:
            raise ValueError("Missing 'validation_rules.required_diagrams.epic' in codebase_rules.json")
        for diag_type in epic_req_diagrams:
            if not re.search(r"```mermaid\s*\n\s*" + diag_type, content):
                errors.append(f"Epic {filename} is missing a valid diagram of type '{diag_type}'.")

    return errors

def normalize_case(name):
    if not name:
        return ""
    return name.lower().replace('-', '').replace('_', '').replace(' ', '')

def verify_behavioral_triggers(schema_dir, features_dir, modules):
    workspace_dir = os.path.abspath(os.path.join(features_dir, "..", ".."))
    rules = load_codebase_rules(workspace_dir)
    backlog_dirs = rules.get("backlog_directories", {})
    user_stories_dir = os.path.join(workspace_dir, backlog_dirs.get("user_stories", "docs/user-stories"))
    use_cases_dir = os.path.join(workspace_dir, backlog_dirs.get("use_cases", "docs/use-cases"))
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    triggers = load_behavioral_triggers(schema_dir, script_dir)
    
    # Collect all definitions from all modules (and normalize their case)
    all_nodes_normalized = {normalize_case(node) for defs in modules.values() for node in defs}
        
    errors = []
    for trigger in triggers:
        trigger_nodes = trigger.get("trigger_nodes", [])
        # Check if the schema contains any of the trigger nodes (case-normalized)
        normalized_trigger_nodes = [normalize_case(node) for node in trigger_nodes]
        if not any(node in all_nodes_normalized for node in normalized_trigger_nodes):
            continue
            
        for rule in trigger.get("rules", []):
            target_type = rule.get("target_type")
            target_dir = user_stories_dir if target_type == "user-story" else use_cases_dir
            
            files = []
            if os.path.exists(target_dir):
                files = [os.path.join(target_dir, f) for f in os.listdir(target_dir) if f.endswith(".md")]

            # Find all files that contain any of the trigger nodes
            trigger_files = []
            for filepath in files:
                try:
                    with open(filepath, "r", encoding="utf-8") as f:
                        content = f.read()
                except Exception as e:
                    print(f"Warning: Failed to read file {filepath}: {e}")
                    continue
                
                has_any_node = False
                for node in trigger_nodes:
                    escaped_node = re.escape(node).replace(r'\-', r'[\s\-_]').replace(r'\_', r'[\s\-_]')
                    if re.search(rf'\b{escaped_node}\b', content, re.IGNORECASE):
                        has_any_node = True
                        break
                if has_any_node:
                    trigger_files.append((filepath, content))

            if not trigger_files:
                errors.append(f"Validation failed: No {target_type} files found referencing any trigger nodes: {', '.join(trigger_nodes)}. {rule.get('error_message')}")
                continue

            for filepath, content in trigger_files:
                file_valid = True
                
                is_target = False
                for node in trigger_nodes:
                    escaped_node = re.escape(node).replace(r'\-', r'[\s\-_]').replace(r'\_', r'[\s\-_]')
                    if re.search(rf'\b{escaped_node}\b', content, re.IGNORECASE):
                        is_target = True
                        break
                if not is_target:
                    continue

                # Check mermaid block requirement if specified
                mermaid_type = rule.get("requires_mermaid_block")
                if mermaid_type:
                    mermaid_matches = re.findall(rf"```mermaid\s*\n\s*{mermaid_type}(.*?)\n```", content, re.DOTALL)
                    if not mermaid_matches:
                        file_valid = False
                    else:
                        mermaid_terms = rule.get("match_terms_in_mermaid", [])
                        if mermaid_terms:
                            if not any(any(term in m_content for term in mermaid_terms) for m_content in mermaid_matches):
                                file_valid = False

                # Check terms in body
                body_terms = rule.get("match_terms_in_body", [])
                if body_terms:
                    if not any(term in content.lower() for term in body_terms):
                        file_valid = False

                # Check secondary terms in body if specified
                body_terms_sec = rule.get("match_terms_in_body_secondary", [])
                if body_terms_sec:
                    if not any(term in content.lower() for term in body_terms_sec):
                        file_valid = False

                if not file_valid:
                    errors.append(f"In {os.path.basename(filepath)}: {rule.get('error_message')}")

    return errors



def strip_c_style_comments(content):
    # Group 1: strings (double, single, backtick). Group 2: block comments. Group 3: line comments.
    pattern = r'("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|`(?:\\.|[^`\\])*`)|(/\*.*?\*/)|(//[^\n]*)'
    
    def replacer(match):
        if match.group(2) or match.group(3): 
            return " "  # Replace matched comments with space
        return match.group(1)  # Return strings entirely untouched
        
    return re.sub(pattern, replacer, content, flags=re.DOTALL)

# Deprecate old functions by pointing to the safe one
strip_js_comments = strip_c_style_comments
strip_dart_comments = strip_c_style_comments

def check_banned_imports(content, forbidden_words, file_ext):
    if not forbidden_words:
        return []
    if file_ext == ".dart":
        clean_content = strip_dart_comments(content)
    else:
        clean_content = strip_js_comments(content)
        
    found_banned = []
    lines = clean_content.splitlines()
    for line in lines:
        line_strip = line.strip()
        is_import = False
        if line_strip.startswith(("import ", "import'", "import\"", "export ", "export'", "export\"", "part ", "part'")):
            is_import = True
        elif "require(" in line_strip:
            is_import = True
            
        if is_import:
            for word in forbidden_words:
                if re.search(r'\b' + re.escape(word) + r'\b', line_strip):
                    found_banned.append(word)
    return list(set(found_banned))

def walk_json_ast_for_compliance(ast_tree, target_method="stopPropagation", ast_rules=None):
    if not ast_rules:
        ast_rules = {}
    call_expr = ast_rules.get("call_expression", "CallExpression")
    member_expr = ast_rules.get("member_expression", "MemberExpression")
    callee_key = ast_rules.get("callee", "callee")
    prop_key = ast_rules.get("property", "property")
    name_key = ast_rules.get("name", "name")
    
    stack = [ast_tree]
    while stack:
        node = stack.pop()
        if isinstance(node, dict):
            if node.get("type") == call_expr:
                callee = node.get(callee_key, {})
                if callee.get("type") == member_expr:
                    property_name = callee.get(prop_key, {}).get(name_key)
                    if property_name == target_method:
                        return True
            # Push dict values to stack
            stack.extend(node.values())
        elif isinstance(node, list):
            # Push array items to stack
            stack.extend(node)
            
    return False

def extract_hex_colors_from_json(data):
    colors = set()
    if isinstance(data, dict):
        for k, v in data.items():
            colors.update(extract_hex_colors_from_json(v))
    elif isinstance(data, list):
        for item in data:
            colors.update(extract_hex_colors_from_json(item))
    elif isinstance(data, str):
        if re.match(r'^#[0-9a-fA-F]{6}$', data) or re.match(r'^#[0-9a-fA-F]{3}$', data):
            colors.add(data.lower())
    return colors

def verify_python_ast(filepath, forbidden_colors):
    with open(filepath, "r", encoding="utf-8") as f:
        code = f.read()
    try:
        tree = ast.parse(code, filename=filepath)
        for node in ast.walk(tree):
            if isinstance(node, ast.Constant) and isinstance(node.value, str):
                val = node.value.lower()
                for color in forbidden_colors:
                    if color in val:
                        return f"Python Constant in {os.path.basename(filepath)} contains hardcoded color '{color}'"
    except Exception as e:
        return f"Python file {os.path.basename(filepath)} has AST parsing errors: {e}"
    return None

def verify_codebase_compliance(workspace_dir):
    """
    Validates codebase compliance using AST inspection, comment-stripping,
    pluggable memory safety checks, playhead rate checks, and egress write-lock audits.
    """
    errors = []
    
    # Load rules dynamically from codebase_rules.json
    rules = load_codebase_rules(workspace_dir)
    if not rules:
        raise ValueError("codebase_rules.json is empty or could not be loaded")
    
    # Resolve target directories
    val_rules = rules.get("validation_rules", {})
    playhead_rate_limits = val_rules.get("playhead_rate_limits", [0.90, 1.10])
    target_dirs = rules.get("target_directories", {})
    react_dir_name = target_dirs.get("react")
    react_dir = os.path.join(workspace_dir, react_dir_name) if react_dir_name else None
    flutter_dir_name = target_dirs.get("flutter")
    flutter_dir = os.path.join(workspace_dir, flutter_dir_name) if flutter_dir_name else None
    
    # Resolve React rules
    react_rules = rules.get("react_rules")
    if react_rules and react_dir:
        react_exts_list = react_rules.get("file_extensions", [])
        react_exts = tuple(react_exts_list)
        react_exclusions = set(react_rules.get("exclusions", []))
        react_forbidden_words = react_rules.get("forbidden_words", [])
        react_write_lock_keywords = react_rules.get("write_lock_keywords", [])
        react_selection_keywords = react_rules.get("selection_keywords", [])
        react_interaction_keywords = react_rules.get("interaction_keywords", [])
        react_playhead_clamp_regex = react_rules.get("playhead_clamp_regex", [])
        react_ui_dirs = react_rules.get("ui_directories", [])
        react_net_dirs = react_rules.get("network_directories", [])
        react_ast_compliance_method = react_rules.get("ast_compliance_method", "")
        react_viewport_file_patterns = react_rules.get("viewport_file_patterns", [])
        react_network_file_patterns = react_rules.get("network_file_patterns", [])
    else:
        react_dir = None
        
    # Resolve Flutter rules
    flutter_rules = rules.get("flutter_rules")
    if flutter_rules and flutter_dir:
        flutter_exts_list = flutter_rules.get("file_extensions", [])
        flutter_exts = tuple(flutter_exts_list)
        flutter_exclusions = set(flutter_rules.get("exclusions", []))
        flutter_selection_setters = flutter_rules.get("selection_setters", [])
        flutter_selection_triggers = flutter_rules.get("selection_triggers", [])
        flutter_loop_guard_keywords = flutter_rules.get("loop_guard_keywords", [])
        flutter_forbidden_words = flutter_rules.get("forbidden_words", [])
        flutter_write_lock_keywords = flutter_rules.get("write_lock_keywords", [])
        flutter_playhead_clamp_regex = flutter_rules.get("playhead_clamp_regex", [])
        flutter_ffi_keywords = flutter_rules.get("ffi_keywords", [])
        flutter_ffi_finalizer_keywords = flutter_rules.get("ffi_finalizer_keywords", [])
        flutter_ffi_refcount_keywords = flutter_rules.get("ffi_refcount_keywords", [])
        flutter_ui_dirs = flutter_rules.get("ui_directories", [])
        flutter_net_dirs = flutter_rules.get("network_directories", [])
        flutter_viewport_file_patterns = flutter_rules.get("viewport_file_patterns", [])
        flutter_network_file_patterns = flutter_rules.get("network_file_patterns", [])
    else:
        flutter_dir = None
        
    # Resolve Python rules
    python_rules = rules.get("python_rules", {})
    python_exclusions = set(python_rules.get("exclusions", []))
    
    # Resolve Spec rules
    spec_rules = rules.get("spec_rules", {})
    dom_patterns = spec_rules.get("dom_leak_patterns", [])
    pixel_leak_patterns = spec_rules.get("pixel_leak_patterns", [])
    spec_files = spec_rules.get("spec_files", [])
    
    # Dynamically extract forbidden colors from design tokens
    design_tokens_path_rel = spec_rules.get("design_tokens_path")
    if design_tokens_path_rel is None:
        raise ValueError("Missing 'spec_rules.design_tokens_path' in codebase_rules.json")
    design_tokens_path = os.path.join(workspace_dir, design_tokens_path_rel)
    if not os.path.exists(design_tokens_path):
        raise ValueError(f"Design tokens file does not exist at path: {design_tokens_path}")
        
    try:
        with open(design_tokens_path, "r", encoding="utf-8") as f:
            tokens_data = json.load(f)
        forbidden_colors_hex = extract_hex_colors_from_json(tokens_data)
    except Exception as e:
        raise ValueError(f"Failed to load design tokens for compliance check: {e}")
        
    if not forbidden_colors_hex:
        raise ValueError(f"No forbidden design token colors could be extracted from design tokens file at: {design_tokens_path}")
    
    # Generate react colors (lowercase hex values)
    hardcoded_colors_react = {}
    for hex_val in forbidden_colors_hex:
        hardcoded_colors_react[hex_val] = f"Forbidden design token color ({hex_val})"

    # Generate flutter colors (with 0xff prefix and lowercase/uppercase variations)
    hardcoded_colors_flutter = {}
    for hex_val in forbidden_colors_hex:
        clean_hex = hex_val.replace("#", "").lower()
        
        if len(clean_hex) == 3:
            clean_hex = "".join([c*2 for c in clean_hex])
            
        if len(clean_hex) == 8:
            # CSS is RRGGBBAA. Flutter (Dart) is AARRGGBB.
            flutter_hex = clean_hex[6:8] + clean_hex[0:6]
        else:
            flutter_hex = "ff" + clean_hex # Fallback 100% opacity
            
        hardcoded_colors_flutter[flutter_hex] = f"Forbidden design token color (0x{flutter_hex.upper()})"
    
    # 1. React Web Codebase Compliance
    if os.path.exists(react_dir):
        for root, dirs, files in os.walk(react_dir):
            dirs[:] = [d for d in dirs if d not in react_exclusions]
            for file in files:
                if file.endswith(react_exts):
                    filepath = os.path.join(root, file)
                    rel_path = os.path.relpath(filepath, workspace_dir)
                    try:
                        with open(filepath, "r", encoding="utf-8") as f:
                            content = f.read()
                    except UnicodeDecodeError as e:
                        errors.append(f"Compliance Bypass Risk: '{rel_path}' is not valid UTF-8. Binary files are not permitted.")
                        continue
                    except OSError as e:
                        errors.append(f"System Error: Failed to open '{rel_path}' for compliance read: {e}")
                        continue
                    
                    if "design-tokens" in file or "design_tokens" in file:
                        continue
                        
                    # Alarm Color Check
                    content_lower = content.lower()
                    for color, desc in hardcoded_colors_react.items():
                        if color in content_lower:
                            errors.append(f"React File '{rel_path}' contains hardcoded alarm color '{color}' ({desc}). Use CSS custom properties or theme tokens instead.")
                            
                    # Clean/Strip comments for structural/AST logic audits to prevent comment bypasses
                    clean_content = strip_js_comments(content)
                    
                    # Try to inspect using JSON-AST if available
                    ast_path = filepath + ".json-ast"
                    ast_verified = False
                    if os.path.exists(ast_path):
                        try:
                            with open(ast_path, "r", encoding="utf-8") as f:
                                ast_tree = json.load(f)
                            if not walk_json_ast_for_compliance(ast_tree, react_ast_compliance_method, react_rules):
                                errors.append(f"React File '{rel_path}' (AST Verified) fails Event-Echo Guard compliance check.")
                            ast_verified = True
                        except Exception as e:
                            pass
                            
                    # If not verified by AST JSON, run comment-stripped fallback check
                    if not ast_verified:
                        if any(kw in clean_content for kw in react_selection_keywords) and any(kw in clean_content for kw in react_interaction_keywords):
                            if react_ast_compliance_method not in clean_content:
                                errors.append(f"React File '{rel_path}' triggers selection events on user interaction but does not call '{react_ast_compliance_method}()'. This violates the Event-Echo Guard.")
                                
                    # Worker Import Restrictions (Web Workers separation)
                    is_react_ui = False
                    for d in react_ui_dirs:
                        if f"{d}/" in rel_path or rel_path.startswith(f"{d}/"):
                            is_react_ui = True
                            break
                    if is_react_ui:
                        banned_libs = check_banned_imports(content, react_forbidden_words, ".js")
                        if banned_libs:
                            msg = react_rules.get("forbidden_words_message", "UI view/component but imports forbidden libraries directly. Calculations must run exclusively in a background Web Worker.")
                            errors.append(f"React File '{rel_path}' is a {msg}")
 
                    # Egress Write-Lock Check (Network-level Echo Guard)
                    is_react_net = False
                    for d in react_net_dirs:
                        if f"{d}/" in rel_path or rel_path.startswith(f"{d}/"):
                            is_react_net = True
                            break
                    is_react_net_file = False
                    for pat in react_network_file_patterns:
                        if pat in file.lower():
                            is_react_net_file = True
                            break
                    if is_react_net and is_react_net_file:
                        if not any(lock_kw in clean_content.lower() for lock_kw in react_write_lock_keywords):
                            errors.append(f"React Network Gateway File '{rel_path}' does not define a write-lock control to block egress mutations during timeline playback/scrubbing.")
                            
                    # Playhead rate clamps check
                    is_react_viewport = False
                    for pat in react_viewport_file_patterns:
                        if pat in rel_path.lower():
                            is_react_viewport = True
                            break
                    if is_react_viewport:
                        react_playhead_clamp_range = playhead_rate_limits
                        if not all(re.search(pat, clean_content) for pat in react_playhead_clamp_regex):
                            errors.append(f"React Viewport File '{rel_path}' does not implement the mandatory playhead rate clamps {react_playhead_clamp_range} for 4D spatial-temporal viewports.")

    # 2. Flutter Desktop/Web Codebase Compliance
    if os.path.exists(flutter_dir):
        for root, dirs, files in os.walk(flutter_dir):
            dirs[:] = [d for d in dirs if d not in flutter_exclusions]
            for file in files:
                if file.endswith(flutter_exts):
                    filepath = os.path.join(root, file)
                    rel_path = os.path.relpath(filepath, workspace_dir)
                    try:
                        with open(filepath, "r", encoding="utf-8") as f:
                            content = f.read()
                    except UnicodeDecodeError as e:
                        errors.append(f"Compliance Bypass Risk: '{rel_path}' is not valid UTF-8. Binary files are not permitted.")
                        continue
                    except OSError as e:
                        errors.append(f"System Error: Failed to open '{rel_path}' for compliance read: {e}")
                        continue
                        
                    if "design_tokens" in file:
                        continue
                        
                    # Alarm Color Check
                    content_lower = content.lower()
                    for color_val, desc in hardcoded_colors_flutter.items():
                        if color_val in content_lower:
                            errors.append(f"Flutter File '{rel_path}' contains hardcoded alarm color '0x{color_val.upper()}' ({desc}). Reference ThemeData or design-tokens config instead.")
                            
                    clean_content = strip_dart_comments(content)
                    clean_content_lower = clean_content.lower()
                    
                    # Event-Echo Guard Check on comment-stripped code
                    if any(setter in clean_content for setter in flutter_selection_setters):
                        if any(trigger in clean_content for trigger in flutter_selection_triggers):
                            if not any(g in clean_content_lower for g in flutter_loop_guard_keywords):
                                errors.append(f"Flutter File '{rel_path}' contains selection setters and triggers updates, but lacks a loop guard variable (e.g. 'userInitiated' or 'programmatic') to satisfy the Event-Echo Guard.")
                                
                    # Isolate Import Restrictions (Isolates separation)
                    is_flutter_ui = False
                    for d in flutter_ui_dirs:
                        if f"{d}/" in rel_path or rel_path.startswith(f"{d}/"):
                            is_flutter_ui = True
                            break
                    if is_flutter_ui:
                        banned_libs = check_banned_imports(content, flutter_forbidden_words, ".dart")
                        if banned_libs:
                            msg = flutter_rules.get("forbidden_words_message", "UI widget/screen but references forbidden libraries directly. Calculations must run exclusively in a background Isolate.")
                            errors.append(f"Flutter File '{rel_path}' is a {msg}")

                    # Egress Write-Lock Check (Network-level Echo Guard)
                    is_flutter_net = False
                    for d in flutter_net_dirs:
                        if f"{d}/" in rel_path or rel_path.startswith(f"{d}/"):
                            is_flutter_net = True
                            break
                    is_flutter_net_file = False
                    for pat in flutter_network_file_patterns:
                        if pat in file.lower():
                            is_flutter_net_file = True
                            break
                    if is_flutter_net and is_flutter_net_file:
                        if not any(lock_kw in clean_content_lower for lock_kw in flutter_write_lock_keywords):
                            errors.append(f"Flutter Network Gateway File '{rel_path}' does not define a write-lock control to block egress mutations during timeline playback/scrubbing.")
                            
                    # Playhead rate clamps check
                    is_flutter_viewport = False
                    for pat in flutter_viewport_file_patterns:
                        if pat in rel_path.lower():
                            is_flutter_viewport = True
                            break
                    if is_flutter_viewport:
                        flutter_playhead_clamp_range = playhead_rate_limits
                        if not all(re.search(pat, clean_content) for pat in flutter_playhead_clamp_regex):
                            errors.append(f"Flutter Viewport File '{rel_path}' does not implement the mandatory playhead rate clamps {flutter_playhead_clamp_range} for 4D spatial-temporal viewports.")
                            
                    # FFI Memory Safety and Finalizer registration
                    if any(ffi_kw in clean_content for ffi_kw in flutter_ffi_keywords):
                        if not any(fn_kw in clean_content_lower for fn_kw in flutter_ffi_finalizer_keywords):
                            errors.append(f"Flutter FFI File '{rel_path}' does not register a 'NativeFinalizer'. This violates memory safety rules.")
                        if not any(ref_kw in clean_content_lower for ref_kw in flutter_ffi_refcount_keywords):
                            errors.append(f"Flutter FFI File '{rel_path}' does not implement native allocation reference counting.")

    # 3. Python AST-based Hardcoded Constants Audit
    python_scan_dirs = python_rules.get("scan_directories")
    if not python_scan_dirs:
        python_scan_dirs = [workspace_dir]
    else:
        python_scan_dirs = [os.path.join(workspace_dir, d) for d in python_scan_dirs]
        
    for scan_dir in python_scan_dirs:
        if os.path.exists(scan_dir):
            for root, dirs, files in os.walk(scan_dir):
                dirs[:] = [d for d in dirs if d not in python_exclusions]
                for file in files:
                    if file.endswith(".py"):
                        filepath = os.path.join(root, file)
                        ast_err = verify_python_ast(filepath, forbidden_colors_hex)
                        if ast_err:
                            errors.append(ast_err)

    # 4. Check specification files for platform/visual leakage
    for spec_rel_path in spec_files:
        logical_components_path = os.path.join(workspace_dir, spec_rel_path)
        if os.path.exists(logical_components_path):
            try:
                with open(logical_components_path, "r", encoding="utf-8") as f:
                    spec_content = f.read()
                
                # Check for ARIA or role/DOM references
                for pattern in dom_patterns:
                    if re.search(pattern, spec_content, re.IGNORECASE):
                        errors.append(f"Specification '{os.path.basename(logical_components_path)}' contains hardcoded DOM/accessibility leaks matching pattern '{pattern}'.")
                
                # Check for pixel dimensions
                for pattern in pixel_leak_patterns:
                    if re.search(pattern, spec_content, re.IGNORECASE):
                        errors.append(f"Specification '{os.path.basename(logical_components_path)}' contains hardcoded pixel dimensions (e.g., '150px'). Use dynamic configuration tokens instead.")
            except Exception as e:
                errors.append(f"Failed to read specification '{logical_components_path}': {e}")

    return errors


def verify_documentation_consistency(workspace_dir):
    """
    Scans major documentation files (README.md, constitution.md, and platform profiles)
    to ensure they are free from obsolete references (such as color.alarm, ITU-T X.733, JViews TGO).
    """
    errors = []
    doc_files = [
        "README.md",
        ".pipeline/constitution.md",
        ".pipeline/profiles/react.md",
        ".pipeline/profiles/flutter.md"
    ]
    
    obsolete_patterns = [
        (r"color\.alarm\b", "color.alarm (obsolete token namespace)"),
        (r"alarm\.cleared\b", "alarm.cleared (obsolete token namespace)"),
        (r"alarm\.minor\b", "alarm.minor (obsolete token namespace)"),
        (r"alarm\.critical\b", "alarm.critical (obsolete token namespace)"),
    ]
    
    for rel_path in doc_files:
        filepath = os.path.join(workspace_dir, rel_path)
        if not os.path.exists(filepath):
            continue
        try:
            with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
        except Exception as e:
            continue
            
        # Run obsolete pattern checks
        for pattern, name in obsolete_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                errors.append(f"Documentation file '{rel_path}' contains obsolete reference '{name}'. Please update it to standard-agnostic status mappings.")
                
        # Specifically enforce that no ITU-T X.733 color mappings are declared as a requirement
        if "react.md" in rel_path or "flutter.md" in rel_path or "README.md" in rel_path:
            if "X.733" in content:
                errors.append(f"Documentation file '{rel_path}' contains hardcoded reference to 'X.733'. Target profiles and READMEs must remain strictly standard-agnostic.")
                
    return errors





def main():
    workspace_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))

    rules = load_codebase_rules(workspace_dir)
    if not rules:
        raise ValueError("codebase_rules.json is empty or could not be loaded")
        
    backlog_dirs = rules.get("backlog_directories")
    if not backlog_dirs:
        raise ValueError("Missing 'backlog_directories' in codebase_rules.json")

    # Allow overriding paths via command-line args or environment variables.
    schema_dir = (
        sys.argv[1] if len(sys.argv) > 1
        else os.environ.get("SCHEMA_DIR", os.environ.get("YANG_DIR", None))
    )
    if not schema_dir:
        schema_dir_rel = backlog_dirs.get("schemas")
        if not schema_dir_rel:
            raise ValueError("Missing 'backlog_directories.schemas' in codebase_rules.json")
        schema_dir = os.path.join(workspace_dir, schema_dir_rel)

    features_dir = (
        sys.argv[2] if len(sys.argv) > 2
        else os.environ.get("FEATURES_DIR", None)
    )
    if not features_dir:
        features_dir_rel = backlog_dirs.get("features")
        if not features_dir_rel:
            raise ValueError("Missing 'backlog_directories.features' in codebase_rules.json")
        features_dir = os.path.join(workspace_dir, features_dir_rel)

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

    non_yang_extensions = set(rules.get("validation_rules", {}).get("non_yang_extensions", [".yaml", ".yml", ".json", ".proto", ".asn", ".asn1", ".msg", ".srv", ".xsd"]))
    has_yang_schemas = False
    has_non_yang_schemas = False
    if os.path.exists(schema_dir):
        for filename in os.listdir(schema_dir):
            if os.path.isdir(os.path.join(schema_dir, filename)):
                continue
            ext = os.path.splitext(filename)[1].lower()
            if ext == ".yang":
                has_yang_schemas = True
            elif ext in non_yang_extensions:
                has_non_yang_schemas = True

    # 2. Load all feature markdown files
    features = load_feature_files(features_dir)
    print(f"Loaded {len(features)} feature specifications.\n")
    
    skip_coverage_checks = False
    if not features:
        print("Note: No feature specifications found in directory. Skipping model coverage checks.")
        skip_coverage_checks = True
    elif has_non_yang_schemas:
        print("Warning: Deep AST node coverage parity audit is currently optimized for YANG schemas. Skipping strict coverage percentage check for OpenAPI/Protobuf/ASN.1, but proceeding with UML compliance audit.")
        skip_coverage_checks = True
    elif not has_yang_schemas:
        print("Note: No schemas found in schema directory. Skipping model coverage checks.")
        skip_coverage_checks = True

    # 3. Audit coverage per module
    total_defined = 0
    total_covered = 0
    coverage_gaps = {}

    global_classes = build_global_classes(features_dir) if features else {}

    if not skip_coverage_checks and features:
        for module_name, definitions in sorted(modules.items()):
            # Find all feature files that explicitly list this module name in their labels
            matching_features = [f for f in features if module_name in f["labels"]]
            
            # If no features target this module explicitly, it is an auxiliary/unused schema and not a target epic.
            if not matching_features:
                continue

            # Build classes only from the matching features
            local_classes = build_classes_from_features(matching_features, rules)

            module_defined = len(definitions)
            module_covered = 0
            missing = []

            for name in sorted(definitions):
                # Verify node coverage against class/attribute/method names in local_classes
                # Support camelCase and PascalCase variations from kebab-case / snake_case
                variants = {name}
                if '-' in name or '_' in name or '.' in name:
                    parts = re.split(r'[-_.]', name)
                    variants.add(parts[0] + "".join(p.capitalize() for p in parts[1:]))
                    variants.add("".join(p.capitalize() for p in parts))
                else:
                    if name:
                        variants.add(name[0].lower() + name[1:])
                        variants.add(name[0].upper() + name[1:])

                found = False
                if any(v in local_classes for v in variants):
                    found = True
                else:
                    for cls_info in local_classes.values():
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
    uml_errors = []
    if not features:
        print("Note: No feature specifications found. Skipping UML Diagrams Compliance Audit.")
    else:
        uml_errors = verify_uml_diagrams(features_dir, global_classes)
    
    has_failed = False

    if uml_errors:
        print("[!] UML Compliance Violations Identified:")
        for err in uml_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        if features:
            print("Success: All specification files are fully UML-compliant (no ERDs or invalid syntax found).")

    if coverage_gaps:
        print("\n[!] Coverage Gaps Identified:")
        for module_name, missing in sorted(coverage_gaps.items()):
            print(f"  Module '{module_name}' is missing {len(missing)} nodes:")
            print(f"    Missing: {', '.join(missing)}")
        print("\nError: 100% model coverage validation failed.")
        has_failed = True
    else:
        if not skip_coverage_checks and features:
            print("\nSuccess: 100% model coverage verified across all specification files.")

    print("\n=== Behavioral Coverage Triggers Audit ===")
    behavioral_errors = []
    if not features:
        print("Note: No feature specifications found. Skipping Behavioral Coverage Triggers Audit.")
    else:
        behavioral_errors = verify_behavioral_triggers(schema_dir, features_dir, modules)

    if behavioral_errors:
        print("[!] Behavioral Coverage Violations Identified:")
        for err in behavioral_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: All behavioral coverage triggers passed.")

    print("\n=== Codebase AST / Compliance Audit ===")
    codebase_errors = verify_codebase_compliance(workspace_dir)

    if codebase_errors:
        print("[!] Codebase Compliance Violations Identified:")
        for err in codebase_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: Codebase compliance checks passed.")

    print("\n=== Documentation Consistency Audit ===")
    doc_errors = verify_documentation_consistency(workspace_dir)

    if doc_errors:
        print("[!] Documentation Consistency Violations Identified:")
        for err in doc_errors:
            print(f"  - {err}")
        has_failed = True
    else:
        print("Success: Documentation consistency checks passed.")

    if has_failed:
        upstream_repo = rules.get("meta", {}).get("upstream_repository")
        if not upstream_repo:
            raise ValueError("Missing 'meta.upstream_repository' in codebase_rules.json")
        print("\n[!] If you believe this failure is due to a bug or limitation in the pipeline tooling, please report it upstream:")
        print(f"    gh issue create --repo {upstream_repo} --title \"Tooling Bug: [Brief description]\" --body \"Context: UML/Coverage validation failed in downstream execution.\"")
        sys.exit(1)
    else:
        print("\nSuccess: All verification checks passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
