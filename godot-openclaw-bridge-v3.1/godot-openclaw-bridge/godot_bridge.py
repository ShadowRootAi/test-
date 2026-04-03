#!/usr/bin/env python3
"""
Simple HTTP Bridge for Godot OpenClaw Bridge
Production-ready version with comprehensive tools

Usage: python godot_bridge.py
Then access: http://localhost:8080
"""

import http.server
import socketserver
import json
import urllib.request
import urllib.error

GODOT_URL = "http://localhost:7450/mcp"
PORT = 8080

class ThreadedHTTPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    """Handle requests in a separate thread."""
    allow_reuse_address = True
    daemon_threads = True

class GodotBridgeHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        """Handle GET requests - FAST version"""
        try:
            # Parse query string
            from urllib.parse import parse_qs, urlparse
            parsed = urlparse(self.path)
            params = parse_qs(parsed.query)
            
            command = params.get('cmd', ['help'])[0]
            
            # Fast dispatch
            handler = self._get_handler(command)
            if handler:
                response = handler(params)
            else:
                response = {"error": f"Unknown command: {command}"}
            
            # Send response
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response, separators=(',', ':')).encode())
            
        except Exception as e:
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())
    
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
            'set_property': self._cmd_set_property,
            'add_script': self._cmd_add_script,
            'edit_script': self._cmd_edit_script,
            'run_game': self._cmd_run_game,
            'stop_game': self._cmd_stop_game,
            'list_files': self._cmd_list_files,
            'read_file': self._cmd_read_file,
            'write_file': self._cmd_write_file,
            'delete_file': self._cmd_delete_file,
        }
        return handlers.get(command)
    
    def _cmd_help(self, params):
        return {
            "message": "Godot Bridge v2.1 - FAST",
            "commands": [
                "help", "status", "create_scene", "save_scene", "get_scene_tree",
                "add_node", "create_sprite", "create_color_rect", "remove_node",
                "set_property", "add_script", "edit_script", "run_game", "stop_game",
                "list_files", "read_file", "write_file", "delete_file"
            ]
        }
    
    def _cmd_status(self, params):
        return self._call_godot("get_project_info", {})
    
    def _cmd_create_scene(self, params):
        return self._call_godot("create_scene", {
            "scene_name": params.get('name', ['NewScene'])[0],
            "root_type": params.get('root', ['Node2D'])[0]
        })
    
    def _cmd_save_scene(self, params):
        return self._call_godot("save_scene", {})
    
    def _cmd_get_scene_tree(self, params):
        return self._call_godot("get_scene_tree", {})
    
    def _cmd_add_node(self, params):
        return self._call_godot("add_node", {
            "parent_path": params.get('parent', ['.'])[0],
            "node_name": params.get('name', ['Node'])[0],
            "node_type": params.get('type', ['Node2D'])[0]
        })
    
    def _cmd_create_sprite(self, params):
        return self._call_godot("create_sprite", {
            "parent_path": params.get('parent', ['.'])[0],
            "name": params.get('name', ['Sprite'])[0],
            "position": {
                "x": float(params.get('x', ['0'])[0]),
                "y": float(params.get('y', ['0'])[0])
            },
            "size": int(params.get('size', ['64'])[0]),
            "color": {
                "r": float(params.get('r', ['1'])[0]),
                "g": float(params.get('g', ['0'])[0]),
                "b": float(params.get('b', ['0'])[0])
            }
        })
    
    def _cmd_create_color_rect(self, params):
        return self._call_godot("create_color_rect", {
            "parent_path": params.get('parent', ['.'])[0],
            "name": params.get('name', ['ColorRect'])[0],
            "position": {
                "x": float(params.get('x', ['0'])[0]),
                "y": float(params.get('y', ['0'])[0])
            },
            "size": {
                "width": float(params.get('w', ['100'])[0]),
                "height": float(params.get('h', ['100'])[0])
            },
            "color": {
                "r": float(params.get('r', ['1'])[0]),
                "g": float(params.get('g', ['0'])[0]),
                "b": float(params.get('b', ['0'])[0]),
                "a": 1
            }
        })
    
    def _cmd_remove_node(self, params):
        node = params.get('node', [''])[0] or params.get('name', [''])[0] or params.get('path', [''])[0]
        return self._call_godot("remove_node", {"node_path": node})
    
    def _cmd_set_property(self, params):
        return self._call_godot("set_property", {
            "node_path": params.get('node', [''])[0],
            "property": params.get('prop', [''])[0],
            "value": params.get('value', [''])[0]
        })
    
    def _cmd_add_script(self, params):
        return self._call_godot("add_script", {
            "node_path": params.get('node', [''])[0],
            "code": params.get('code', [''])[0]
        })
    
    def _cmd_edit_script(self, params):
        return self._call_godot("edit_script", {
            "script_path": params.get('path', [''])[0],
            "code": params.get('code', [''])[0]
        })
    
    def _cmd_run_game(self, params):
        return self._call_godot("run_game", {})
    
    def _cmd_stop_game(self, params):
        return self._call_godot("stop_game", {})
    
    def _cmd_list_files(self, params):
        return self._call_godot("list_files", {"path": params.get('path', ['res://'])[0]})
    
    def _cmd_read_file(self, params):
        return self._call_godot("read_file", {"path": params.get('path', [''])[0]})
    
    def _cmd_write_file(self, params):
        return self._call_godot("write_file", {
            "path": params.get('path', [''])[0],
            "content": params.get('content', [''])[0]
        })
    
    def _cmd_delete_file(self, params):
        return self._call_godot("delete_file", {"path": params.get('path', [''])[0]})
    
    def do_POST(self):
        """Handle POST requests - FAST"""
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            
            data = json.loads(post_data)
            response = self._call_godot(data.get('tool', 'get_project_info'), data.get('args', {}))
            
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response, separators=(',', ':')).encode())
            
        except Exception as e:
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())
    
    def _call_godot(self, tool_name: str, args: dict) -> dict:
        """FAST call to Godot - 1 second timeout"""
        request_data = {
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {"name": tool_name, "arguments": args},
            "id": 1
        }
        
        try:
            req = urllib.request.Request(
                GODOT_URL,
                data=json.dumps(request_data, separators=(',', ':')).encode(),
                headers={"Content-Type": "application/json"},
                method="POST"
            )
            # FAST timeout - 1 second for local connection
            with urllib.request.urlopen(req, timeout=1) as response:
                mcp_response = json.loads(response.read().decode())
                if "result" in mcp_response and "content" in mcp_response["result"]:
                    content = mcp_response["result"]["content"]
                    if content and len(content) > 0 and "text" in content[0]:
                        try:
                            return json.loads(content[0]["text"])
                        except:
                            return {"result": content[0]["text"]}
                return mcp_response
        except urllib.error.URLError:
            return {"error": "Godot not running on localhost:7450"}
        except Exception as e:
            return {"error": str(e)}
    
    def log_message(self, format, *args):
        pass

def main():
    print("=" * 60)
    print("🎮 Godot Bridge v2.1 - FAST MODE")
    print("=" * 60)
    print(f"\n⚡ Running on: http://localhost:{PORT}")
    print(f"⚡ Connected to Godot: http://localhost:7450")
    print(f"⚡ Timeout: 1 second (fast!)")
    print(f"⚡ Threaded: Yes (handles multiple requests)")
    print("\n📚 Examples:")
    print(f"  curl 'http://localhost:{PORT}/?cmd=create_sprite&name=Hero&x=100&y=100'")
    print(f"  curl 'http://localhost:{PORT}/?cmd=run_game'")
    print("\nPress Ctrl+C to stop")
    print("=" * 60)
    
    # Use threaded server for concurrent connections
    with ThreadedHTTPServer(("", PORT), GodotBridgeHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n⚡ Bridge stopped.")

if __name__ == "__main__":
    main()
