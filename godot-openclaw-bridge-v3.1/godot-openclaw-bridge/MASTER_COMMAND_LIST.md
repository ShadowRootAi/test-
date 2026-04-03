# 🤖 GODOT BOT - COMPLETE COMMAND LIST

## 📋 QUICK SYNTAX

```
GET http://localhost:8080/?cmd=COMMAND&param1=value1&param2=value2
POST http://localhost:8080/ {json body}
```

---

## 🎮 1. SCENE COMMANDS

| Command | Description | Example |
|---------|-------------|---------|
| `create_scene` | Νέα σκηνή | `?cmd=create_scene&name=Level1&root=Node2D` |
| `save_scene` | Αποθήκευση | `?cmd=save_scene` |
| `get_scene_tree` | Δείξε δέντρο | `?cmd=get_scene_tree` |
| `status` | Info project | `?cmd=status` |

**Parameters:**
- `name` - όνομα σκηνής
- `root` - τύπος root (Node2D, Node3D, Control)

---

## 🟦 2. CREATE COMMANDS (Τα πιο εύκολα!)

### create_sprite - Sprite2D με χρώμα
```
?cmd=create_sprite&name=Player&x=100&y=200&size=64&r=1&g=0&b=0
```
**Params:** `name` (req), `x`, `y`, `size` (default:64), `r`, `g`, `b` (default:1,0,0)

### create_color_rect - ColorRect
```
?cmd=create_color_rect&name=Platform&x=0&y=500&w=200&h=50&r=0&g=1&b=0
```
**Params:** `name` (req), `x`, `y`, `w` (width), `h` (height), `r`, `g`, `b`

### add_node - Γενικός κόμβος
```
?cmd=add_node&parent=.&name=Camera&type=Camera2D
```
**Params:** `parent` (default:.), `name`, `type`

**Common types:**
- `Sprite2D`, `ColorRect`, `Camera2D`
- `CharacterBody2D`, `RigidBody2D`, `StaticBody2D`
- `Area2D`, `CollisionShape2D`
- `Label`, `Button`, `Panel`
- `AnimatedSprite2D`, `AudioStreamPlayer2D`
- `Node2D`, `Node` (container)

---

## 🗑️ 3. REMOVE COMMANDS

### remove_node - Διαγραφή
```
?cmd=remove_node&node=OldSprite
?cmd=remove_node&name=Player
?cmd=remove_node&path=Enemy
```
**Params:** `node` ή `name` ή `path`

---

## ⚙️ 4. PROPERTY COMMANDS

### set_property - Μία property
```
?cmd=set_property&node=Player&prop=position&value={"x":100,"y":200}
?cmd=set_property&node=Player&prop=visible&value=false
?cmd=set_property&node=Player&prop=rotation&value=1.57
```

### set_properties - Πολλές (POST)
```json
POST / {
  "tool": "set_properties",
  "args": {
    "node_path": "Player",
    "properties": {
      "position": {"x": 100, "y": 200},
      "scale": {"x": 2, "y": 2},
      "rotation": 1.57,
      "visible": true,
      "modulate": {"r": 1, "g": 0, "b": 0}
    }
  }
}
```

---

## 🎨 5. ALL PROPERTIES BY NODE TYPE

### 🖼️ SPRITE2D
```
position:     {"x": 100, "y": 200}
rotation:     1.57 (radians, π/2 = 90°)
scale:        {"x": 2, "y": 2}
visible:      true / false
modulate:     {"r": 1, "g": 0, "b": 0} (color)
flip_h:       true / false
flip_v:       true / false
z_index:      1 (higher = front)
offset:       {"x": 32, "y": 32}
```

### 🟩 COLORRECT
```
position:     {"x": 0, "y": 0}
size:         {"x": 200, "y": 100} (width, height)
color:        {"r": 0, "g": 1, "b": 0}
rotation:     0
scale:        {"x": 1, "y": 1}
visible:      true / false
```

### 📷 CAMERA2D
```
position:            {"x": 0, "y": 0}
zoom:                {"x": 1, "y": 1} (2 = zoom out, 0.5 = zoom in)
offset:              {"x": 0, "y": 0}
rotation:            0
enabled:             true / false
current:             true / false
smoothing_enabled:   true / false
smoothing_speed:     5.0
limit_left:          -1000
limit_right:         1000
limit_top:           -1000
limit_bottom:        1000
```

