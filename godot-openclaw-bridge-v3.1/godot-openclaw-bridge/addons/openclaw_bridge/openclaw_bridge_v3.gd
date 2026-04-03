@tool
extends Node

# OpenClaw MCP Bridge v3.0 - Ultra-Fast Human-Like Control
# Fixed script bugs, added batch operations, better error handling

var editor_plugin: EditorPlugin
var tcp_server: TCPServer
var clients: Array[StreamPeerTCP] = []

const PORT = 7450
const BUFFER_SIZE = 4096

# Editor interface shortcuts for speed
var _editor_interface: EditorInterface
var _editor_filesystem: EditorFileSystem
var _undo_redo: UndoRedo

func _ready():
	_editor_interface = editor_plugin.get_editor_interface()
	_editor_filesystem = _editor_interface.get_resource_filesystem()
	_undo_redo = _editor_interface.get_undo_redo()
	start_server()

func _process(_delta):
	# Accept new connections
	if tcp_server and tcp_server.is_connection_available():
		var client = tcp_server.take_connection()
		clients.append(client)
		print("[OpenClaw v3] Client connected")
	
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
		print("[OpenClaw v3] MCP server on port ", PORT)
	else:
		push_error("[OpenClaw v3] Failed to start server on port " + str(PORT))

func stop_server():
	for client in clients:
		client.disconnect_from_host()
	clients.clear()
	if tcp_server:
		tcp_server.stop()
		print("[OpenClaw v3] Server stopped")

func _handle_request(client: StreamPeerTCP, data: String):
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
	
	if method == "POST" and path == "/mcp":
		_handle_mcp_request(client, data)
	elif method == "GET" and path == "/health":
		_send_json(client, 200, {"status": "ok", "version": "3.0"})
	else:
		_send_error(client, 404, "Not Found")

func _handle_mcp_request(client: StreamPeerTCP, data: String):
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
		return {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": id}
	
	match method:
		"initialize":
			return {
				"jsonrpc": "2.0",
				"result": {
					"protocolVersion": "2024-11-05",
					"capabilities": {"tools": {}},
					"serverInfo": {"name": "godot-openclaw-bridge", "version": "3.0.0"}
				},
				"id": id
			}
		
		"tools/list":
			return {"jsonrpc": "2.0", "result": {"tools": _get_tool_definitions()}, "id": id}
		
		"tools/call":
			return _handle_tool_call(params, id)
		
		_:
			return {"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found: " + method}, "id": id}

func _handle_tool_call(params: Dictionary, id) -> Dictionary:
	var tool_name = params.get("name", "")
	var tool_params = params.get("arguments", {})
	
	var result = _execute_tool(tool_name, tool_params)
	return {
		"jsonrpc": "2.0",
		"result": {"content": [{"type": "text", "text": JSON.stringify(result)}]},
		"id": id
	}

func _execute_tool(tool_name: String, params: Dictionary) -> Dictionary:
	var start_time = Time.get_ticks_msec()
	var result
	
	match tool_name:
		# Core Scene
		"get_project_info": result = _get_project_info(params)
		"get_scene_tree": result = _get_scene_tree(params)
		"create_scene": result = _create_scene(params)
		"save_scene": result = _save_scene(params)
		
		# Node Operations
		"add_node": result = _add_node(params)
		"remove_node": result = _remove_node(params)
		"duplicate_node": result = _duplicate_node(params)
		"reparent_node": result = _reparent_node(params)
		"rename_node": result = _rename_node(params)
		"get_node_info": result = _get_node_info(params)
		
		# Properties
		"set_property": result = _set_property(params)
		"set_properties": result = _set_properties(params)
		"get_property": result = _get_property(params)
		
		# Visual Nodes
		"create_sprite": result = _create_sprite(params)
		"create_color_rect": result = _create_color_rect(params)
		
		# Scripts - FIXED VERSION
		"add_script": result = _add_script_fixed(params)
		"edit_script": result = _edit_script(params)
		"get_script_content": result = _get_script_content(params)
		"reload_scripts": result = _reload_scripts(params)
		
		# Game Control
		"run_game": result = _run_game(params)
		"stop_game": result = _stop_game(params)
		"get_output": result = _get_output(params)
		"clear_output": result = _clear_output(params)
		
		# File Operations
		"list_files": result = _list_files(params)
		"read_file": result = _read_file(params)
		"write_file": result = _write_file(params)
		"delete_file": result = _delete_file(params)
		
		# Editor
		"select_node": result = _select_node(params)
		"get_selected_nodes": result = _get_selected_nodes(params)
		"undo": result = _undo(params)
		"redo": result = _redo(params)
		
		# NEW: Game Development Helpers
		"create_collision_shape": result = _create_collision_shape(params)
		"create_camera": result = _create_camera(params)
		"create_label": result = _create_label(params)
		"create_area2d": result = _create_area2d(params)
		"create_timer_node": result = _create_timer_node(params)
		"create_full_character": result = _create_full_character(params)
		"set_main_scene": result = _set_main_scene(params)
		
		_:
			return {"error": "Unknown tool: " + tool_name}
	
	var elapsed = Time.get_ticks_msec() - start_time
	result["_server_time_ms"] = elapsed
	return result

