@tool
extends Node

# OpenClaw MCP Bridge for Godot Editor
# Production-ready version with comprehensive tools

var editor_plugin: EditorPlugin
var tcp_server: TCPServer
var clients: Array[StreamPeerTCP] = []

const PORT = 7450
const BUFFER_SIZE = 4096

# Available tools/commands
var tools: Dictionary = {
	"get_project_info": _get_project_info,
	"get_scene_tree": _get_scene_tree,
	"create_scene": _create_scene,
	"save_scene": _save_scene,
	"add_node": _add_node,
	"create_sprite": _create_sprite,
	"create_color_rect": _create_color_rect,
	"remove_node": _remove_node,
	"set_property": _set_property,
	"set_properties": _set_properties,
	"add_script": _add_script,
	"edit_script": _edit_script,
	"run_game": _run_game,
	"stop_game": _stop_game,
	"get_output": _get_output,
	"list_files": _list_files,
	"read_file": _read_file,
	"write_file": _write_file,
	"delete_file": _delete_file,
}

func _ready():
	start_server()

func _process(_delta):
	# Accept new connections
	if tcp_server and tcp_server.is_connection_available():
		var client = tcp_server.take_connection()
		clients.append(client)
		print("[OpenClaw] Client connected")
	
	# Handle existing clients
	for i in range(clients.size() - 1, -1, -1):
		var client = clients[i]
		if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			clients.remove_at(i)
			continue
		
		var bytes_available = client.get_available_bytes()
		if bytes_available > 0:
			var data = client.get_utf8_string(bytes_available)
			_handle_request(client, data)

func start_server():
	tcp_server = TCPServer.new()
	var err = tcp_server.listen(PORT)
	if err == OK:
		print("[OpenClaw] MCP server listening on port ", PORT)
	else:
		push_error("[OpenClaw] Failed to start server on port " + str(PORT))

func stop_server():
	for client in clients:
		client.disconnect_from_host()
	clients.clear()
	if tcp_server:
		tcp_server.stop()
		print("[OpenClaw] Server stopped")

func _handle_request(client: StreamPeerTCP, data: String):
	# Simple HTTP request parsing
	var lines = data.split("\r\n")
	if lines.size() < 1:
		return
	
	var request_line = lines[0]
	var parts = request_line.split(" ")
	if parts.size() < 3:
		_send_error(client, 400, "Bad Request")
		return
	
	var method = parts[0]
	var path = parts[1]
	
	# Handle POST /mcp for JSON-RPC
	if method == "POST" and path == "/mcp":
		_handle_mcp_request(client, data)
	elif method == "GET" and path == "/health":
		_send_json(client, 200, {"status": "ok", "godot_version": Engine.get_version_info()})
	else:
		_send_error(client, 404, "Not Found")

func _handle_mcp_request(client: StreamPeerTCP, data: String):
	# Extract body from HTTP request
	var body_start = data.find("\r\n\r\n")
	if body_start == -1:
		_send_error(client, 400, "Missing body")
		return
	
	var body = data.substr(body_start + 4)
	var json = JSON.new()
	var err = json.parse(body)
	
	if err != OK:
		_send_json(client, 400, {
			"jsonrpc": "2.0",
			"error": {"code": -32700, "message": "Parse error"},
			"id": null
		})
		return
	
	var request = json.get_data()
	var response = _process_mcp_request(request)
	_send_json(client, 200, response)

func _process_mcp_request(request: Dictionary) -> Dictionary:
	var jsonrpc = request.get("jsonrpc", "")
	var method = request.get("method", "")
	var params = request.get("params", {})
	var id = request.get("id", null)
	
	if jsonrpc != "2.0":
		return {
			"jsonrpc": "2.0",
			"error": {"code": -32600, "message": "Invalid Request"},
			"id": id
		}
	
	# Handle standard MCP methods
	match method:
		"initialize":
			return {
				"jsonrpc": "2.0",
				"result": {
					"protocolVersion": "2024-11-05",
					"capabilities": {"tools": {}},
					"serverInfo": {"name": "godot-openclaw-bridge", "version": "2.0.0"}
				},
				"id": id
			}
		
		"tools/list":
			return {
				"jsonrpc": "2.0",
				"result": {"tools": _get_tool_definitions()},
				"id": id
			}
		
		"tools/call":
			return _handle_tool_call(params, id)
		
		_:
			return {
				"jsonrpc": "2.0",
				"error": {"code": -32601, "message": "Method not found: " + method},
				"id": id
			}