### 🎮 CHARACTERBODY2D
```
position:            {"x": 100, "y": 0}
velocity:            {"x": 0, "y": 0}
rotation:            0
scale:               {"x": 1, "y": 1}
motion_mode:         0 (grounded) / 1 (floating)
up_direction:        {"x": 0, "y": -1}
floor_max_angle:     0.785
```

### 🎭 ANIMATEDSPRITE2D
```
position:            {"x": 0, "y": 0}
animation:           "run" / "idle" / "jump"
frame:               0
frame_progress:      0.5
speed_scale:         1.0 (2.0 = 2x faster)
playing:             true / false
flip_h:              true / false
flip_v:              true / false
```

### 📝 LABEL
```
position:            {"x": 100, "y": 100}
text:                "Hello World"
modulate:            {"r": 1, "g": 1, "b": 1}
scale:               {"x": 2, "y": 2}
visible:             true / false
```

### 🔊 AUDIOSTREAMPLAYER2D
```
volume_db:           0.0 (0 = max, -80 = mute)
pitch_scale:         1.0 (2.0 = higher pitch)
playing:             true / false
autoplay:            true / false
max_distance:        2000
bus:                 "Master"
```

### 🌍 NODE2D (Base)
```
position:            {"x": 100, "y": 200}
rotation:            1.57
scale:               {"x": 2, "y": 2}
visible:             true / false
modulate:            {"r": 1, "g": 1, "b": 1}
z_index:             0
y_sort_enabled:      true / false
top_level:           true / false
```

---

## 📝 6. SCRIPT COMMANDS

### add_script - Προσθήκη script
```
POST / {
  "tool": "add_script",
  "args": {
    "node_path": "Player",
    "code": "extends Sprite2D\n\nvar speed = 400\n\nfunc _process(delta):\n    var direction = Input.get_vector(\"ui_left\", \"ui_right\", \"ui_up\", \"ui_down\")\n    position += direction * speed * delta"
  }
}
```

### edit_script - Επεξεργασία
```
POST / {
  "tool": "edit_script",
  "args": {
    "script_path": "res://Player.gd",
    "code": "extends Sprite2D\n\nfunc _ready():\n    print(\"Hello\")"
  }
}
```

---

## 🎮 7. GAME COMMANDS

| Command | Description | Example |
|---------|-------------|---------|
| `run_game` | Εκκίνηση | `?cmd=run_game` |
| `stop_game` | Σταμάτημα | `?cmd=stop_game` |

---

## 📁 8. FILE COMMANDS

| Command | Description | Example |
|---------|-------------|---------|
| `list_files` | Λίστα | `?cmd=list_files&path=res://` |
| `read_file` | Ανάγνωση | `?cmd=read_file&path=res://Player.gd` |
| `write_file` | Εγγραφή | `?cmd=write_file&path=res://test.txt&content=hello` |
| `delete_file` | Διαγραφή | `?cmd=delete_file&path=res://old.gd` |

---

## 🎯 9. COMPLETE WORKFLOWS

### Φτιάξε Player με movement:
```python
# 1. Sprite με χρώμα
GET /?cmd=create_sprite&name=Player&x=300&y=200&r=0&g=0.5&b=1

# 2. Script (POST)
POST / {"tool":"add_script","args":{"node_path":"Player","code":"extends Sprite2D\n\nvar speed = 400\n\nfunc _process(delta):\n    var direction = Input.get_vector(\"ui_left\", \"ui_right\", \"ui_up\", \"ui_down\")\n    position += direction * speed * delta"}}

# 3. Camera που ακολουθεί
GET /?cmd=add_node&parent=Player&name=Camera&type=Camera2D
GET /?cmd=set_property&node=Camera&prop=current&value=true

# 4. Save & Run
GET /?cmd=save_scene
GET /?cmd=run_game
```

### Φτιάξε Platformer Level:
```python
# Ground
GET /?cmd=create_color_rect&name=Ground&x=0&y=500&w=800&h=100&r=0.3&g=0.3&b=0.3

# Platforms
GET /?cmd=create_color_rect&name=P1&x=200&y=400&w=100&h=20&r=0.5&g=0.3&b=0.1
GET /?cmd=create_color_rect&name=P2&x=400&y=300&w=100&h=20&r=0.5&g=0.3&b=0.1
GET /?cmd=create_color_rect&name=P3&x=600&y=200&w=100&h=20&r=0.5&g=0.3&b=0.1

# Player
GET /?cmd=create_sprite&name=Player&x=100&y=400&r=1&g=0&b=0

# Enemy
GET /?cmd=create_sprite&name=Enemy&x=500&y=350&size=50&r=1&g=0&b=0
GET /?cmd=set_property&node=Enemy&prop=modulate&value={"r":1,"g":0,"b":0}

# Save
GET /?cmd=save_scene
```