# ═══════════════════════════════════════════════════════════════
# TOOL DEFINITIONS
# ═══════════════════════════════════════════════════════════════

func _get_tool_definitions() -> Array:
	return [
		{"name": "get_project_info", "description": "Get project information", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "get_scene_tree", "description": "Get scene tree structure", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "create_scene", "description": "Create new scene", "inputSchema": {"type": "object", "properties": {"scene_name": {"type": "string"}, "root_type": {"type": "string"}}}},
		{"name": "save_scene", "description": "Save current scene", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "add_node", "description": "Add node to scene", "inputSchema": {"type": "object", "properties": {"parent_path": {"type": "string"}, "node_name": {"type": "string"}, "node_type": {"type": "string"}, "properties": {"type": "object"}}}},
		{"name": "remove_node", "description": "Remove node", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}}}},
		{"name": "duplicate_node", "description": "Duplicate node", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}, "new_name": {"type": "string"}}}},
		{"name": "reparent_node", "description": "Reparent node", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}, "new_parent": {"type": "string"}}}},
		{"name": "rename_node", "description": "Rename node", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}, "new_name": {"type": "string"}}}},
		{"name": "set_property", "description": "Set single property", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}, "property": {"type": "string"}, "value": {}}}},
		{"name": "set_properties", "description": "Set multiple properties", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}, "properties": {"type": "object"}}}},
		{"name": "get_property", "description": "Get property value", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}, "property": {"type": "string"}}}},
		{"name": "create_sprite", "description": "Create Sprite2D", "inputSchema": {"type": "object", "properties": {"parent_path": {"type": "string"}, "name": {"type": "string"}, "position": {"type": "object"}, "size": {"type": "integer"}, "color": {"type": "object"}}}},
		{"name": "create_color_rect", "description": "Create ColorRect", "inputSchema": {"type": "object", "properties": {"parent_path": {"type": "string"}, "name": {"type": "string"}, "position": {"type": "object"}, "size": {"type": "object"}, "color": {"type": "object"}}}},
		{"name": "add_script", "description": "Add script to node (FIXED)", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}, "code": {"type": "string"}, "script_name": {"type": "string"}, "auto_reload": {"type": "boolean"}}}},
		{"name": "edit_script", "description": "Edit existing script", "inputSchema": {"type": "object", "properties": {"script_path": {"type": "string"}, "code": {"type": "string"}}}},
		{"name": "get_script_content", "description": "Read script content", "inputSchema": {"type": "object", "properties": {"script_path": {"type": "string"}}}},
		{"name": "reload_scripts", "description": "Force script refresh", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "run_game", "description": "Run game", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "stop_game", "description": "Stop game", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "list_files", "description": "List directory", "inputSchema": {"type": "object", "properties": {"path": {"type": "string"}}}},
		{"name": "read_file", "description": "Read file", "inputSchema": {"type": "object", "properties": {"path": {"type": "string"}}}},
		{"name": "write_file", "description": "Write file", "inputSchema": {"type": "object", "properties": {"path": {"type": "string"}, "content": {"type": "string"}}}},
		{"name": "delete_file", "description": "Delete file", "inputSchema": {"type": "object", "properties": {"path": {"type": "string"}}}},
		{"name": "get_node_info", "description": "Get detailed node info", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}}}},
		{"name": "select_node", "description": "Select node in editor", "inputSchema": {"type": "object", "properties": {"node_path": {"type": "string"}}}},
		{"name": "get_selected_nodes", "description": "Get selected nodes", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "undo", "description": "Undo", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "redo", "description": "Redo", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "clear_output", "description": "Clear output panel", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "create_collision_shape", "description": "Add CollisionShape2D with RectangleShape2D to a node", "inputSchema": {"type": "object", "properties": {"parent_path": {"type": "string"}, "width": {"type": "number"}, "height": {"type": "number"}}}},
		{"name": "create_camera", "description": "Add Camera2D to a node with zoom and smoothing", "inputSchema": {"type": "object", "properties": {"parent_path": {"type": "string"}, "zoom": {"type": "number"}, "smoothing": {"type": "boolean"}}}},
		{"name": "create_label", "description": "Add Label node for UI/HUD text", "inputSchema": {"type": "object", "properties": {"parent_path": {"type": "string"}, "name": {"type": "string"}, "text": {"type": "string"}, "font_size": {"type": "integer"}, "position": {"type": "object"}}}},
		{"name": "create_area2d", "description": "Add Area2D with collision for triggers/pickups", "inputSchema": {"type": "object", "properties": {"parent_path": {"type": "string"}, "name": {"type": "string"}, "width": {"type": "number"}, "height": {"type": "number"}, "monitoring": {"type": "boolean"}}}},
		{"name": "create_timer_node", "description": "Add Timer node", "inputSchema": {"type": "object", "properties": {"parent_path": {"type": "string"}, "name": {"type": "string"}, "wait_time": {"type": "number"}, "one_shot": {"type": "boolean"}, "autostart": {"type": "boolean"}}}},
		{"name": "create_full_character", "description": "Create a complete game character with body, sprite, collision shape, and script in one call", "inputSchema": {"type": "object", "properties": {"parent_path": {"type": "string"}, "name": {"type": "string"}, "char_type": {"type": "string", "description": "platformer, topdown, or static"}, "width": {"type": "number"}, "height": {"type": "number"}, "color": {"type": "object"}}}},
		{"name": "set_main_scene", "description": "Set the main scene for the project (the one that runs on F5)", "inputSchema": {"type": "object", "properties": {"scene_path": {"type": "string"}}}}
	]