func _get_tool_definitions() -> Array:
	return [
		{
			"name": "get_project_info",
			"description": "Get information about the current Godot project",
			"inputSchema": {"type": "object", "properties": {}}
		},
		{
			"name": "get_scene_tree",
			"description": "Get the current scene tree structure with valid node paths",
			"inputSchema": {"type": "object", "properties": {}}
		},
		{
			"name": "create_scene",
			"description": "Create a new scene with a root node",
			"inputSchema": {
				"type": "object",
				"properties": {
					"scene_name": {"type": "string"},
					"root_type": {"type": "string", "default": "Node2D"}
				},
				"required": ["scene_name"]
			}
		},
		{
			"name": "add_node",
			"description": "Add a node to the current scene with optional properties",
			"inputSchema": {
				"type": "object",
				"properties": {
					"parent_path": {"type": "string", "description": "Path to parent node (use '.' for root)"},
					"node_name": {"type": "string"},
					"node_type": {"type": "string"},
					"properties": {"type": "object", "description": "Optional properties like position, size, color"}
				},
				"required": ["parent_path", "node_name", "node_type"]
			}
		},
		{
			"name": "create_sprite",
			"description": "Create a Sprite2D with a colored rectangle texture",
			"inputSchema": {
				"type": "object",
				"properties": {
					"parent_path": {"type": "string", "default": "."},
					"name": {"type": "string"},
					"position": {"type": "object", "properties": {"x": {"type": "number"}, "y": {"type": "number"}}},
					"size": {"type": "integer", "default": 64},
					"color": {"type": "object", "properties": {"r": {"type": "number"}, "g": {"type": "number"}, "b": {"type": "number"}}}
				},
				"required": ["name"]
			}
		},
		{
			"name": "create_color_rect",
			"description": "Create a ColorRect node with specified color and size",
			"inputSchema": {
				"type": "object",
				"properties": {
					"parent_path": {"type": "string", "default": "."},
					"name": {"type": "string"},
					"position": {"type": "object", "properties": {"x": {"type": "number"}, "y": {"type": "number"}}},
					"size": {"type": "object", "properties": {"width": {"type": "number"}, "height": {"type": "number"}}},
					"color": {"type": "object", "properties": {"r": {"type": "number"}, "g": {"type": "number"}, "b": {"type": "number"}, "a": {"type": "number"}}}
				},
				"required": ["name"]
			}
		},
		{
			"name": "remove_node",
			"description": "Remove/delete a node from the current scene by name or path",
			"inputSchema": {
				"type": "object",
				"properties": {
					"node_path": {"type": "string", "description": "Node name or path"}
				},
				"required": ["node_path"]
			}
		},
		{
			"name": "set_property",
			"description": "Set a single property on a node",
			"inputSchema": {
				"type": "object",
				"properties": {
					"node_path": {"type": "string"},
					"property": {"type": "string"},
					"value": {}
				},
				"required": ["node_path", "property", "value"]
			}
		},
		{
			"name": "set_properties",
			"description": "Set multiple properties on a node at once",
			"inputSchema": {
				"type": "object",
				"properties": {
					"node_path": {"type": "string"},
					"properties": {"type": "object"}
				},
				"required": ["node_path", "properties"]
			}
		},
		{
			"name": "add_script",
			"description": "Add a script to a node. The script will be properly attached and saved.",
			"inputSchema": {
				"type": "object",
				"properties": {
					"node_path": {"type": "string", "description": "Path to the node (e.g., 'Player', '/root/Player')"},
					"code": {"type": "string", "description": "GDScript code to put in the script"},
					"script_name": {"type": "string", "description": "Optional custom name for the script file (without .gd extension)"}
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
					"script_path": {"type": "string"},
					"code": {"type": "string"}
				},
				"required": ["script_path", "code"]
			}
		},
		{
			"name": "save_scene",
			"description": "Save the current scene",
			"inputSchema": {"type": "object", "properties": {}}
		},
		{
			"name": "run_game",
			"description": "Run the game from editor",
			"inputSchema": {"type": "object", "properties": {}}
		},
		{
			"name": "stop_game",
			"description": "Stop the running game",
			"inputSchema": {"type": "object", "properties": {}}
		},
		{
			"name": "list_files",
			"description": "List files in a directory",
			"inputSchema": {
				"type": "object",
				"properties": {
					"path": {"type": "string", "default": "res://"}
				}
			}
		},
		{
			"name": "read_file",
			"description": "Read a file from the project",
			"inputSchema": {
				"type": "object",
				"properties": {
					"path": {"type": "string"}
				},
				"required": ["path"]
			}
		},
		{
			"name": "write_file",
			"description": "Write content to a file",
			"inputSchema": {
				"type": "object",
				"properties": {
					"path": {"type": "string"},
					"content": {"type": "string"}
				},
				"required": ["path", "content"]
			}
		},
		{
			"name": "delete_file",
			"description": "Delete a file from the project",
			"inputSchema": {
				"type": "object",
				"properties": {
					"path": {"type": "string"}
				},
				"required": ["path"]
			}
		}
	]

