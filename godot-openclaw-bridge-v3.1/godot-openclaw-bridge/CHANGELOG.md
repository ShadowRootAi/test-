# 📝 Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [3.1.0] - 2026-04-03 - Bug Fixes & Game Dev Tools

### Fixed
- **CRITICAL: plugin.gd loaded v2 instead of v3** — `preload("openclaw_bridge.gd")` → `preload("openclaw_bridge_v3.gd")`. The v3 code was never actually running!
- **Content-Length byte count** — Used char count instead of UTF-8 byte count, corrupting non-ASCII responses
- **`_clear_output` crash** — Called non-existent `get_output_log()` Godot 4.x API method
- **`_get_node_info` type checks** — Used `has_method()` for properties; now uses `is GDScript`
- **`_reparent_node` position loss** — Now preserves `global_position` and recursively re-owns children
- **`_parse_value` expanded** — Added rotation, modulate, global_position, velocity, z_index, Rect2, bool

### Added
- `create_collision_shape` — CollisionShape2D + RectangleShape2D in one call
- `create_camera` — Camera2D with zoom and smoothing
- `create_label` — Label for UI/HUD with font_size
- `create_area2d` — Area2D with collision for triggers/pickups
- `create_timer_node` — Timer with wait_time, one_shot, autostart
- `create_full_character` — Complete character (body + sprite + collision + script) in one call
- `set_main_scene` — Set project main scene for F5

---

## [3.0.0] - 2026-04-05

### ⚡ Performance
- **Connection pooling** - 5 persistent connections for 2-3x speedup
- **Batch operations** - Execute multiple commands in single HTTP call
- **Optimized timeouts** - 2 second default for local connections

### 🔧 Fixed
- **Script reload bug** - Scripts now appear immediately in editor
  - Added filesystem scan after script save
  - Force reload from disk before attach
  - Undo/redo integration for proper editor state
  - Verification that script actually attached

### 🎮 Added
- New commands:
  - `duplicate_node` - Copy existing nodes
  - `reparent_node` - Change node parent
  - `rename_node` - Rename nodes
  - `get_node_info` - Detailed node info + script verification
  - `get_property` - Read property values
  - `get_script` - Read script source code
  - `reload_scripts` - Force editor refresh
  - `select_node` - Select in editor
  - `get_selected_nodes` - Get current selection
  - `undo` / `redo` - Editor undo/redo
  - `clear_output` - Clear output panel

### 📦 Changed
- Bridge now returns `_timing.total_ms` for performance monitoring
- Improved error messages with context
- Better CORS support for web clients

### 📚 Documentation
- New README with badges and benchmarks
- Added UPGRADE_TO_V3.md migration guide
- Added CONTRIBUTING.md
- Added this CHANGELOG.md

---

## [2.1.0] - 2026-03-30

### 🔧 Fixed
- Script attachment now uses proper reload from disk
- Added `script_name` parameter for custom filenames

### 🎮 Added
- `set_properties` - Set multiple properties at once
- Script verification in response

---

## [2.0.0] - 2026-03-28

### 🎉 Initial Stable Release

First production-ready version with:

- ✅ Godot Editor MCP server (port 7450)
- ✅ HTTP Bridge for easy bot integration (port 8080)
- ✅ Scene creation and management
- ✅ Node manipulation (add, remove, modify)
- ✅ Script creation and editing
- ✅ Property editing
- ✅ Game control (play/stop)
- ✅ File I/O operations

### 🎮 Commands
- `create_scene`, `save_scene`, `get_scene_tree`
- `add_node`, `remove_node`, `create_sprite`, `create_color_rect`
- `set_property`, `add_script`, `edit_script`
- `run_game`, `stop_game`
- `list_files`, `read_file`, `write_file`, `delete_file`

### 📚 Documentation
- README.md
- ARCHITECTURE.md
- EXAMPLES.md
- SETUP_GUIDE.md
- MASTER_COMMAND_LIST.md

---

## [1.0.0] - 2026-03-19

### 🚀 First Release

Initial proof of concept with basic scene manipulation.

---

## Planned for Future

- [ ] C# script support
- [ ] Visual scripting nodes
- [ ] Shader editing
- [ ] Asset import automation
- [ ] Multi-project support
- [ ] WebSocket transport
- [ ] Authentication/Security layer
- [ ] VS Code extension

---

[3.0.0]: https://github.com/pavlos1323456/godot-openclaw-bridge/compare/v2.1.0...v3.0.0
[2.1.0]: https://github.com/pavlos1323456/godot-openclaw-bridge/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/pavlos1323456/godot-openclaw-bridge/releases/tag/v2.0.0