# ═══════════════════════════════════════════════════════════════
# IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════

func _get_project_info(_params: Dictionary) -> Dictionary:
	return {
		"project_name": ProjectSettings.get_setting("application/config/name"),
		"project_path": ProjectSettings.globalize_path("res://"),
		"godot_version": Engine.get_version_info(),
		"main_scene": ProjectSettings.get_setting("application/run/main_scene")
	}

func _get_scene_tree(_params: Dictionary) -> Dictionary:
	var root = _editor_interface.get_edited_scene_root()
	if not root:
		return {"error": "No scene open"}
	return {"scene_path": root.scene_file_path, "root": _serialize_node(root, root)}

func _serialize_node(node: Node, scene_root: Node) -> Dictionary:
	var relative_path = scene_root.get_path_to(node)
	var path_str = str(relative_path)
	if path_str == ".":
		path_str = node.name
	
	var data = {"name": node.name, "type": node.get_class(), "path": path_str, "children": []}
	for child in node.get_children():
		if not child.name.begins_with("@"):
			data["children"].append(_serialize_node(child, scene_root))
	return data

func _create_scene(params: Dictionary) -> Dictionary:
	var scene_name = params.get("scene_name", "NewScene")
	var root_type = params.get("root_type", "Node2D")
	
	var scene = PackedScene.new()
	var root = ClassDB.instantiate(root_type)
	root.name = scene_name
	
	scene.pack(root)
	var path = "res://" + scene_name + ".tscn"
	var err = ResourceSaver.save(scene, path)
	
	if err == OK:
		_editor_interface.open_scene_from_path(path)
		return {"success": true, "path": path}
	return {"error": "Failed to save scene", "code": err}