func _handle_tool_call(params: Dictionary, id) -> Dictionary:
	var tool_name = params.get("name", "")
	var tool_params = params.get("arguments", {})
	
	if not tools.has(tool_name):
		return {
			"jsonrpc": "2.0",
			"error": {"code": -32602, "message": "Unknown tool: " + tool_name},
			"id": id
		}
	
	var result = tools[tool_name].call(tool_params)
	return {
		"jsonrpc": "2.0",
		"result": {"content": [{"type": "text", "text": JSON.stringify(result)}]},
		"id": id
	}

func _send_json(client: StreamPeerTCP, status_code: int, data: Dictionary):
	var body = JSON.stringify(data)
	var response = "HTTP/1.1 %d OK\r\n" % status_code
	response += "Content-Type: application/json\r\n"
	response += "Content-Length: %d\r\n" % body.length()
	response += "Access-Control-Allow-Origin: *\r\n"
	response += "\r\n"
	response += body
	client.put_data(response.to_utf8_buffer())

func _send_error(client: StreamPeerTCP, status_code: int, message: String):
	_send_json(client, status_code, {"error": message})

# ═══════════════════════════════════════════════════════════════
# TOOL IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════

func _get_project_info(_params: Dictionary) -> Dictionary:
	var project_path = ProjectSettings.globalize_path("res://")
	return {
		"project_name": ProjectSettings.get_setting("application/config/name"),
		"project_path": project_path,
		"godot_version": Engine.get_version_info(),
		"main_scene": ProjectSettings.get_setting("application/run/main_scene"),
		"features": ProjectSettings.get_setting("application/config/features")
	}

func _get_scene_tree(_params: Dictionary) -> Dictionary:
	var editor_interface = editor_plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	
	if not edited_scene_root:
		return {"error": "No scene currently open"}
	
	return {
		"scene_path": edited_scene_root.scene_file_path,
		"root": _serialize_node(edited_scene_root, edited_scene_root)
	}

func _serialize_node(node: Node, scene_root: Node) -> Dictionary:
	# Get path relative to scene root
	var relative_path = scene_root.get_path_to(node)
	var path_str = str(relative_path)
	if path_str == ".":
		path_str = node.name
	
	var data = {
		"name": node.name,
		"type": node.get_class(),
		"path": path_str,
		"children": []
	}
	
	for child in node.get_children():
		# Skip internal/editor nodes
		if not child.name.begins_with("@"):
			data["children"].append(_serialize_node(child, scene_root))
	
	return data

