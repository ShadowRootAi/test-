# Godot Node Properties - Complete Reference

## 🎯 QUICK REFERENCE για το Bot

### Βασική σύνταξη:
```
GET /?cmd=set_property&node=Player&prop=PROPERTY_NAME&value=VALUE
```

### Για complex values (POST):
```json
POST / {
  "tool": "set_properties",
  "args": {
    "node_path": "Player",
    "properties": {
      "position": {"x": 100, "y": 200},
      "scale": {"x": 2, "y": 2}
    }
  }
}
```

---

## 📦 SPRITE2D PROPERTIES

| Property | Type | Example | Description |
|----------|------|---------|-------------|
| `position` | Vector2 | `{"x": 100, "y": 200}` | Θέση στον κόσμο |
| `rotation` | float | `1.57` | Περιστροφή σε radians (π/2 = 90°) |
| `scale` | Vector2 | `{"x": 2, "y": 2}` | Μέγεθος (1 = κανονικό) |
| `visible` | bool | `true` / `false` | Ορατότητα |
| `modulate` | Color | `{"r": 1, "g": 0, "b": 0}` | Χρώμα/αδιαφάνεια |
| `self_modulate` | Color | `{"r": 1, "g": 1, "b": 0}` | Τοπικό χρώμα |
| `flip_h` | bool | `true` / `false` | Οριζόντια αναστροφή |
| `flip_v` | bool | `true` / `false` | Κάθετη αναστροφή |
| `z_index` | int | `1` / `-1` | Σειρά εμφάνισης |
| `z_as_relative` | bool | `true` | Σχετικό z-index |
| `offset` | Vector2 | `{"x": 32, "y": 32}` | Offset texture |

**Examples:**
```
# Μετακίνηση
GET /?cmd=set_property&node=Player&prop=position&value={"x":100,"y":200}

# Περιστροφή 45°
GET /?cmd=set_property&node=Player&prop=rotation&value=0.785

# Διπλάσιο μέγεθος
GET /?cmd=set_property&node=Player&prop=scale&value={"x":2,"y":2}

# Κόκκινο χρώμα
GET /?cmd=set_property&node=Player&prop=modulate&value={"r":1,"g":0,"b":0}

# Αόρατο
GET /?cmd=set_property&node=Player&prop=visible&value=false
```

---

## 🟦 COLORRECT PROPERTIES

| Property | Type | Example | Description |
|----------|------|---------|-------------|
| `position` | Vector2 | `{"x": 100, "y": 200}` | Θέση |
| `size` | Vector2 | `{"x": 200, "y": 100}` | Μέγεθος (width/height) |
| `rotation` | float | `0.5` | Περιστροφή |
| `scale` | Vector2 | `{"x": 1, "y": 1}` | Scale |
| `color` | Color | `{"r": 1, "g": 0, "b": 0}` | Χρώμα fill |
| `visible` | bool | `true` | Ορατότητα |
| `modulate` | Color | `{"r": 1, "g": 1, "b": 1}` | Modulation |
| `z_index` | int | `0` | Z-order |

**Examples:**
```
# Άλλαγε μέγεθος
GET /?cmd=set_property&node=Platform&prop=size&value={"x":300,"y":50}

# Άλλαγε χρώμα
GET /?cmd=set_property&node=Platform&prop=color&value={"r":0,"g":1,"b":0}
```

---

## 📷 CAMERA2D PROPERTIES

| Property | Type | Example | Description |
|----------|------|---------|-------------|
| `position` | Vector2 | `{"x": 0, "y": 0}` | Θέση |
| `zoom` | Vector2 | `{"x": 1, "y": 1}` | Zoom (1 = normal, 2 = 2x) |
| `offset` | Vector2 | `{"x": 0, "y": 0}` | Offset |
| `rotation` | float | `0` | Περιστροφή |
| `anchor_mode` | int | `1` | 0=Fixed TopLeft, 1=Drag Center |
| `enabled` | bool | `true` | Ενεργή |
| `current` | bool | `true` | Τρέχουσα camera |
| `limit_left` | int | `-1000` | Όριο αριστερά |
| `limit_right` | int | `1000` | Όριο δεξιά |
| `limit_top` | int | `-1000` | Όριο πάνω |
| `limit_bottom` | int | `1000` | Όριο κάτω |
| `smoothing_enabled` | bool | `true` | Ομαλή κίνηση |
| `smoothing_speed` | float | `5.0` | Ταχύτητα smoothing |
| `drag_horizontal_enabled` | bool | `true` | Drag οριζόντια |
| `drag_vertical_enabled` | bool | `true` | Drag κάθετα |

**Examples:**
```
# Zoom out (πλατύτερο view)
GET /?cmd=set_property&node=Camera&prop=zoom&value={"x":2,"y":2}

# Zoom in
GET /?cmd=set_property&node=Camera&prop=zoom&value={"x":0.5,"y":0.5}

# Ενεργοποίηση smoothing
GET /?cmd=set_property&node=Camera&prop=smoothing_enabled&value=true

# Όρια
GET /?cmd=set_property&node=Camera&prop=limit_left&value=-500
GET /?cmd=set_property&node=Camera&prop=limit_right&value=500
```

