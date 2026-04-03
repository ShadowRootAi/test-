# 🚀 FINAL SETUP GUIDE - Godot OpenClaw Bridge

## ⚠️ ΣΗΜΑΝΤΙΚΟ: Πρέπει να κάνεις ΟΛΑ τα βήματα!

### Βήμα 1: Κλείσε ΤΑ ΠΑΝΤΑ
```powershell
# Κλείσε το Godot ΕΝΤΕΛΩΣ (ΟΧΙ minimize!)
# Κλείσε το bridge (Ctrl+C στο terminal)
```

### Βήμα 2: Git Pull
```powershell
cd C:\Users\paylos\godot-openclaw-bridge
git pull origin main
```

### Βήμα 3: Setup (Αυτόματο)
```powershell
.\setup.ps1 -GodotProject "C:\Users\paylos\Documents\GodotProjects\Test"
```

### Βήμα 4: Άνοιξε το Godot
1. Άνοιξε το Godot Editor
2. Άνοιξε το project σου (Test)

### Βήμα 5: Ενεργοποίησε το Plugin
```
Project → Project Settings → Plugins → OpenClaw Bridge → [✓] Enable
```

### Βήμα 6: Κάνε Ctrl+S
Πάτα `Ctrl+S` να σώσεις το project

### Βήμα 7: Κλείσε & Άνοιξε το Godot ΞΑΝΑ
```
File → Quit
Άνοιξε το Godot ξανά
```

### Βήμα 8: Έλεγξε το Output
```
Output panel (κάτω):
[OpenClaw] MCP server listening on port 7450
```

### Βήμα 9: Τρέξε το Bridge
```powershell
cd C:\Users\paylos\godot-openclaw-bridge
python godot_bridge.py
```

### Βήμα 10: Τεστάρισμα
```
http://localhost:8080/?cmd=create_sprite&name=Hero&x=100&y=100
```

---

## ✅ ΑΝ ΔΟΥΛΕΨΕΙ:
Θα δεις το Hero στο Godot αυτόματα!

## ❌ ΑΝ ΠΕΤΑΞΕΙ "Unknown tool":
Επανέλαβε από το Βήμα 1. Το plugin ΔΕΝ έχει φορτωθεί σωστά.

---

## 📞 TROUBLESHOOTING

### "Cannot connect to Godot"
- Το plugin δεν είναι enabled
- Κάνε ξανά τα βήματα 5-7

### "Unknown tool: create_sprite"
- Το plugin είναι παλιό
- Κάνε ξανά git pull + setup + restart

### Το Godot κολλάει
- Κλείσε το bridge και ξανά-open

---

## 🎮 QUICK TEST COMMANDS

```
# Δημιούργησε κόκκινο τετράγωνο
http://localhost:8080/?cmd=create_sprite&name=RedBox&x=200&y=200&r=1&g=0&b=0

# Δημιούργησε πράσινο platform
http://localhost:8080/?cmd=create_color_rect&name=Platform&x=0&y=400&w=300&h=50&r=0&g=1&b=0

# Διέγραψε
http://localhost:8080/?cmd=remove_node&node=RedBox

# Save
http://localhost:8080/?cmd=save_scene

# Run game
http://localhost:8080/?cmd=run_game
```

---

**Μόλις δουλέψει αυτό, είσαι έτοιμος να φτιάχνεις games μέσω Telegram!** 🎮