func _create_scene(params: Dictionary) -> Dictionary:
	var scene_name = params.get("scene_name", "NewScene")
	var root_type = params.get("root_type", "Node2D")
	
	# Create new scene
	var scene = PackedScene.new()
	var root = ClassDB.instantiate(root_type)
	root.name = scene_name
	
	scene.pack(root)
	var path = "res://" + scene_name + ".tscn"
	var err = ResourceSaver.save(scene, path)
	
	if err == OK:
		# Open the scene
		editor_plugin.get_editor_interface().open_scene_from_path(path)
		return {"success": true, "path": path, "root_type": root_type}
	else:
		return {"error": "Failed to save scene", "code": err}

func _save_scene(_params: Dictionary) -> Dictionary:
	editor_plugin.get_editor_interface().save_scene()
	return {"success": true}

func _add_node(params: Dictionary) -> Dictionary:
	var parent_path = params.get("parent_path", ".")
	var node_name = params.get("node_name", "")
	var node_type = params.get("node_type", "")
	var properties = params.get("properties", {})
	
	var edited_scene_root = editor_plugin.get_editor_interface().get_edited_scene_root()
	if not edited_scene_root:
		return {"error": "No scene open"}
	
	var parent = edited_scene_root.get_node_or_null(parent_path)
	if not parent:
		return {"error": "Parent node not found: " + parent_path}
	
	var node = ClassDB.instantiate(node_type)
	if not node:
		return {"error": "Invalid node type: " + node_type}
	
	node.name = node_name
	
	# Set properties
	for prop in properties:
		if prop in node:
			var value = _parse_property_value(properties[prop], prop)
			node.set(prop, value)
	
	parent.add_child(node)
	node.owner = edited_scene_root
	
	# Save scene
	editor_plugin.get_editor_interface().save_scene()
	
	return {"success": true, "node_path": node.get_path()}

func _create_sprite(params: Dictionary) -> Dictionary:
	var parent_path = params.get("parent_path", ".")
	var node_name = params.get("name", "Sprite")
	var pos = params.get("position", {"x": 0, "y": 0})
	var size = params.get("size", 64)
	var color_dict = params.get("color", {"r": 1, "g": 0, "b": 0})
	var color = Color(color_dict.get("r", 1), color_dict.get("g", 0), color_dict.get("b", 0))
	
	var edited_scene_root = editor_plugin.get_editor_interface().get_edited_scene_root()
	if not edited_scene_root:
		return {"error": "No scene open"}
	
	var parent = edited_scene_root.get_node_or_null(parent_path)
	if not parent:
		return {"error": "Parent not found: " + parent_path}
	
	# Create Sprite2D
	var sprite = Sprite2D.new()
	sprite.name = node_name
	sprite.position = Vector2(pos.get("x", 0), pos.get("y", 0))
	
	# Create colored texture
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	sprite.texture = ImageTexture.create_from_image(image)
	
	parent.add_child(sprite)
	sprite.owner = edited_scene_root
	
	editor_plugin.get_editor_interface().save_scene()
	
	return {
		"success": true,
		"node_name": node_name,
		"position": sprite.position,
		"size": size,
		"color": color.to_html()
	}

func _create_color_rect(params: Dictionary) -> Dictionary:
	var parent_path = params.get("parent_path", ".")
	var node_name = params.get("name", "ColorRect")
	var pos = params.get("position", {"x": 0, "y": 0})
	var size_dict = params.get("size", {"width": 100, "height": 100})
	var color_dict = params.get("color", {"r": 1, "g": 0, "b": 0, "a": 1})
	var color = Color(
		color_dict.get("r", 1), 
		color_dict.get("g", 0), 
		color_dict.get("b", 0),
		color_dict.get("a", 1)
	)
	
	var edited_scene_root = editor_plugin.get_editor_interface().get_edited_scene_root()
	if not edited_scene_root:
		return {"error": "No scene open"}
	
	var parent = edited_scene_root.get_node_or_null(parent_path)
	if not parent:
		return {"error": "Parent not found: " + parent_path}
	
	# Create ColorRect
	var rect = ColorRect.new()
	rect.name = node_name
	rect.position = Vector2(pos.get("x", 0), pos.get("y", 0))
	rect.size = Vector2(size_dict.get("width", 100), size_dict.get("height", 100))
	rect.color = color
	
	parent.add_child(rect)
	rect.owner = edited_scene_root
	
	editor_plugin.get_editor_interface().save_scene()
	
	return {
		"success": true,
		"node_name": node_name,
		"position": rect.position,
		"size": rect.size,
		"color": color.to_html()
	}

