#!/usr/bin/env python3
"""
Godot Bridge v3.0 - Ultra-Fast Human-Like Control
Fixed script bugs, added batch operations, connection pooling

Usage: python godot_bridge_v3.py
"""

import http.server
import socketserver
import json
import urllib.request
import urllib.error
import urllib.parse
from http.client import HTTPConnection
from threading import Lock
import time

GODOT_URL = "http://localhost:7450/mcp"
PORT = 8080

# Connection pool for speed
_connection_pool = []
_pool_lock = Lock()
_pool_size = 5

def _get_connection():
    """Get connection from pool or create new"""
    with _pool_lock:
        if _connection_pool:
            return _connection_pool.pop()
    return HTTPConnection("localhost", 7450, timeout=2)

def _return_connection(conn):
    """Return connection to pool"""
    with _pool_lock:
        if len(_connection_pool) < _pool_size:
            _connection_pool.append(conn)
        else:
            conn.close()

class ThreadedHTTPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True
    daemon_threads = True

class GodotBridgeHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()
    
    def do_GET(self):
        """Fast GET handler"""
        start_time = time.time()
        try:
            parsed = urllib.parse.urlparse(self.path)
            params = urllib.parse.parse_qs(parsed.query)
            
            # Convert single-value lists to scalars
            params = {k: v[0] if len(v) == 1 else v for k, v in params.items()}
            
            command = params.get('cmd', 'help')
            handler = self._get_handler(command)
            
            if handler:
                response = handler(params)
            else:
                response = {"error": f"Unknown command: {command}"}
            
            response["_timing"] = {"total_ms": round((time.time() - start_time) * 1000, 2)}
            
            self._send_json(200, response)
            
        except Exception as e:
            self._send_json(500, {"error": str(e), "_timing": {"total_ms": round((time.time() - start_time) * 1000, 2)}})
    
    def do_POST(self):
        """POST handler with batch support"""
        start_time = time.time()
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data)
            
            # Check for batch commands
            if 'batch' in data:
                response = self._handle_batch(data['batch'])
            else:
                tool_name = data.get('tool') or data.get('cmd')
                args = data.get('args') or data.get('params') or {}
                response = self._call_godot_fast(tool_name, args)
            
            response["_timing"] = {"total_ms": round((time.time() - start_time) * 1000, 2)}
            self._send_json(200, response)
            
        except Exception as e:
            self._send_json(500, {"error": str(e), "_timing": {"total_ms": round((time.time() - start_time) * 1000, 2)}})
    
    def _send_json(self, status, data):
        """Send JSON response"""
        body = json.dumps(data, separators=(',', ':'), default=str).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Length", len(body))
        self.end_headers()
        self.wfile.write(body)
    
    def _handle_batch(self, commands):
        """Execute multiple commands in sequence"""
        results = []
        errors = []
        
        for i, cmd in enumerate(commands):
            cmd_name = cmd.get('cmd') or cmd.get('tool')
            if not cmd_name:
                errors.append({"index": i, "error": "No command specified"})
                continue
            
            try:
                handler = self._get_handler(cmd_name)
                if handler:
                    result = handler(cmd)
                    results.append({"index": i, "cmd": cmd_name, "result": result})
                else:
                    errors.append({"index": i, "cmd": cmd_name, "error": "Unknown command"})
            except Exception as e:
                errors.append({"index": i, "cmd": cmd_name, "error": str(e)})
        
        return {
            "batch": True,
            "completed": len(results),
            "errors": len(errors),
            "results": results,
            "error_details": errors if errors else None
        }
    
    def _get_handler(self, command):
        handlers = {
            'help': self._cmd_help,
            'status': self._cmd_status,
            'create_scene': self._cmd_create_scene,
            'save_scene': self._cmd_save_scene,
            'get_scene_tree': self._cmd_get_scene_tree,
            'add_node': self._cmd_add_node,
            'create_sprite': self._cmd_create_sprite,
            'create_color_rect': self._cmd_create_color_rect,
            'remove_node': self._cmd_remove_node,
            'duplicate_node': self._cmd_duplicate_node,
            'reparent_node': self._cmd_reparent_node,
            'rename_node': self._cmd_rename_node,
            'set_property': self._cmd_set_property,
            'set_properties': self._cmd_set_properties,
            'get_property': self._cmd_get_property,
            'add_script': self._cmd_add_script,
            'edit_script': self._cmd_edit_script,
            'get_script': self._cmd_get_script,
            'reload_scripts': self._cmd_reload_scripts,
            'run_game': self._cmd_run_game,
            'stop_game': self._cmd_stop_game,
            'list_files': self._cmd_list_files,
            'read_file': self._cmd_read_file,
            'write_file': self._cmd_write_file,
            'delete_file': self._cmd_delete_file,
            'get_node_info': self._cmd_get_node_info,
            'select_node': self._cmd_select_node,
            'get_selected_nodes': self._cmd_get_selected_nodes,
            'undo': self._cmd_undo,
            'redo': self._cmd_redo,
            'clear_output': self._cmd_clear_output,
            'create_collision_shape': lambda p: self._call_godot_fast("create_collision_shape", {"parent_path": p.get("parent", "."), "width": float(p.get("w", 32)), "height": float(p.get("h", 32))}),
            'create_camera': lambda p: self._call_godot_fast("create_camera", {"parent_path": p.get("parent", "."), "zoom": float(p.get("zoom", 1)), "smoothing": p.get("smoothing", True)}),
            'create_label': lambda p: self._call_godot_fast("create_label", {"parent_path": p.get("parent", "."), "name": p.get("name", "Label"), "text": p.get("text", ""), "font_size": int(p.get("font_size", 16)), "position": {"x": float(p.get("x", 0)), "y": float(p.get("y", 0))}}),
            'create_area2d': lambda p: self._call_godot_fast("create_area2d", {"parent_path": p.get("parent", "."), "name": p.get("name", "Area2D"), "width": float(p.get("w", 32)), "height": float(p.get("h", 32))}),
            'create_timer_node': lambda p: self._call_godot_fast("create_timer_node", {"parent_path": p.get("parent", "."), "name": p.get("name", "Timer"), "wait_time": float(p.get("wait_time", 1)), "one_shot": p.get("one_shot", False), "autostart": p.get("autostart", False)}),
            'create_full_character': lambda p: self._call_godot_fast("create_full_character", {"parent_path": p.get("parent", "."), "name": p.get("name", "Player"), "char_type": p.get("char_type", "platformer"), "width": float(p.get("w", 32)), "height": float(p.get("h", 48)), "color": {"r": float(p.get("r", 0.2)), "g": float(p.get("g", 0.6)), "b": float(p.get("b", 1))}}),
            'set_main_scene': lambda p: self._call_godot_fast("set_main_scene", {"scene_path": p.get("path", "")}),
            'batch': lambda p: {"error": "Use POST for batch commands"},
        }
        return handlers.get(command)
    
    # ═══════════════════════════════════════════════════════════════
    # COMMAND HANDLERS
    # ═══════════════════════════════════════════════════════════════
    
    def _cmd_help(self, params):
        return {
            "version": "3.1",
            "message": "Godot Bridge v3.1 - Fixed & Enhanced",
            "commands": [
                "help", "status", "create_scene", "save_scene", "get_scene_tree",
                "add_node", "create_sprite", "create_color_rect", "remove_node",
                "duplicate_node", "reparent_node", "rename_node",
                "set_property", "set_properties", "get_property",
                "add_script", "edit_script", "get_script", "reload_scripts",
                "run_game", "stop_game", "list_files", "read_file", "write_file", "delete_file",
                "get_node_info", "select_node", "get_selected_nodes",
                "undo", "redo", "clear_output",
                "create_collision_shape", "create_camera", "create_label",
                "create_area2d", "create_timer_node", "create_full_character",
                "set_main_scene"
            ],
            "batch_support": "Use POST with {'batch': [{'cmd': '...'}, ...]}",
            "new_in_v31": [
                "create_full_character - Complete character in one call (platformer/topdown)",
                "create_collision_shape - CollisionShape2D helper",
                "create_camera - Camera2D with zoom/smoothing",
                "create_label - UI text with font size",
                "create_area2d - Trigger zones with collision",
                "create_timer_node - Timer node",
                "set_main_scene - Set F5 launch scene"
            ]
        }
    
    def _cmd_status(self, params):
        return self._call_godot_fast("get_project_info", {})
    
    def _cmd_create_scene(self, params):
        return self._call_godot_fast("create_scene", {
            "scene_name": params.get('name', 'NewScene'),
            "root_type": params.get('root', 'Node2D')
        })
    
    def _cmd_save_scene(self, params):
        return self._call_godot_fast("save_scene", {})
    
    def _cmd_get_scene_tree(self, params):
        return self._call_godot_fast("get_scene_tree", {})
    
    def _cmd_add_node(self, params):
        return self._call_godot_fast("add_node", {
            "parent_path": params.get('parent', '.'),
            "node_name": params.get('name', 'Node'),
            "node_type": params.get('type', 'Node2D'),
            "properties": params.get('properties', {})
        })
    
    def _cmd_create_sprite(self, params):
        return self._call_godot_fast("create_sprite", {
            "parent_path": params.get('parent', '.'),
            "name": params.get('name', 'Sprite'),
            "position": {"x": float(params.get('x', 0)), "y": float(params.get('y', 0))},
            "size": int(params.get('size', 64)),
            "color": {
                "r": float(params.get('r', 1)),
                "g": float(params.get('g', 0)),
                "b": float(params.get('b', 0))
            }
        })
    
    def _cmd_create_color_rect(self, params):
        return self._call_godot_fast("create_color_rect", {
            "parent_path": params.get('parent', '.'),
            "name": params.get('name', 'ColorRect'),
            "position": {"x": float(params.get('x', 0)), "y": float(params.get('y', 0))},
            "size": {"width": float(params.get('w', 100)), "height": float(params.get('h', 100))},
            "color": {
                "r": float(params.get('r', 1)),
                "g": float(params.get('g', 0)),
                "b": float(params.get('b', 0)),
                "a": float(params.get('a', 1))
            }
        })
    
    def _cmd_remove_node(self, params):
        node = params.get('node') or params.get('name') or params.get('path', '')
        return self._call_godot_fast("remove_node", {"node_path": node})
    
    def _cmd_duplicate_node(self, params):
        return self._call_godot_fast("duplicate_node", {
            "node_path": params.get('node', ''),
            "new_name": params.get('new_name', '')
        })
    
    def _cmd_reparent_node(self, params):
        return self._call_godot_fast("reparent_node", {
            "node_path": params.get('node', ''),
            "new_parent": params.get('parent', '')
        })
    
    def _cmd_rename_node(self, params):
        return self._call_godot_fast("rename_node", {
            "node_path": params.get('node', ''),
            "new_name": params.get('new_name', '')
        })
    
    def _cmd_set_property(self, params):
        return self._call_godot_fast("set_property", {
            "node_path": params.get('node', ''),
            "property": params.get('prop', ''),
            "value": params.get('value')
        })
    
    def _cmd_set_properties(self, params):
        return self._call_godot_fast("set_properties", {
            "node_path": params.get('node', ''),
            "properties": params.get('properties', {})
        })
    
    def _cmd_get_property(self, params):
        return self._call_godot_fast("get_property", {
            "node_path": params.get('node', ''),
            "property": params.get('prop', '')
        })
    
    def _cmd_add_script(self, params):
        """Add script with verification"""
        return self._call_godot_fast("add_script", {
            "node_path": params.get('node', ''),
            "code": params.get('code', ''),
            "script_name": params.get('script_name', ''),
            "auto_reload": params.get('auto_reload', True)
        })
    
    def _cmd_edit_script(self, params):
        return self._call_godot_fast("edit_script", {
            "script_path": params.get('path', ''),
            "code": params.get('code', '')
        })
    
    def _cmd_get_script(self, params):
        return self._call_godot_fast("get_script_content", {
            "script_path": params.get('path', '')
        })
    
    def _cmd_reload_scripts(self, params):
        return self._call_godot_fast("reload_scripts", {})
    
    def _cmd_run_game(self, params):
        return self._call_godot_fast("run_game", {})
    
    def _cmd_stop_game(self, params):
        return self._call_godot_fast("stop_game", {})
    
    def _cmd_list_files(self, params):
        return self._call_godot_fast("list_files", {"path": params.get('path', 'res://')})
    
    def _cmd_read_file(self, params):
        return self._call_godot_fast("read_file", {"path": params.get('path', '')})
    
    def _cmd_write_file(self, params):
        return self._call_godot_fast("write_file", {
            "path": params.get('path', ''),
            "content": params.get('content', '')
        })
    
    def _cmd_delete_file(self, params):
        return self._call_godot_fast("delete_file", {"path": params.get('path', '')})
    
    def _cmd_get_node_info(self, params):
        return self._call_godot_fast("get_node_info", {"node_path": params.get('node', '')})
    
    def _cmd_select_node(self, params):
        return self._call_godot_fast("select_node", {"node_path": params.get('node', '')})
    
    def _cmd_get_selected_nodes(self, params):
        return self._call_godot_fast("get_selected_nodes", {})
    
    def _cmd_undo(self, params):
        return self._call_godot_fast("undo", {})
    
    def _cmd_redo(self, params):
        return self._call_godot_fast("redo", {})
    
    def _cmd_clear_output(self, params):
        return self._call_godot_fast("clear_output", {})
    
    # ═══════════════════════════════════════════════════════════════
    # FAST GODOT CALL (with connection pooling)
    # ═══════════════════════════════════════════════════════════════
    
    def _call_godot_fast(self, tool_name: str, args: dict) -> dict:
        """Ultra-fast call using connection pool with stale connection recovery"""
        request_data = {
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {"name": tool_name, "arguments": args},
            "id": 1
        }
        
        body = json.dumps(request_data, separators=(',', ':')).encode()
        
        # Try pooled connection first, fall back to new one
        for attempt in range(2):
            conn = None
            try:
                conn = _get_connection() if attempt == 0 else HTTPConnection("localhost", 7450, timeout=5)
                
                conn.request("POST", "/mcp", body=body, headers={
                    "Content-Type": "application/json",
                    "Content-Length": str(len(body))
                })
                
                response = conn.getresponse()
                mcp_response = json.loads(response.read().decode())
                
                if "result" in mcp_response and "content" in mcp_response["result"]:
                    content = mcp_response["result"]["content"]
                    if content and len(content) > 0 and "text" in content[0]:
                        try:
                            return json.loads(content[0]["text"])
                        except:
                            return {"result": content[0]["text"]}
                
                return mcp_response
                
            except (ConnectionRefusedError, OSError):
                if conn:
                    try: conn.close()
                    except: pass
                if attempt == 0:
                    continue  # Retry with fresh connection
                return {"error": "Cannot connect to Godot on port 7450. Is the plugin enabled?", "tool": tool_name}
            except Exception as e:
                if conn:
                    try: conn.close()
                    except: pass
                if attempt == 0:
                    continue
                return {"error": str(e), "tool": tool_name}
            finally:
                if conn and attempt == 0:
                    try: _return_connection(conn)
                    except: pass
        
        return {"error": "Failed after retries", "tool": tool_name}

def main():
    print("=" * 60)
    print("🎮 Godot Bridge v3.1 - FIXED & ENHANCED")
    print("=" * 60)
    print(f"⚡ HTTP Server: http://localhost:{PORT}")
    print(f"⚡ Connection Pool: {_pool_size} connections (with stale recovery)")
    print(f"⚡ Batch Commands: Supported")
    print(f"⚡ Game Dev Tools: create_full_character, collision, camera...")
    print(f"⚡ Bug Fixes: plugin loader, Content-Length, reparent, parse_value")
    print("\n📚 Quick Test:")
    print(f"  curl 'http://localhost:{PORT}/?cmd=status'")
    print(f"  curl 'http://localhost:{PORT}/?cmd=help'")
    print("\nPress Ctrl+C to stop")
    print("=" * 60)
    
    with ThreadedHTTPServer(("", PORT), GodotBridgeHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n⚡ Bridge stopped.")

if __name__ == "__main__":
    main()
