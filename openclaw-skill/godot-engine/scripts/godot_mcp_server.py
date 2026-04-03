#!/usr/bin/env python3
"""
MCP Server for Godot Engine Bridge
Runs as stdio server that forwards requests to Godot HTTP server
"""

import sys
import json
import urllib.request
import urllib.error

GODOT_HOST = "http://localhost:7450"

def send_request(method: str, params: dict = None) -> dict:
    """Send JSON-RPC request to Godot server"""
    request_data = {
        "jsonrpc": "2.0",
        "method": method,
        "params": params or {},
        "id": 1
    }
    
    req = urllib.request.Request(
        f"{GODOT_HOST}/mcp",
        data=json.dumps(request_data).encode(),
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.loads(response.read().decode())
    except urllib.error.URLError as e:
        return {
            "jsonrpc": "2.0",
            "error": {"code": -32000, "message": f"Cannot connect to Godot: {e}"},
            "id": 1
        }
    except Exception as e:
        return {
            "jsonrpc": "2.0",
            "error": {"code": -32000, "message": str(e)},
            "id": 1
        }

def handle_initialize(params: dict) -> dict:
    return {
        "protocolVersion": "2024-11-05",
        "capabilities": {"tools": {}},
        "serverInfo": {"name": "godot-engine-mcp", "version": "1.0.0"}
    }

def handle_tools_list(params: dict) -> dict:
    """Return available tools"""
    return {
        "tools": [
            {
                "name": "get_project_info",
                "description": "Get information about the current Godot project including name, path, version, and main scene",
                "inputSchema": {"type": "object", "properties": {}}
            },
            {
                "name": "get_scene_tree",
                "description": "Get the current scene tree structure with all nodes and their hierarchy",
                "inputSchema": {"type": "object", "properties": {}}
            },
            {
                "name": "create_scene",
                "description": "Create a new scene file with a root node",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "scene_name": {"type": "string", "description": "Name of the new scene"},
                        "root_type": {"type": "string", "default": "Node2D", "description": "Type of root node (Node2D, Node3D, Control, etc.)"}
                    },
                    "required": ["scene_name"]
                }
            },
            {
                "name": "save_scene",
                "description": "Save the currently edited scene",
                "inputSchema": {"type": "object", "properties": {}}
            },
            {
                "name": "add_node",
                "description": "Add a new node to the current scene",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "parent_path": {"type": "string", "description": "NodePath of parent (e.g., '/root' or '.')"},
                        "node_name": {"type": "string", "description": "Name for the new node"},
                        "node_type": {"type": "string", "description": "Godot node type (Sprite2D, CollisionShape2D, etc.)"},
                        "properties": {"type": "object", "description": "Optional properties to set"}
                    },
                    "required": ["parent_path", "node_name", "node_type"]
                }
            },
            {
                "name": "remove_node",
                "description": "Remove a node from the scene",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "node_path": {"type": "string", "description": "NodePath to remove"}
                    },
                    "required": ["node_path"]
                }
            },
            {
                "name": "set_property",
                "description": "Set a property value on a node",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "node_path": {"type": "string"},
                        "property": {"type": "string", "description": "Property name (position, modulate, texture, etc.)"},
                        "value": {"description": "Value to set"}
                    },
                    "required": ["node_path", "property", "value"]
                }
            },
            {
                "name": "get_property",
                "description": "Get a property value from a node",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "node_path": {"type": "string"},
                        "property": {"type": "string"}
                    },
                    "required": ["node_path", "property"]
                }
            },
            {
                "name": "add_script",
                "description": "Add a GDScript to a node",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "node_path": {"type": "string"},
                        "code": {"type": "string", "description": "Optional custom script code"}
                    },
                    "required": ["node_path"]
                }
            },
            {
                "name": "edit_script",
                "description": "Edit an existing script file",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "script_path": {"type": "string", "description": "Path like res://Player.gd"},
                        "code": {"type": "string", "description": "New script content"}
                    },
                    "required": ["script_path", "code"]
                }
            },
            {
                "name": "run_game",
                "description": "Run/play the current scene from editor",
                "inputSchema": {"type": "object", "properties": {}}
            },
            {
                "name": "stop_game",
                "description": "Stop the running game",
                "inputSchema": {"type": "object", "properties": {}}
            },
            {
                "name": "list_files",
                "description": "List files in a project directory",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "path": {"type": "string", "default": "res://", "description": "Directory path"}
                    }
                }
            },
            {
                "name": "read_file",
                "description": "Read content of a project file",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "path": {"type": "string", "description": "File path like res://script.gd"}
                    },
                    "required": ["path"]
                }
            },
            {
                "name": "write_file",
                "description": "Write content to a project file",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "path": {"type": "string"},
                        "content": {"type": "string"}
                    },
                    "required": ["path", "content"]
                }
            }
        ]
    }

def handle_tools_call(params: dict) -> dict:
    """Forward tool call to Godot server"""
    tool_name = params.get("name")
    arguments = params.get("arguments", {})
    
    result = send_request("tools/call", {
        "name": tool_name,
        "arguments": arguments
    })
    
    if "error" in result:
        return {"content": [{"type": "text", "text": json.dumps(result["error"])}], "isError": True}
    
    return result.get("result", {"content": [{"type": "text", "text": "{}"}]})

def main():
    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break
            
            message = json.loads(line)
            method = message.get("method")
            params = message.get("params", {})
            msg_id = message.get("id")
            
            result = None
            
            if method == "initialize":
                result = handle_initialize(params)
            elif method == "tools/list":
                result = handle_tools_list(params)
            elif method == "tools/call":
                result = handle_tools_call(params)
            elif method == "notifications/initialized":
                continue
            else:
                result = {"error": {"code": -32601, "message": f"Method not found: {method}"}}
            
            if msg_id is not None:
                response = {
                    "jsonrpc": "2.0",
                    "result": result,
                    "id": msg_id
                }
                print(json.dumps(response), flush=True)
                
        except json.JSONDecodeError as e:
            error_response = {
                "jsonrpc": "2.0",
                "error": {"code": -32700, "message": f"Parse error: {e}"},
                "id": None
            }
            print(json.dumps(error_response), flush=True)
        except Exception as e:
            error_response = {
                "jsonrpc": "2.0",
                "error": {"code": -32000, "message": str(e)},
                "id": None
            }
            print(json.dumps(error_response), flush=True)

if __name__ == "__main__":
    main()