func _remove_node(params: Dictionary) -> Dictionary:
	var node_path = params.get("node_path", "")
	
	if node_path.is_empty():
		return {"error": "No node_path provided"}
	
	var edited_scene_root = editor_plugin.get_editor_interface().get_edited_scene_root()
	if not edited_scene_root:
		return {"error": "No scene open"}
	
	var node = _find_node(edited_scene_root, node_path)
	
	if not node:
		return {
			"error": "Node not found",
			"searched": node_path,
			"available": _list_all_node_names(edited_scene_root)
		}
	
	var node_name = node.name
	node.queue_free()
	editor_plugin.get_editor_interface().save_scene()
	
	return {"success": true, "deleted": node_name}

func _find_node(root: Node, search: String) -> Node:
	# Try as path first
	var node = root.get_node_or_null(search)
	if node:
		return node
	
	# Try as name (search recursively)
	return _find_node_by_name(root, search)

func _find_node_by_name(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	for child in root.get_children():
		if child.name.begins_with("@"):
			continue
		var found = _find_node_by_name(child, target_name)
		if found:
			return found
	return null

func _list_all_node_names(root: Node) -> Array:
	var names = [root.name]
	for child in root.get_children():
		if child.name.begins_with("@"):
			continue
		names.append_array(_list_all_node_names(child))
	return names

func _set_property(params: Dictionary) -> Dictionary:
	var node_path = params.get("node_path", "")
	var property = params.get("property", "")
	var value = params.get("value", null)
	
	var edited_scene_root = editor_plugin.get_editor_interface().get_edited_scene_root()
	if not edited_scene_root:
		return {"error": "No scene open"}
	
	var node = _find_node(edited_scene_root, node_path)
	if not node:
		return {"error": "Node not found: " + node_path}
	
	if property in node:
		var parsed_value = _parse_property_value(value, property)
		node.set(property, parsed_value)
		editor_plugin.get_editor_interface().save_scene()
		return {"success": true}
	else:
		return {"error": "Property not found: " + property}

func _set_properties(params: Dictionary) -> Dictionary:
	var node_path = params.get("node_path", "")
	var properties = params.get("properties", {})
	
	var edited_scene_root = editor_plugin.get_editor_interface().get_edited_scene_root()
	if not edited_scene_root:
		return {"error": "No scene open"}
	
	var node = _find_node(edited_scene_root, node_path)
	if not node:
		return {"error": "Node not found: " + node_path}
	
	var results = {}
	for prop in properties:
		if prop in node:
			var value = _parse_property_value(properties[prop], prop)
			node.set(prop, value)
			results[prop] = "ok"
		else:
			results[prop] = "not_found"
	
	editor_plugin.get_editor_interface().save_scene()
	return {"success": true, "results": results}

func _parse_property_value(value, property_name: String):
	# Handle position as {"x": 10, "y": 20}
	if property_name == "position" and value is Dictionary:
		return Vector2(value.get("x", 0), value.get("y", 0))
	# Handle size as {"width": 100, "height": 100}
	if property_name == "size" and value is Dictionary and value.has("width"):
		return Vector2(value.get("width", 0), value.get("height", 0))
	# Handle scale as {"x": 1, "y": 1}
	if property_name == "scale" and value is Dictionary:
		return Vector2(value.get("x", 1), value.get("y", 1))
	# Handle color as {"r": 1, "g": 0, "b": 0}
	if property_name == "color" and value is Dictionary:
		if value.has("a"):
			return Color(value.get("r", 0), value.get("g", 0), value.get("b", 0), value.get("a", 1))
		return Color(value.get("r", 0), value.get("g", 0), value.get("b", 0))
	return value

func _add_script(params: Dictionary) -> Dictionary:
	var node_path = params.get("node_path", "")
	var code = params.get("code", "")
	var script_name = params.get("script_name", "")
	
	var edited_scene_root = editor_plugin.get_editor_interface().get_edited_scene_root()
	if not edited_scene_root:
		return {"error": "No scene open"}
	
	var node = _find_node(edited_scene_root, node_path)
	if not node:
		return {"error": "Node not found: " + node_path}
	
	# Determine script filename
	var script_file_name = script_name if not script_name.is_empty() else node.name
	var script_path = "res://" + script_file_name + ".gd"
	
	# Check if script already exists
	var script: GDScript
	if FileAccess.file_exists(script_path):
		# Update existing script
		script = load(script_path)
		if code:
			script.source_code = code
	else:
		# Create new script
		script = GDScript.new()
		if code:
			script.source_code = code
		else:
			script.source_code = _get_default_script(node.get_class())
	
	# Save the script to disk
	var err = ResourceSaver.save(script, script_path)
	if err != OK:
		return {"error": "Failed to save script", "code": err, "path": script_path}
	
	# CRITICAL: Reload the script from disk to get a proper reference
	script = load(script_path)
	
	# CRITICAL: Set the script using the editor's method to ensure it's properly attached
	# This properly marks the scene as modified and updates the editor UI
	node.set_script(script)
	
	# Mark the node as owned by the scene so the script persists
	node.owner = edited_scene_root
	
	# Save the scene
	editor_plugin.get_editor_interface().save_scene()
	
	# Verify the script was attached
	var attached_script = node.get_script()
	var script_attached = attached_script != null
	
	return {
		"success": true, 
		"script_path": script_path,
		"script_attached": script_attached,
		"node_name": node.name,
		"node_type": node.get_class()
	}

func _get_default_script(node_type: String) -> String:
	return """extends %s

func _ready():
	pass

func _process(delta):
	pass
""" % node_type

func _edit_script(params: Dictionary) -> Dictionary:
	var script_path = params.get("script_path", "")
	var code = params.get("code", "")
	
	var full_path = ProjectSettings.globalize_path(script_path)
	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file:
		file.store_string(code)
		file.close()
		return {"success": true}
	else:
		return {"error": "Failed to write script: " + script_path}

func _run_game(_params: Dictionary) -> Dictionary:
	editor_plugin.get_editor_interface().play_current_scene()
	return {"success": true, "message": "Game started"}

func _stop_game(_params: Dictionary) -> Dictionary:
	editor_plugin.get_editor_interface().stop_playing_scene()
	return {"success": true, "message": "Game stopped"}

func _get_output(_params: Dictionary) -> Dictionary:
	return {"message": "Output capture not implemented in this version"}

func _list_files(params: Dictionary) -> Dictionary:
	var path = params.get("path", "res://")
	var dir = DirAccess.open(path)
	
	if not dir:
		return {"error": "Cannot open directory: " + path}
	
	var files = []
	var dirs = []
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			dirs.append(file_name)
		else:
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return {"path": path, "directories": dirs, "files": files}

func _read_file(params: Dictionary) -> Dictionary:
	var path = params.get("path", "")
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var content = file.get_as_text()
		file.close()
		return {"path": path, "content": content}
	else:
		return {"error": "Cannot read file: " + path}

func _write_file(params: Dictionary) -> Dictionary:
	var path = params.get("path", "")
	var content = params.get("content", "")
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		return {"success": true, "path": path}
	else:
		return {"error": "Cannot write file: " + path}

func _delete_file(params: Dictionary) -> Dictionary:
	var path = params.get("path", "")
	
	var err = DirAccess.remove_absolute(path)
	if err == OK:
		return {"success": true, "path": path}
	else:
		return {"error": "Cannot delete file: " + path, "code": err}