---

## 🎮 CHARACTERBODY2D PROPERTIES

| Property | Type | Example | Description |
|----------|------|---------|-------------|
| `position` | Vector2 | `{"x": 100, "y": 0}` | Θέση |
| `velocity` | Vector2 | `{"x": 0, "y": 0}` | Ταχύτητα |
| `rotation` | float | `0` | Περιστροφή |
| `scale` | Vector2 | `{"x": 1, "y": 1}` | Scale |
| `motion_mode` | int | `0` | 0=Grounded, 1=Floating |
| `up_direction` | Vector2 | `{"x": 0, "y": -1}` | Πάνω κατεύθυνση |
| `slide_on_ceiling` | bool | `true` | Slide στο ταβάνι |
| `floor_max_angle` | float | `0.785` | Μέγιστη γωνία δαπέδου |
| `floor_snap_length` | float | `1` | Snap μήκος |
| `platform_on_leave` | int | `0` | Συμπεριφορά όταν φεύγει από platform |

**Examples:**
```
# Άλλαγε up direction (για wall-running)
GET /?cmd=set_property&node=Player&prop=up_direction&value={"x":0,"y":-1}

# Floating mode (για platformer στον αέρα)
GET /?cmd=set_property&node=Player&prop=motion_mode&value=1
```

---

## 🎨 LABEL PROPERTIES (Κείμενο)

| Property | Type | Example | Description |
|----------|------|---------|-------------|
| `text` | String | `"Hello World"` | Κείμενο |
| `position` | Vector2 | `{"x": 100, "y": 100}` | Θέση |
| `modulate` | Color | `{"r": 1, "g": 1, "b": 1}` | Χρώμα |
| `scale` | Vector2 | `{"x": 2, "y": 2}` | Μέγεθος |
| `visible` | bool | `true` | Ορατό |
| `z_index` | int | `0` | Z-order |

**Example:**
```
GET /?cmd=set_property&node=ScoreLabel&prop=text&value=Score:%20100
```

---

## 🔲 COLLISIONSHAPE2D PROPERTIES

| Property | Type | Example | Description |
|----------|------|---------|-------------|
| `position` | Vector2 | `{"x": 0, "y": 0}` | Θέση |
| `rotation` | float | `0` | Περιστροφή |
| `scale` | Vector2 | `{"x": 1, "y": 1}` | Scale |
| `disabled` | bool | `false` | Απενεργοποίηση |
| `debug_color` | Color | `{"r": 0, "g": 1, "b": 0, "a": 0.5}` | Debug χρώμα |

---

## 🌍 NODE2D PROPERTIES (Base για όλα τα 2D)

| Property | Type | Example | Description |
|----------|------|---------|-------------|
| `position` | Vector2 | `{"x": 100, "y": 200}` | Θέση X,Y |
| `rotation` | float | `1.57` | Περιστροφή (radians) |
| `scale` | Vector2 | `{"x": 2, "y": 2}` | Scale X,Y |
| `skew` | float | `0.0` | Skew effect |
| `visible` | bool | `true` / `false` | Ορατό ή όχι |
| `modulate` | Color | `{"r": 1, "g": 0, "b": 0}` | Χρώμα |
| `self_modulate` | Color | `{"r": 1, "g": 1, "b": 1}` | Self modulation |
| `show_behind_parent` | bool | `false` | Πίσω από parent |
| `top_level` | bool | `false` | Ανεξάρτητο από parent transform |
| `z_index` | int | `0` | Z-order (μεγαλύτερο = μπροστά) |
| `z_as_relative` | bool | `true` | Z σχετικό με parent |
| `y_sort_enabled` | bool | `false` | Y-sorting για top-down |

---

## 🎭 ANIMATEDSPRITE2D PROPERTIES

| Property | Type | Example | Description |
|----------|------|---------|-------------|
| `position` | Vector2 | `{"x": 0, "y": 0}` | Θέση |
| `animation` | String | `"run"` / `"idle"` | Τρέχουσα animation |
| `frame` | int | `0` | Τρέχον frame |
| `frame_progress` | float | `0.5` | Progress (0-1) |
| `speed_scale` | float | `1.0` | Ταχύτητα (2.0 = 2x) |
| `playing` | bool | `true` | Παίζει ή όχι |
| `flip_h` | bool | `false` | Flip οριζόντια |
| `flip_v` | bool | `false` | Flip κάθετα |
| `visible` | bool | `true` | Ορατό |

**Example:**
```
# Άλλαγε animation
GET /?cmd=set_property&node=PlayerAnim&prop=animation&value=run

# 2x ταχύτητα
GET /?cmd=set_property&node=PlayerAnim&prop=speed_scale&value=2
```

---

## 🔊 AUDIOSTREAMPLAYER2D PROPERTIES