### Animation sequence:
```python
# Frame 1
GET /?cmd=set_property&node=Player&prop=position&value={"x":0,"y":0}
GET /?cmd=set_property&node=Player&prop=scale&value={"x":1,"y":1}

# Frame 2
GET /?cmd=set_property&node=Player&prop=position&value={"x":50,"y":0}
GET /?cmd=set_property&node=Player&prop=scale&value={"x":1.2,"y":0.8}

# Frame 3
GET /?cmd=set_property&node=Player&prop=position&value={"x":100,"y":0}
GET /?cmd=set_property&node=Player&prop=scale&value={"x":1,"y":1}
```

### Color flash effect:
```python
GET /?cmd=set_property&node=Player&prop=modulate&value={"r":1,"g":0,"b":0}
GET /?cmd=set_property&node=Player&prop=modulate&value={"r":1,"g":1,"b":1}
GET /?cmd=set_property&node=Player&prop=modulate&value={"r":1,"g":0,"b":0}
GET /?cmd=set_property&node=Player&prop=modulate&value={"r":1,"g":1,"b":1}
```

---

## 🎨 10. COLOR VALUES (RGB)

| Color | R | G | B | Value |
|-------|---|---|---|-------|
| 🔴 Red | 1 | 0 | 0 | `{"r":1,"g":0,"b":0}` |
| 🟢 Green | 0 | 1 | 0 | `{"r":0,"g":1,"b":0}` |
| 🔵 Blue | 0 | 0 | 1 | `{"r":0,"g":0,"b":1}` |
| 🟡 Yellow | 1 | 1 | 0 | `{"r":1,"g":1,"b":0}` |
| 🟣 Purple | 1 | 0 | 1 | `{"r":1,"g":0,"b":1}` |
| 🩵 Cyan | 0 | 1 | 1 | `{"r":0,"g":1,"b":1}` |
| ⚪ White | 1 | 1 | 1 | `{"r":1,"g":1,"b":1}` |
| ⚫ Black | 0 | 0 | 0 | `{"r":0,"g":0,"b":0}` |
| 🟠 Orange | 1 | 0.5 | 0 | `{"r":1,"g":0.5,"b":0}` |
| 🩷 Pink | 1 | 0 | 0.5 | `{"r":1,"g":0,"b":0.5}` |
| 🩶 Gray | 0.5 | 0.5 | 0.5 | `{"r":0.5,"g":0.5,"b":0.5}` |

---

## 🔢 11. COMMON VALUES

### Rotation (radians):
- 0° = `0`
- 45° = `0.785`
- 90° = `1.57`
- 180° = `3.14`
- 360° = `6.28`

### Scale:
- Normal = `{"x":1,"y":1}`
- Double = `{"x":2,"y":2}`
- Half = `{"x":0.5,"y":0.5}`
- Flip X = `{"x":-1,"y":1}`

### Z-Index (layers):
- Background: `-10` to `-1`
- Default: `0`
- Player: `10`
- UI: `100`

---

## ⚠️ 12. IMPORTANT NOTES

1. **Πάντα save:** `GET /?cmd=save_scene` μετά από αλλαγές
2. **URL Encoding:** Space=%20, "=%22, {=%7B, }=%7D
3. **POST για scripts:** Μεγάλα strings χρειάζονται POST
4. **Names:** Να είναι unique σε κάθε σκηνή
5. **Types:** Sprite2D, Camera2D, κλπ (case-sensitive)

---

## 💡 13. TIPS FOR BOT

- **create_sprite** = πιο εύκολο από add_node + script
- **create_color_rect** = για platforms, UI, backgrounds
- **set_properties** (POST) = για πολλές αλλαγές μαζί
- **remove_node** = δουλεύει με όνομα (δεν χρειάζεται full path)
- **modulate** = αλλαγή χρώματος χωρίς texture

---

**🎮 Είσαι έτοιμος να φτιάξεις games μέσω Telegram!**
