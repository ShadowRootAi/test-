# 🎮 Godot OpenClaw Bridge

<p align="center">
  <img src="https://img.shields.io/github/stars/pavlos1323456/godot-openclaw-bridge?style=for-the-badge&color=ff6b6b" alt="Stars">
  <img src="https://img.shields.io/github/license/pavlos1323456/godot-openclaw-bridge?style=for-the-badge&color=4ecdc4" alt="License">
  <img src="https://img.shields.io/badge/Godot-4.x-blue?style=for-the-badge&logo=godot-engine" alt="Godot 4.x">
  <img src="https://img.shields.io/badge/MCP-Protocol-orange?style=for-the-badge" alt="MCP">
</p>

<p align="center">
  <b>Control Godot Editor with AI. Build games with natural language.</b>
</p>

<p align="center">
  <a href="#-demo">🎬 Demo</a> •
  <a href="#-features">✨ Features</a> •
  <a href="#-quick-start">🚀 Quick Start</a> •
  <a href="#-examples">📚 Examples</a> •
  <a href="#-architecture">🏗️ Architecture</a>
</p>

---

## 🎬 Demo

> *"Create a player with WASD movement and a jumping animation"*

```
✅ Scene created: Player.tscn
✅ Node added: CharacterBody2D → Player
✅ Node added: Sprite2D → Sprite
✅ Node added: AnimationPlayer → AnimationPlayer
✅ Script written: player.gd
✅ Game started successfully
```

**⏱️ Time taken: 3 seconds**

---

## ✨ Features

### 🎮 Scene Management
- ✅ Create scenes programmatically
- ✅ Add/remove/duplicate nodes
- ✅ Modify properties in real-time
- ✅ Manage scene hierarchy

### 📝 Scripting
- ✅ Write GDScript via AI
- ✅ Edit existing scripts
- ✅ Auto-attach scripts to nodes
- ✅ **Hot-reload support** (v3.0+)

### 🏃 Game Control
- ✅ Play/Stop game from editor
- ✅ Inspect output logs
- ✅ Debug running games

### ⚡ Ultra-Fast (v3.0)
- 🔥 **Connection pooling** - 2-3x faster
- 🔥 **Batch operations** - multiple commands in one call
- 🔥 **Smart caching** - reduced latency

---

## 🚀 Quick Start

### 1. Install Plugin

```bash
# Clone the repo
git clone https://github.com/pavlos1323456/godot-openclaw-bridge.git

# Copy to your Godot project
cp -r godot-openclaw-bridge/addons/openclaw_bridge your-project/addons/
```

### 2. Enable in Godot

1. Open **Project → Project Settings → Plugins**
2. Find **"OpenClaw Bridge"**
3. Click **Enable**

### 3. Run the Bridge

```bash
# Terminal 1: Run HTTP bridge
python godot_bridge_v3.py

# Terminal 2: Test it
curl "http://localhost:8080/?cmd=status"
```

### 4. Connect Your Bot

```python
import requests

# Create a player scene
requests.post("http://localhost:8080/", json={
    "batch": [
        {"cmd": "create_scene", "name": "Player", "root": "CharacterBody2D"},
        {"cmd": "add_node", "parent": ".", "name": "Sprite", "type": "Sprite2D"},
        {"cmd": "add_script", "node": "Player", "code": "extends CharacterBody2D\n\nvar speed = 300\n\nfunc _physics_process(delta):\n    velocity = Input.get_vector('ui_left', 'ui_right', 'ui_up', 'ui_down') * speed\n    move_and_slide()"},
        {"cmd": "run_game"}
    ]
})
```

---

## 📚 Examples

### Create a Complete Game

```bash
curl -X POST http://localhost:8080/ \
  -H "Content-Type: application/json" \
  -d '{
    "batch": [
      {"cmd": "create_scene", "name": "Main", "root": "Node2D"},
      {"cmd": "create_color_rect", "parent": ".", "name": "Background", "w": 1920, "h": 1080, "r": 0.1, "g": 0.1, "b": 0.2},
      {"cmd": "add_node", "parent": ".", "name": "Player", "type": "CharacterBody2D"},
      {"cmd": "create_sprite", "parent": "Player", "name": "Sprite", "size": 64, "r": 0, "g": 0.8, "b": 0.2},
      {"cmd": "add_script", "node": "Player", "script_name": "player", "code": "extends CharacterBody2D\n\n@export var speed = 400\n@export var jump_velocity = -600\nvar gravity = ProjectSettings.get_setting(\"physics/2d/default_gravity\")\n\nfunc _physics_process(delta):\n    if not is_on_floor():\n        velocity.y += gravity * delta\n    \n    if Input.is_action_just_pressed(\"ui_accept\") and is_on_floor():\n        velocity.y = jump_velocity\n    \n    var direction = Input.get_axis(\"ui_left\", \"ui_right\")\n    if direction:\n        velocity.x = direction * speed\n    else:\n        velocity.x = move_toward(velocity.x, 0, speed)\n    \n    move_and_slide()"},
      {"cmd": "save_scene"},
      {"cmd": "run_game"}
    ]
  }'
```