| Property | Type | Example | Description |
|----------|------|---------|-------------|
| `volume_db` | float | `0.0` | Ένταση σε dB (0 = max, -80 = mute) |
| `pitch_scale` | float | `1.0` | Τονικότητα (2.0 = πιο ψηλά) |
| `playing` | bool | `true` | Παίζει |
| `autoplay` | bool | `false` | Auto-play on ready |
| `max_distance` | float | `2000` | Μέγιστη απόσταση ακρόασης |
| `attenuation` | float | `1.0` | Εξασθένηση με απόσταση |
| `bus` | String | `"Master"` | Audio bus |

**Examples:**
```
# Μείωση έντασης
GET /?cmd=set_property&node=Music&prop=volume_db&value=-10

# Mute
GET /?cmd=set_property&node=SFX&prop=volume_db&value=-80

# Higher pitch
GET /?cmd=set_property&node=JumpSound&prop=pitch_scale&value=1.5
```

---

## 🎲 RANDOM USEFUL PROPERTIES

### global_position (read-only, World space)
```
# Παίρνεις την τιμή μέσω get_property
```

### transform (Matrix)
```json
POST / {
  "tool": "set_property",
  "args": {
    "node_path": "Player",
    "property": "transform",
    "value": {
      "x": {"x": 1, "y": 0},
      "y": {"x": 0, "y": 1},
      "origin": {"x": 100, "y": 200}
    }
  }
}
```

---

## 🔍 ΠΩΣ ΝΑ ΒΡΕΙΣ ΠΕΡΙΣΣΟΤΕΡΑ PROPERTIES

### Μέθοδος 1: Inspector στο Godot
1. Click το node
2. Δες το Inspector (δεξιά)
3. Όλα τα properties εκεί είναι accessible

### Μέθοδος 2: Godot Documentation
- https://docs.godotengine.org/en/stable/classes/index.html
- Ψάξε το node (π.χ. Sprite2D)
- Δες το "Properties" section

### Μέθοδος 3: get_property (από το plugin)
```
GET /?cmd=get_property&node=Player&prop=scale
```

---

## 💡 COMMON PATTERNS

### Animation χωρίς code:
```python
# Frame 1
GET /?cmd=set_property&node=Player&prop=position&value={"x":0,"y":0}
GET /?cmd=set_property&node=Player&prop=rotation&value=0

# Frame 2  
GET /?cmd=set_property&node=Player&prop=position&value={"x":10,"y":0}
GET /?cmd=set_property&node=Player&prop=rotation&value=0.1
```

### Color transition:
```python
# Red -> Yellow
GET /?cmd=set_property&node=Player&prop=modulate&value={"r":1,"g":0,"b":0}
GET /?cmd=set_property&node=Player&prop=modulate&value={"r":1,"g":0.5,"b":0}
GET /?cmd=set_property&node=Player&prop=modulate&value={"r":1,"g":1,"b":0}
```

### Visibility flash:
```python
GET /?cmd=set_property&node=Player&prop=visible&value=false
GET /?cmd=set_property&node=Player&prop=visible&value=true
GET /?cmd=set_property&node=Player&prop=visible&value=false
GET /?cmd=set_property&node=Player&prop=visible&value=true
```

---

## ⚠️ LIMITATIONS

1. **read-only properties** - Δεν μπορείς να γράψεις (π.χ. `global_position`)
2. **Object references** - Δύσκολο να ορίσεις (π.χ. `texture`, `script`)
3. **Enums** - Χρησιμοποίησε int values (π.χ. `motion_mode=0`)
4. **Arrays/Dictionaries** - Χρησιμοποίησε POST με JSON

---

## 🎯 COMPLETE EXAMPLE

**Create a flashing red enemy that moves:**
```python
# 1. Create enemy
GET /?cmd=create_sprite&name=Enemy&x=500&y=200&size=80&r=1&g=0&b=0

# 2. Make it flash (POST for multiple)
POST / {
  "tool": "set_properties",
  "args": {
    "node_path": "Enemy",
    "properties": {
      "visible": true,
      "scale": {"x": 1.5, "y": 1.5},
      "z_index": 10
    }
  }
}

# 3. Move it
GET /?cmd=set_property&node=Enemy&prop=position&value={"x":400,"y":200}

# 4. Flash off
GET /?cmd=set_property&node=Enemy&prop=visible&value=false
GET /?cmd=set_property&node=Enemy&prop=visible&value=true
```

---

## 📚 REFERENCE CONVERSION TABLE

| Godot Type | JSON Format | Example |
|------------|-------------|---------|
| Vector2 | `{"x": 10, "y": 20}` | `{"x": 100, "y": 200}` |
| Vector2i | `{"x": 10, "y": 20}` | `{"x": 10, "y": 10}` |
| Color | `{"r": 1, "g": 0, "b": 0, "a": 1}` | `{"r": 1, "g": 0.5, "b": 0}` |
| bool | `true` / `false` | `true` |
| int | `10` | `100` |
| float | `1.5` | `3.14` |
| String | `"text"` | `"Hello"` |

---

**Σημείωση:** Όλα τα properties που βλέπεις στο Godot Inspector μπορούν να αλλάξουν μέσω `set_property`!
