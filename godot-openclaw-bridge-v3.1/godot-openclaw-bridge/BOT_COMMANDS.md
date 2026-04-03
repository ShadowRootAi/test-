# Godot OpenClaw Bridge v2.0 - Bot Commands Reference

## 🚀 QUICK START

```
GET http://localhost:8080/?cmd=create_sprite&name=Player&x=100&y=100&r=1&g=0&b=0
```

---

## 📋 ALL COMMANDS

### 1. create_sprite - Φτιάχνει Sprite2D με χρώμα
**Παράμετροι:**
- `name` (required) - Όνομα του sprite
- `x` (optional, default: 0) - Θέση X
- `y` (optional, default: 0) - Θέση Y  
- `size` (optional, default: 64) - Μέγεθος σε pixels
- `r` (optional, default: 1) - Κόκκινο (0-1)
- `g` (optional, default: 0) - Πράσινο (0-1)
- `b` (optional, default: 0) - Μπλε (0-1)

**Παραδείγματα:**
```
# Κόκκινο τετράγωνο 64x64 στο (100, 100)
GET /?cmd=create_sprite&name=Hero&x=100&y=100

# Μπλε τετράγωνο 100x100 στο (200, 150)
GET /?cmd=create_sprite&name=Enemy&x=200&y=150&size=100&r=0&g=0&b=1

# Πράσινο 32x32 στο (0, 0)
GET /?cmd=create_sprite&name=Coin&size=32&r=0&g=1&b=0
```

---

### 2. create_color_rect - Φτιάχνει ColorRect
**Παράμετροι:**
- `name` (required) - Όνομα
- `x` (optional, default: 0) - Θέση X
- `y` (optional, default: 0) - Θέση Y
- `w` (optional, default: 100) - Πλάτος
- `h` (optional, default: 100) - Ύψος
- `r`, `g`, `b` (optional) - Χρώμα (0-1)

**Παραδείγματα:**
```
# Πράσινο ορθογώνιο 200x50
GET /?cmd=create_color_rect&name=Platform&x=100&y=300&w=200&h=50&r=0&g=1&b=0

# Μωβ background
GET /?cmd=create_color_rect&name=Background&w=800&h=600&r=0.5&g=0&b=0.5
```

---

### 3. add_node - Γενικός κόμβος
**Παράμετροι:**
- `name` (required) - Όνομα κόμβου
- `type` (required) - Τύπος (Sprite2D, Node2D, CharacterBody2D, κλπ)
- `parent` (optional, default: ".") - Path γονέα

**Παραδείγματα:**
```
# CharacterBody2D για player
GET /?cmd=add_node&name=Player&type=CharacterBody2D

# Sprite2D ως child του Player
GET /?cmd=add_node&name=PlayerSprite&type=Sprite2D&parent=Player

# Camera2D
GET /?cmd=add_node&name=Camera&type=Camera2D
```

---

### 4. remove_node - Διαγραφή κόμβου
**Παράμετροι:**
- `node` (required) - Όνομα ή path κόμβου

**Παραδείγματα:**
```
GET /?cmd=remove_node&node=OldSprite
GET /?cmd=remove_node&node=Player
GET /?cmd=remove_node&node=Background
```

---

### 5. set_property - Ρύθμιση property
**Παράμετροι:**
- `node` (required) - Όνομα κόμβου
- `prop` (required) - Όνομα property
- `value` (required) - Τιμή

**Παραδείγματα:**
```
# Θέση
GET /?cmd=set_property&node=Player&prop=position&value={"x":100,"y":200}

# Scale
GET /?cmd=set_property&node=Player&prop=scale&value={"x":2,"y":2}

# Rotation
GET /?cmd=set_property&node=Player&prop=rotation&value=1.57

# Visible
GET /?cmd=set_property&node=Player&prop=visible&value=false

# Modulate (χρώμα)
GET /?cmd=set_property&node=Player&prop=modulate&value={"r":1,"g":0.5,"b":0.5}
```

---

### 6. set_properties - Πολλαπλά properties (POST)
**Για complex objects, χρησιμοποίησε POST:**

```json
POST http://localhost:8080/
{
  "tool": "set_properties",
  "args": {
    "node_path": "Player",
    "properties": {
      "position": {"x": 100, "y": 200},
      "scale": {"x": 1.5, "y": 1.5},
      "rotation": 0.5,
      "visible": true,
      "modulate": {"r": 1, "g": 0, "b": 0}
    }
  }
}
```

---

### 7. add_script - Προσθήκη script
**Παράμετροι:**
- `node` (required) - Όνομα κόμβου
- `code` (required) - Κώδικας GDScript

