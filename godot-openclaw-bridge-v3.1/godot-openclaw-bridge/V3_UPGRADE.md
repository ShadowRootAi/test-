# Godot OpenClaw Bridge v3.0
## Ultra-Fast Human-Like Godot Control

**Νέα features:**
- ⚡ Connection pooling για ταχύτητα
- 🔄 Σωστό script reload με editor refresh  
- 🎯 Smart node finding (fuzzy search)
- 📦 Batch operations (πολλαπλά commands σε ένα call)
- 🧠 Better error messages
- ✓ Verification - επιβεβαίωση ότι εφαρμόστηκαν οι αλλαγές
- 🎮 Extended commands (undo, duplicate, reparent, etc)

---

## Γρήγορο ξεκίνημα

```bash
# 1. Copy to Godot project
xcopy /E /I addons\openclaw_bridge C:\Users\paylos\Documents\GodotProjects\Test\addons\openclaw_bridge

# 2. Enable plugin in Godot (Project Settings -> Plugins)

# 3. Run bridge
python godot_bridge_v3.py

# 4. Test
curl "http://localhost:8080/?cmd=status"
```

---

## Key Improvements

### Script Bug Fixed ✅
```python
# ΠΡΙΝ: Script φαινόταν σωστό αλλά editor δεν το έδειχνε
# ΜΕΤΑ: Script reload + editor refresh + verification

# Το νέο add_script κάνει:
1. Save script to disk
2. Reload from disk (CRITICAL)
3. Attach to node
4. Mark scene as modified  
5. Editor file system scan
6. Save scene
7. VERIFY: script actually attached
```

### Batch Commands
```python
# Ένα call για πολλές ενέργειες
{
  "batch": [
    {"cmd": "create_scene", "name": "Player", "root": "CharacterBody2D"},
    {"cmd": "add_node", "parent": ".", "name": "Sprite", "type": "Sprite2D"},
    {"cmd": "add_script", "node": "Player", "code": "..."}
  ]
}
```

### Fuzzy Node Finding
```python
# Βρίσκει node ακόμα και με partial name
"Player" → matches "Player", "MainPlayer", "PlayerCharacter"
```

---

## New Commands

| Command | Description |
|---------|-------------|
| `batch` | Πολλαπλά commands σε ένα call |
| `duplicate_node` | Αντιγραφή node |
| `reparent_node` | Αλλαγή parent |
| `rename_node` | Μετονομασία |
| `get_node_info` | Λεπτομέρειες node |
| `set_script_property` | Αλλαγή property σε script |
| `reload_scripts` | Force script refresh |
| `undo` | Undo last action |
| `redo` | Redo |
| `clear_output` | Καθαρισμός console |
| `get_selected_nodes` | Ποια nodes είναι selected |
| `select_node` | Επιλογή node |

---

## API Examples

### Create Player with Script
```bash
curl -X POST http://localhost:8080/ \
  -H "Content-Type: application/json" \
  -d '{
    "batch": [
      {"cmd": "create_scene", "name": "Player", "root": "CharacterBody2D"},
      {"cmd": "add_node", "parent": ".", "name": "Sprite", "type": "Sprite2D"},
      {"cmd": "add_script", "node": "Player", "script_name": "player_controller", "code": "extends CharacterBody2D\n\nvar speed = 300\n\nfunc _physics_process(delta):\n    velocity = Input.get_vector(\"ui_left\", \"ui_right\", \"ui_up\", \"ui_down\") * speed\n    move_and_slide()"}
    ]
  }'
```

### Verify Script Attached
```bash
curl "http://localhost:8080/?cmd=get_node_info&node=Player"
# Returns: {"script_attached": true, "script_path": "res://player_controller.gd"}
```