func _save_scene(_params: Dictionary) -> Dictionary:
	_editor_interface.save_scene()
	return {"success": true}

func _get_edited_root():
	return _editor_interface.get_edited_scene_root()

func _find_node(root: Node, search: String) -> Node:
	var node = root.get_node_or_null(search)
	if node:
		return node
	return _find_node_by_name(root, search)

func _find_node_by_name(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	for child in root.get_children():
		if not child.name.begins_with("@"):
			var found = _find_node_by_name(child, target_name)
			if found:
				return found
	return null

func _add_node(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var parent = _find_node(root, params.get("parent_path", "."))
	if not parent:
		return {"error": "Parent not found"}
	
	var node = ClassDB.instantiate(params.get("node_type", "Node2D"))
	if not node:
		return {"error": "Invalid node type"}
	
	node.name = params.get("node_name", "Node")
	
	var properties = params.get("properties", {})
	for prop in properties:
		if prop in node:
			node.set(prop, _parse_value(properties[prop], prop))
	
	parent.add_child(node)
	node.owner = root
	_editor_interface.save_scene()
	
	return {"success": true, "node_path": node.get_path()}

func _remove_node(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node = _find_node(root, params.get("node_path", ""))
	if not node:
		return {"error": "Node not found"}
	
	var name = node.name
	node.queue_free()
	_editor_interface.save_scene()
	return {"success": true, "deleted": name}

func _duplicate_node(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node = _find_node(root, params.get("node_path", ""))
	if not node:
		return {"error": "Node not found"}
	
	var duplicate = node.duplicate()
	var new_name = params.get("new_name", node.name + "2")
	duplicate.name = new_name
	
	node.get_parent().add_child(duplicate)
	duplicate.owner = root
	_editor_interface.save_scene()
	
	return {"success": true, "new_node": new_name, "path": str(duplicate.get_path())}

func _reparent_node(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node = _find_node(root, params.get("node_path", ""))
	var new_parent = _find_node(root, params.get("new_parent", ""))
	
	if not node or not new_parent:
		return {"error": "Node or parent not found"}
	
	# Preserve global position if it's a Node2D
	var global_pos = null
	if node is Node2D:
		global_pos = node.global_position
	
	var old_parent = node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)
	node.owner = root
	
	# Restore global position
	if global_pos and node is Node2D:
		node.global_position = global_pos
	
	# Re-own all children recursively
	_set_owner_recursive(node, root)
	
	_editor_interface.save_scene()
	return {"success": true, "node": node.name, "new_parent": new_parent.name}

func _set_owner_recursive(node: Node, owner: Node):
	for child in node.get_children():
		child.owner = owner
		_set_owner_recursive(child, owner)

func _rename_node(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node = _find_node(root, params.get("node_path", ""))
	if not node:
		return {"error": "Node not found"}
	
	var old_name = node.name
	var new_name = params.get("new_name", "")
	if new_name.is_empty():
		return {"error": "No new name provided"}
	
	node.name = new_name
	_editor_interface.save_scene()
	return {"success": true, "old_name": old_name, "new_name": new_name}

func _get_node_info(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node = _find_node(root, params.get("node_path", ""))
	if not node:
		return {"error": "Node not found"}
	
	var script = node.get_script()
	var info = {
		"name": node.name,
		"type": node.get_class(),
		"path": str(node.get_path()),
		"has_script": script != null,
		"child_count": node.get_child_count()
	}
	
	# Add position/size if applicable
	if "position" in node:
		info["position"] = {"x": node.position.x, "y": node.position.y}
	if "size" in node:
		info["size"] = {"x": node.size.x, "y": node.size.y}
	
	if script and script is GDScript:
		info["script_path"] = script.resource_path
		info["script_source"] = script.source_code
	
	return info

func _set_property(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node = _find_node(root, params.get("node_path", ""))
	if not node:
		return {"error": "Node not found"}
	
	var prop = params.get("property", "")
	var value = params.get("value")
	
	if prop in node:
		node.set(prop, _parse_value(value, prop))
		_editor_interface.save_scene()
		return {"success": true, "property": prop}
	return {"error": "Property not found: " + prop}

func _set_properties(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node = _find_node(root, params.get("node_path", ""))
	if not node:
		return {"error": "Node not found"}
	
	var properties = params.get("properties", {})
	var results = {}
	for prop in properties:
		if prop in node:
			node.set(prop, _parse_value(properties[prop], prop))
			results[prop] = "ok"
		else:
			results[prop] = "not_found"
	
	_editor_interface.save_scene()
	return {"success": true, "results": results}

func _get_property(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node = _find_node(root, params.get("node_path", ""))
	if not node:
		return {"error": "Node not found"}
	
	var prop = params.get("property", "")
	if prop in node:
		var value = node.get(prop)
		return {"success": true, "property": prop, "value": value}
	return {"error": "Property not found"}

func _parse_value(value, property_name: String):
	# Vector2 properties
	if property_name in ["position", "velocity", "global_position", "offset", "pivot_offset", "custom_minimum_size"] and value is Dictionary:
		return Vector2(value.get("x", 0), value.get("y", 0))
	if property_name == "size" and value is Dictionary:
		if value.has("width"):
			return Vector2(value.get("width", 0), value.get("height", 0))
		return Vector2(value.get("x", 0), value.get("y", 0))
	if property_name == "scale" and value is Dictionary:
		return Vector2(value.get("x", 1), value.get("y", 1))
	# Color properties
	if property_name in ["color", "modulate", "self_modulate", "font_color"] and value is Dictionary:
		return Color(value.get("r", 0), value.get("g", 0), value.get("b", 0), value.get("a", 1))
	# Numeric auto-convert (JSON sends ints as floats)
	if property_name in ["rotation", "rotation_degrees", "z_index", "z_as_relative"]:
		if value is String:
			return float(value)
		return value
	# Rect2
	if property_name in ["region_rect"] and value is Dictionary:
		return Rect2(value.get("x", 0), value.get("y", 0), value.get("w", 0), value.get("h", 0))
	# Bool
	if value is String and value.to_lower() in ["true", "false"]:
		return value.to_lower() == "true"
	return value

func _create_sprite(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var parent = _find_node(root, params.get("parent_path", "."))
	if not parent:
		return {"error": "Parent not found"}
	
	var pos = params.get("position", {"x": 0, "y": 0})
	var size = params.get("size", 64)
	var color_dict = params.get("color", {"r": 1, "g": 0, "b": 0})
	var color = Color(color_dict.get("r", 1), color_dict.get("g", 0), color_dict.get("b", 0))
	
	var sprite = Sprite2D.new()
	sprite.name = params.get("name", "Sprite")
	sprite.position = Vector2(pos.get("x", 0), pos.get("y", 0))
	
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	sprite.texture = ImageTexture.create_from_image(image)
	
	parent.add_child(sprite)
	sprite.owner = root
	_editor_interface.save_scene()
	
	return {"success": true, "node_name": sprite.name}

func _create_color_rect(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var parent = _find_node(root, params.get("parent_path", "."))
	if not parent:
		return {"error": "Parent not found"}
	
	var pos = params.get("position", {"x": 0, "y": 0})
	var size = params.get("size", {"width": 100, "height": 100})
	var color_dict = params.get("color", {"r": 1, "g": 0, "b": 0, "a": 1})
	var color = Color(color_dict.get("r", 1), color_dict.get("g", 0), color_dict.get("b", 0), color_dict.get("a", 1))
	
	var rect = ColorRect.new()
	rect.name = params.get("name", "ColorRect")
	rect.position = Vector2(pos.get("x", 0), pos.get("y", 0))
	rect.size = Vector2(size.get("width", 100), size.get("height", 100))
	rect.color = color
	
	parent.add_child(rect)
	rect.owner = root
	_editor_interface.save_scene()
	
	return {"success": true, "node_name": rect.name}

# ═══════════════════════════════════════════════════════════════
# FIXED SCRIPT SYSTEM
# ═══════════════════════════════════════════════════════════════

func _add_script_fixed(params: Dictionary) -> Dictionary:
	"""
	FIXED: Script properly reloads and attaches to node
	"""
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node_path = params.get("node_path", "")
	var code = params.get("code", "")
	var script_name = params.get("script_name", "")
	var auto_reload = params.get("auto_reload", true)
	
	var node = _find_node(root, node_path)
	if not node:
		return {"error": "Node not found: " + node_path}
	
	# Determine script filename
	var script_file_name = script_name if not script_name.is_empty() else node.name
	var script_path = "res://" + script_file_name + ".gd"
	
	# Check if script exists
	var existing_script = node.get_script()
	
	# Create or update script
	var script: GDScript
	if FileAccess.file_exists(script_path):
		# Update existing
		script = load(script_path)
		if code:
			script.source_code = code
	else:
		# Create new
		script = GDScript.new()
		script.source_code = code if code else _get_default_script(node.get_class())
	
	# Save script to disk FIRST
	var err = ResourceSaver.save(script, script_path)
	if err != OK:
		return {"error": "Failed to save script", "code": err}
	
	# CRITICAL FIX: Force filesystem scan to pick up the new file
	_editor_filesystem.scan()
	
	# CRITICAL FIX: Reload script from disk to get proper reference
	script = load(script_path)
	
	# CRITICAL FIX: Use editor's undo/redo for proper integration
	_undo_redo.create_action("Add Script to " + node.name)
	_undo_redo.add_do_property(node, "script", script)
	_undo_redo.add_undo_property(node, "script", existing_script)
	_undo_redo.commit_action()
	
	# Alternative: direct set for immediate effect
	node.set_script(script)
	
	# Ensure ownership
	node.owner = root
	
	# Mark scene as modified
	_editor_interface.mark_scene_as_unsaved()
	
	# Save scene
	_editor_interface.save_scene()
	
	# Auto reload if requested
	if auto_reload:
		_reload_scripts({})
	
	# VERIFICATION: Check if script actually attached
	var attached_script = node.get_script()
	var script_attached = attached_script != null
	var verification_path = ""
	if attached_script and attached_script.has_method("get_path"):
		verification_path = attached_script.resource_path
	
	return {
		"success": true,
		"script_path": script_path,
		"script_attached": script_attached,
		"verification_path": verification_path,
		"node_name": node.name,
		"node_type": node.get_class(),
		"auto_reload": auto_reload
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
	
	if not script_path.begins_with("res://"):
		script_path = "res://" + script_path
	
	var script = load(script_path)
	if not script:
		# Create new
		script = GDScript.new()
	
	script.source_code = code
	var err = ResourceSaver.save(script, script_path)
	
	if err == OK:
		_editor_filesystem.scan()
		return {"success": true, "path": script_path}
	return {"error": "Failed to save script", "code": err}

func _get_script_content(params: Dictionary) -> Dictionary:
	var script_path = params.get("script_path", "")
	if not script_path.begins_with("res://"):
		script_path = "res://" + script_path
	
	var file = FileAccess.open(script_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		return {"success": true, "content": content, "path": script_path}
	return {"error": "Cannot read script: " + script_path}

func _reload_scripts(_params: Dictionary) -> Dictionary:
	"""Force script refresh in editor"""
	_editor_filesystem.scan()
	
	# Trigger reimport if needed
	var import_plugin = _editor_interface.get_resource_previewer()
	
	return {"success": true, "message": "Scripts reloaded"}

# ═══════════════════════════════════════════════════════════════
# GAME CONTROL
# ═══════════════════════════════════════════════════════════════

func _run_game(_params: Dictionary) -> Dictionary:
	_editor_interface.play_current_scene()
	return {"success": true, "message": "Game started"}

func _stop_game(_params: Dictionary) -> Dictionary:
	_editor_interface.stop_playing_scene()
	return {"success": true, "message": "Game stopped"}

func _get_output(_params: Dictionary) -> Dictionary:
	return {"message": "Output capture not available via plugin API. Check Godot Output panel."}

func _clear_output(_params: Dictionary) -> Dictionary:
	# get_output_log() does not exist in Godot 4.x EditorInterface
	return {"message": "Output panel cannot be cleared via plugin API."}

# ═══════════════════════════════════════════════════════════════
# FILE OPERATIONS
# ═══════════════════════════════════════════════════════════════

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
		return {"success": true, "content": content, "path": path}
	return {"error": "Cannot read file: " + path}

func _write_file(params: Dictionary) -> Dictionary:
	var path = params.get("path", "")
	var content = params.get("content", "")
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		return {"success": true, "path": path}
	return {"error": "Cannot write file: " + path}

func _delete_file(params: Dictionary) -> Dictionary:
	var path = params.get("path", "")
	var err = DirAccess.remove_absolute(path)
	if err == OK:
		return {"success": true, "path": path}
	return {"error": "Cannot delete file: " + path, "code": err}

# ═══════════════════════════════════════════════════════════════
# EDITOR OPERATIONS
# ═══════════════════════════════════════════════════════════════

func _select_node(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var node = _find_node(root, params.get("node_path", ""))
	if not node:
		return {"error": "Node not found"}
	
	_editor_interface.edit_node(node)
	return {"success": true, "selected": node.name}

func _get_selected_nodes(_params: Dictionary) -> Dictionary:
	var selection = _editor_interface.get_selection()
	var nodes = []
	for node in selection.get_selected_nodes():
		nodes.append({"name": node.name, "path": str(node.get_path())})
	return {"selected": nodes, "count": nodes.size()}

func _undo(_params: Dictionary) -> Dictionary:
	_undo_redo.undo()
	return {"success": true, "action": "undo"}

func _redo(_params: Dictionary) -> Dictionary:
	_undo_redo.redo()
	return {"success": true, "action": "redo"}

# ═══════════════════════════════════════════════════════════════
# GAME DEV HELPERS (v3.1)
# ═══════════════════════════════════════════════════════════════

func _create_collision_shape(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var parent = _find_node(root, params.get("parent_path", "."))
	if not parent:
		return {"error": "Parent not found"}
	
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(params.get("width", 32), params.get("height", 32))
	collision.shape = shape
	
	parent.add_child(collision)
	collision.owner = root
	_editor_interface.save_scene()
	return {"success": true, "node": "CollisionShape2D", "size": {"w": shape.size.x, "h": shape.size.y}}

func _create_camera(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var parent = _find_node(root, params.get("parent_path", "."))
	if not parent:
		return {"error": "Parent not found"}
	
	var camera = Camera2D.new()
	camera.name = "Camera2D"
	var zoom_val = params.get("zoom", 1.0)
	camera.zoom = Vector2(zoom_val, zoom_val)
	camera.position_smoothing_enabled = params.get("smoothing", true)
	
	parent.add_child(camera)
	camera.owner = root
	_editor_interface.save_scene()
	return {"success": true, "node": "Camera2D", "zoom": zoom_val}

func _create_label(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var parent = _find_node(root, params.get("parent_path", "."))
	if not parent:
		return {"error": "Parent not found"}
	
	var label = Label.new()
	label.name = params.get("name", "Label")
	label.text = params.get("text", "Hello")
	
	var pos = params.get("position", {"x": 0, "y": 0})
	if pos is Dictionary:
		label.position = Vector2(pos.get("x", 0), pos.get("y", 0))
	
	var font_size = params.get("font_size", 16)
	label.add_theme_font_size_override("font_size", font_size)
	
	parent.add_child(label)
	label.owner = root
	_editor_interface.save_scene()
	return {"success": true, "node": label.name, "text": label.text}

func _create_area2d(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var parent = _find_node(root, params.get("parent_path", "."))
	if not parent:
		return {"error": "Parent not found"}
	
	var area = Area2D.new()
	area.name = params.get("name", "Area2D")
	area.monitoring = params.get("monitoring", true)
	area.monitorable = true
	
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(params.get("width", 32), params.get("height", 32))
	collision.shape = shape
	
	area.add_child(collision)
	parent.add_child(area)
	area.owner = root
	collision.owner = root
	_editor_interface.save_scene()
	return {"success": true, "node": area.name}

func _create_timer_node(params: Dictionary) -> Dictionary:
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var parent = _find_node(root, params.get("parent_path", "."))
	if not parent:
		return {"error": "Parent not found"}
	
	var timer = Timer.new()
	timer.name = params.get("name", "Timer")
	timer.wait_time = params.get("wait_time", 1.0)
	timer.one_shot = params.get("one_shot", false)
	timer.autostart = params.get("autostart", false)
	
	parent.add_child(timer)
	timer.owner = root
	_editor_interface.save_scene()
	return {"success": true, "node": timer.name, "wait_time": timer.wait_time}

func _create_full_character(params: Dictionary) -> Dictionary:
	"""Create a complete character: CharacterBody2D + Sprite + Collision + Script"""
	var root = _get_edited_root()
	if not root:
		return {"error": "No scene open"}
	
	var parent = _find_node(root, params.get("parent_path", "."))
	if not parent:
		return {"error": "Parent not found"}
	
	var char_name = params.get("name", "Player")
	var char_type = params.get("char_type", "platformer")
	var w = params.get("width", 32)
	var h = params.get("height", 48)
	var color_dict = params.get("color", {"r": 0.2, "g": 0.6, "b": 1.0})
	var color = Color(color_dict.get("r", 0.2), color_dict.get("g", 0.6), color_dict.get("b", 1.0))
	
	# CharacterBody2D
	var body = CharacterBody2D.new()
	body.name = char_name
	
	# Sprite (ColorRect as placeholder)
	var sprite = ColorRect.new()
	sprite.name = "Sprite"
	sprite.size = Vector2(w, h)
	sprite.position = Vector2(-w / 2.0, -h / 2.0)
	sprite.color = color
	
	# CollisionShape2D
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(w, h)
	collision.shape = shape
	
	# Assemble
	body.add_child(sprite)
	body.add_child(collision)
	parent.add_child(body)
	body.owner = root
	sprite.owner = root
	collision.owner = root
	
	# Script based on type
	var code = _get_character_script(char_type, char_name)
	var script_path = "res://" + char_name.to_lower() + ".gd"
	var script = GDScript.new()
	script.source_code = code
	ResourceSaver.save(script, script_path)
	_editor_filesystem.scan()
	script = load(script_path)
	body.set_script(script)
	
	_editor_interface.save_scene()
	return {"success": true, "character": char_name, "type": char_type, "script": script_path}

func _get_character_script(char_type: String, char_name: String) -> String:
	match char_type:
		"platformer":
			return """extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
"""
		"topdown":
			return """extends CharacterBody2D

const SPEED = 200.0

func _physics_process(_delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	velocity = input.normalized() * SPEED
	move_and_slide()
"""
		_:
			return """extends CharacterBody2D

func _ready():
	pass

func _physics_process(_delta):
	pass
"""

func _set_main_scene(params: Dictionary) -> Dictionary:
	var scene_path = params.get("scene_path", "")
	if scene_path.is_empty():
		return {"error": "No scene_path provided"}
	if not scene_path.begins_with("res://"):
		scene_path = "res://" + scene_path
	
	ProjectSettings.set_setting("application/run/main_scene", scene_path)
	ProjectSettings.save()
	return {"success": true, "main_scene": scene_path}

# ═══════════════════════════════════════════════════════════════
# HTTP HELPERS
# ═══════════════════════════════════════════════════════════════

func _send_json(client: StreamPeerTCP, status_code: int, data: Dictionary):
	var body = JSON.stringify(data)
	var body_bytes = body.to_utf8_buffer()
	var header = "HTTP/1.1 %d OK\r\n" % status_code
	header += "Content-Type: application/json; charset=utf-8\r\n"
	header += "Content-Length: %d\r\n" % body_bytes.size()
	header += "Access-Control-Allow-Origin: *\r\n"
	header += "Connection: close\r\n"
	header += "\r\n"
	client.put_data(header.to_utf8_buffer())
	client.put_data(body_bytes)

func _send_error(client: StreamPeerTCP, status_code: int, message: String):
	_send_json(client, status_code, {"error": message})