**Result:** A playable platformer in 5 seconds ⚡

### More Examples

See [EXAMPLES.md](EXAMPLES.md) for:
- RPG character creation
- UI layout generation
- Animation setup
- AI NPC scripting
- Multiplayer boilerplate

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Telegram Bot / Discord Bot / Custom AI                     │
│  └─ HTTP GET/POST ──▶ localhost:8080                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │ HTTP Bridge │  (Python - Connection Pool)
                    │  (v3.0)     │
                    └──────┬──────┘
                           │ JSON-RPC
                    ┌──────▼──────┐
                    │ Godot Plugin│  (GDScript - Port 7450)
                    │  MCP Server │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ Godot Editor│
                    │  (Live API) │
                    └─────────────┘
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed protocol documentation.

---

## 📊 Benchmarks

| Operation | v2.1 | v3.0 | Improvement |
|-----------|------|------|-------------|
| Create Scene | 120ms | 45ms | **2.7x** |
| Add Script | 200ms | 85ms | **2.4x** |
| Batch (5 ops) | 800ms | 150ms | **5.3x** |
| Connection | New each | Pooled | **∞** |

---

## 🎯 Use Cases

### 🤖 AI Game Development
Build entire games with natural language:
> *"Create a 2D platformer with a player, enemies, coins, and a win condition"*

### 🧪 Rapid Prototyping
Test ideas in seconds:
> *"Make a top-down shooter with WASD movement and mouse aiming"*

### 📚 Learning Godot
See how things work:
> *"Show me how to make a State Machine in GDScript"*

### 🎮 Live Demos
Control Godot from chat during streams

---

## 🔧 Supported Commands

### Scene Management
- `create_scene` - Create new scene
- `save_scene` - Save current scene
- `get_scene_tree` - List all nodes
- `add_node` - Add node to scene
- `remove_node` - Delete node
- `duplicate_node` - Copy node
- `reparent_node` - Change parent
- `rename_node` - Rename node

### Properties
- `set_property` - Set single property
- `set_properties` - Set multiple properties
- `get_property` - Read property value

### Scripts
- `add_script` - Create and attach script (v3.0: auto-reload)
- `edit_script` - Modify existing script
- `get_script` - Read script content
- `reload_scripts` - Force editor refresh

### Game Control
- `run_game` - Play current scene
- `stop_game` - Stop game
- `undo` / `redo` - Editor undo/redo

### Files
- `list_files` - Browse project files
- `read_file` - Read file content
- `write_file` - Write file
- `delete_file` - Delete file

See [MASTER_COMMAND_LIST.md](MASTER_COMMAND_LIST.md) for full reference.

---

## 🛡️ Security

⚠️ **Important:** This plugin allows remote code execution.

- ✅ **Localhost only** - Binds to 127.0.0.1
- ✅ **Development use** - Don't expose to internet
- ✅ **Trusted networks** - Use VPN if remote access needed

---

## 🤝 Contributing

We love contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Setting up dev environment
- Adding new commands
- Reporting bugs
- Suggesting features

---

## 📝 Changelog

### v3.0 (2026-04-05)
- ⚡ **Ultra-fast** - Connection pooling, 2-3x speedup
- 🔧 **Script bug fixed** - Scripts now appear immediately
- 🎮 **New commands** - duplicate, reparent, rename, undo, redo
- 📦 **Batch operations** - Multiple commands in one call
- ✅ **Verification** - Check if scripts attached correctly

### v2.1 (2026-03-28)
- Initial stable release
- Basic scene/node/script control
- HTTP bridge
- Telegram bot integration

See [CHANGELOG.md](CHANGELOG.md) for full history.

---

## 💬 Community

- 💬 [Discord](https://discord.gg/godotengine) - Mention "OpenClaw Bridge"
- 🐦 [Twitter/X](https://twitter.com) - Tag us with your creations
- 📺 [YouTube](https://youtube.com) - Tutorials coming soon

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=pavlos1323456/godot-openclaw-bridge&type=Date)](https://star-history.com/#pavlos1323456/godot-openclaw-bridge&Date)

---

## 📄 License

MIT © [pavlos1323456](https://github.com/pavlos1323456)

---

<p align="center">
  <b>Made with ❤️ for the Godot community</b>
</p>

<p align="center">
  <a href="https://github.com/pavlos1323456/godot-openclaw-bridge/stargazers">⭐ Star this repo</a> •
  <a href="https://github.com/pavlos1323456/godot-openclaw-bridge/fork">🍴 Fork it</a> •
  <a href="https://github.com/pavlos1323456/godot-openclaw-bridge/issues">🐛 Report issues</a>
</p>
