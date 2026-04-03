---
name: godot-engine
description: Control Godot Editor through OpenClaw. Use when the user wants to create games, manage scenes, edit scripts, or control the Godot Editor remotely. Triggers on phrases like "create a game", "make a scene", "add a node", "edit script in Godot", "run the game", "build a game", "Godot project".
---

# Godot Engine Skill

This skill provides control over Godot Editor via the OpenClaw Bridge plugin.

## Prerequisites

1. Install the OpenClaw Bridge plugin in your Godot project:
   - Copy `addons/openclaw_bridge/` to your project's `addons/` folder
   - Enable it in Project → Project Settings → Plugins

2. The plugin runs an HTTP server on port **7450**

## Configuration

Set the Godot project path in your environment:
```bash
export GODOT_PROJECT_PATH=/path/to/your/godot/project
```

## Available Tools

### Scene Management
- `get_project_info` - Get project metadata
- `get_scene_tree` - Get current scene structure
- `create_scene` - Create new scene with root node
- `save_scene` - Save current scene

### Node Operations
- `add_node` - Add node to scene
- `remove_node` - Remove node from scene
- `set_property` - Set node property
- `get_property` - Get node property

### Scripting
- `add_script` - Add GDScript to node
- `edit_script` - Edit script file content

### File Operations
- `list_files` - List project files
- `read_file` - Read file content
- `write_file` - Write file content

### Game Control
- `run_game` - Play current scene
- `stop_game` - Stop running game

## Usage Examples

> "Create a new 2D scene called Player with a Sprite2D and CharacterBody2D"

> "Add WASD movement script to the Player node"

> "Change the background color to dark blue"

> "List all scenes in the project"

## Implementation

The skill communicates via HTTP JSON-RPC to the Godot plugin:
```
POST http://localhost:7450/mcp
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "add_node",
    "arguments": {...}
  },
  "id": 1
}
```