**Παράδειγμα:**
```
GET /?cmd=add_script&node=Player&code=extends%20Sprite2D%0A%0Afunc%20_ready()%3A%0A%20%20%20%20print(%22Hello!%22)
```

**Για μεγάλα scripts, χρησιμοποίησε POST:**
```json
POST http://localhost:8080/
{
  "tool": "add_script",
  "args": {
    "node_path": "Player",
    "code": "extends CharacterBody2D\n\nvar speed = 300\n\nfunc _physics_process(delta):\n    var direction = Input.get_vector(\"ui_left\", \"ui_right\", \"ui_up\", \"ui_down\")\n    velocity = direction * speed\n    move_and_slide()"
  }
}
```

---

### 8. edit_script - Επεξεργασία script file
**Παράμετροι:**
- `path` (required) - Path script (π.χ. res://Player.gd)
- `code` (required) - Νέος κώδικας

**Παράδειγμα:**
```
GET /?cmd=edit_script&path=res://Player.gd&code=extends%20Sprite2D
```

---

### 9. Scene Management

**create_scene** - Δημιουργία νέας σκηνής
```
GET /?cmd=create_scene&name=Level2&root=Node2D
```

**save_scene** - Αποθήκευση τρέχουσας σκηνής
```
GET /?cmd=save_scene
```

**get_scene_tree** - Προβολή δέντρου
```
GET /?cmd=get_scene_tree
```

---

### 10. Game Control

**run_game** - Εκκίνηση παιχνιδιού
```
GET /?cmd=run_game
```

**stop_game** - Σταμάτημα
```
GET /?cmd=stop_game
```

---

### 11. File Operations

**list_files** - Λίστα αρχείων
```
GET /?cmd=list_files&path=res://
```

**read_file** - Ανάγνωση
```
GET /?cmd=read_file&path=res://Player.gd
```

**write_file** - Εγγραφή
```
GET /?cmd=write_file&path=res://config.txt&content=hello%20world
```

**delete_file** - Διαγραφή
```
GET /?cmd=delete_file&path=res://old_file.gd
```

---

## 🎯 COMPLETE WORKFLOW EXAMPLES

### Δημιουργία Player με movement:
```
# 1. Φτιάξε τον player
GET /?cmd=create_sprite&name=Player&x=300&y=200&size=64&r=0&g=0.5&b=1

# 2. Πρόσθεσε script για movement
POST / {"tool":"add_script","args":{"node_path":"Player","code":"extends Sprite2D\n\nvar speed = 400\n\nfunc _process(delta):\n    var direction = Input.get_vector(\"ui_left\", \"ui_right\", \"ui_up\", \"ui_down\")\n    position += direction * speed * delta"}}

# 3. Save και run
GET /?cmd=save_scene
GET /?cmd=run_game
```

### Δημιουργία Platformer level:
```
# Ground
GET /?cmd=create_color_rect&name=Ground&x=0&y=500&w=800&h=100&r=0.3&g=0.3&b=0.3

# Platforms
GET /?cmd=create_color_rect&name=Platform1&x=200&y=400&w=100&h=20&r=0.5&g=0.3&b=0.1
GET /?cmd=create_color_rect&name=Platform2&x=400&y=300&w=100&h=20&r=0.5&g=0.3&b=0.1

# Player
GET /?cmd=create_sprite&name=Player&x=100&y=400&r=1&g=0&b=0

# Save
GET /?cmd=save_scene
```

---

## ⚠️ URL ENCODING

Για ειδικούς χαρακτήρες, χρησιμοποίησε URL encoding:
- Space → `%20`
- Newline → `%0A`
- `"` → `%22`
- `{` → `%7B`
- `}` → `%7D`

**Ή καλύτερα:** Χρησιμοποίησε POST requests για complex data!

---

## 🔥 BEST PRACTICES

1. **Πάντα save μετά από αλλαγές:** `GET /?cmd=save_scene`
2. **Χρησιμοποίησε create_sprite αντί για add_node + script** (είναι πιο εύκολο!)
3. **Για movement:** Πρόσθεσε script στο sprite με `_process` ή `_physics_process`
4. **Για πολλαπλά properties:** Χρησιμοποίησε `set_properties` με POST

---

## 📝 RESPONSE FORMAT

Όλα τα commands επιστρέφουν JSON:
```json
{
  "success": true,
  "node_name": "Player",
  "position": {"x": 100, "y": 200}
}
```

Σε περίπτωση error:
```json
{
  "error": "Node not found",
  "searched": "OldNode"
}
```
