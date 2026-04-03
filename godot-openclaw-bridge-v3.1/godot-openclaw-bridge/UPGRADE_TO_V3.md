# 🚀 Upgrade to v3.0

## What's New

### ✅ Script Bug FIXED
```
ΠΡΙΝ: Bot λέει "Script saved!" αλλά editor δεν το δείχνει
ΜΕΤΑ: Script εμφανίζεται άμεσα, με verification
```

**Το πρόβλημα:** Το Godot 4.x χρειάζεται ειδικό handling για script reload.

**Η λύση:**
1. Save script to disk
2. Editor filesystem scan
3. Reload from disk (CRITICAL)
4. Attach with undo/redo integration
5. Mark scene modified
6. Verify attachment

### ⚡ Ultra-Fast Performance
- Connection pooling (5 connections)
- Batch operations (πολλά commands σε ένα call)
- Optimized timeouts

### 🎮 New Commands
| Command | Description |
|---------|-------------|
| `batch` | Πολλαπλά commands μαζί |
| `duplicate_node` | Αντιγραφή node |
| `reparent_node` | Αλλαγή parent |
| `rename_node` | Μετονομασία |
| `get_node_info` | Λεπτομέρειες + script status |
| `get_script` | Διάβασμα script |
| `reload_scripts` | Force refresh |
| `undo` / `redo` | Undo/Redo |
| `select_node` | Επιλογή στον editor |

---

## Installation

### 1. Backup (προαιρετικό)
```bash
cd C:\Users\paylos\Documents\GodotProjects\Test
xcopy /E /I addons\openclaw_bridge addons\openclaw_bridge_backup
```

### 2. Copy New Files
```bash
# Από το godot-openclaw-bridge repo:
xcopy /E /I addons\openclaw_bridge\openclaw_bridge_v3.gd C:\Users\paylos\Documents\GodotProjects\Test\addons\openclaw_bridge\
```

### 3. Update Plugin
Edit `addons/openclaw_bridge/plugin.gd`:
```gdscript
# ΠΑΛΙΟ:
const OpenClawBridge = preload("openclaw_bridge.gd")

# ΝΕΟ:
const OpenClawBridge = preload("openclaw_bridge_v3.gd")
```

### 4. Restart Godot
- Disable plugin
- Enable plugin
- Θα δεις: `[OpenClaw v3] MCP server on port 7450`

### 5. Run New Bridge
```bash
python godot_bridge_v3.py
```

### 6. Test
```bash
python test_v3.py
```

---

## Usage Examples

### Create Player with Script
```bash
# Ένα call για όλα
curl -X POST http://localhost:8080/ \
  -H "Content-Type: application/json" \
  -d '{
    "batch": [
      {"cmd": "create_scene", "name": "Player", "root": "CharacterBody2D"},
      {"cmd": "add_node", "parent": ".", "name": "Sprite", "type": "Sprite2D"},
      {"cmd": "add_script", "node": "Player", "script_name": "player", "code": "extends CharacterBody2D\n\nvar speed = 300\n\nfunc _physics_process(delta):\n    velocity = Input.get_vector(\"ui_left\", \"ui_right\", \"ui_up\", \"ui_down\") * speed\n    move_and_slide()"}
    ]
  }'
```

### Verify Script Attached
```bash
curl "http://localhost:8080/?cmd=get_node_info&node=Player"

# Response:
{
  "name": "Player",
  "has_script": true,
  "script_attached": true,
  "script_path": "res://player.gd"
}
```

### Batch Operations
```bash
curl -X POST http://localhost:8080/ \
  -d '{"batch": [
    {"cmd": "add_node", "parent": ".", "name": "Enemy1", "type": "CharacterBody2D"},
    {"cmd": "add_node", "parent": "Enemy1", "name": "Sprite", "type": "Sprite2D"},
    {"cmd": "duplicate_node", "node": "Enemy1", "new_name": "Enemy2"}
  ]}'
```

---

## Telegram Bot Integration

Το bot σου τώρα μπορεί να κάνει:

```python
# Πριν (αργό):
requests.get("http://localhost:8080/?cmd=add_node...")
requests.get("http://localhost:8080/?cmd=add_script...")
requests.get("http://localhost:8080/?cmd=run_game...")

# Μετά (γρήγορο):
requests.post("http://localhost:8080/", json={
    "batch": [
        {"cmd": "add_node", ...},
        {"cmd": "add_script", ...},
        {"cmd": "run_game"}
    ]
})
```

### Script Verification
```python
# Μετά το add_script, έλεγξε:
response = requests.get("http://localhost:8080/?cmd=get_node_info&node=Player")
data = response.json()

if data.get("script_attached"):
    print("✅ Script attached successfully!")
else:
    print("❌ Script not attached")
    # Auto-fix
    requests.get("http://localhost:8080/?cmd=reload_scripts")
```

---

## Troubleshooting

### "Script not showing in editor"
```bash
# Force reload
curl "http://localhost:8080/?cmd=reload_scripts"

# Ή κάνε focus σε άλλο node και πίσω
```

### "Node not found"
```bash
# Δες το scene tree
curl "http://localhost:8080/?cmd=get_scene_tree"

# Χρησιμοποίησε fuzzy matching - αρκεί το όνομα
```

### "Connection refused"
```bash
# Έλεγξε αν το plugin είναι enabled
# Έλεγξε αν ο Godot τρέχει
# Έλεγξε το port 7450
```
