# 📖 Πλήρης Οδηγός Εγκατάστασης Godot OpenClaw Bridge

## Πού Δίνεις τις Εντολές

Τις δίνεις **στο OpenClaw** - όπως μιλάς σε εμένα τώρα! Το OpenClaw επικοινωνεί με τον Godot Editor στο background.

```
┌─────────────────┐     Σου απαντάω εδώ      ┌─────────────────┐
│   OpenClaw      │ ◄──────────────────────► │     ΕΣΥ         │
│   (εγώ)         │   "Φτιάξε μου έναν       │  (Chat/Discord/ │
│                 │    Player με WASD"       │   Telegram/κλπ) │
└────────┬────────┘                          └─────────────────┘
         │
         │ HTTP localhost:7450 (αόρατο για σένα)
         ▼
┌─────────────────┐
│   Godot Editor  │ ◄── Ανοικτός στο PC σου
│   με Plugin     │     (κάνει τη δουλειά)
└─────────────────┘
```

## Βήμα-βήμα Εγκατάσταση

### Βήμα 1: Κατέβασμα

```bash
# Άνοιξε terminal και τρέξε:
git clone https://github.com/pavlos1323456/godot-openclaw-bridge.git
cd godot-openclaw-bridge
```

### Βήμα 2: Εγκατάσταση στο Godot Project σου

```bash
# Βάλε το path του Godot project σου
./setup.sh /home/pavlos/Documents/MyGodotGame
```

Αυτό θα κάνει:
- ✅ Copy το plugin στο `addons/openclaw_bridge/`
- ✅ Εγκατάσταση του OpenClaw skill

### Βήμα 3: Άνοιγμα στο VS Code

Τα αρχεία του plugin είναι απλά GDScript - τα ανοίγεις κανονικά:

```bash
# Άνοιξε τον φάκελο του plugin στο VS Code
code /home/pavlos/Documents/MyGodotGame/addons/openclaw_bridge
```

Ή από το VS Code: `File → Open Folder` και επίλεξε το `addons/openclaw_bridge`

**Τα κύρια αρχεία:**
- `plugin.gd` - Το entry point (ξεκινάει/σταματάει το plugin)
- `openclaw_bridge.gd` - Ο server και τα tools (εδώ είναι η λογική)
- `plugin.cfg` - Το configuration

### Βήμα 4: Ενεργοποίηση στο Godot

1. Άνοιξε τον Godot Editor
2. Πήγαινε: **Project → Project Settings → Plugins**
3. Βρες το **"OpenClaw Bridge"**
4. Πάτησε το **✓ Status** (από inactive → active)
5. Θα δεις μήνυμα στο Output panel: `[OpenClaw] MCP server listening on port 7450`

### Βήμα 5: Έλεγχος σύνδεσης

```bash
# Τρέξε από το terminal:
./test.sh

# Ή χειροκίνητα με curl:
curl http://localhost:7450/health
```

Αν δεις `{"status": "ok"}` → **Είσαι έτοιμος!** 🎉

---

## Πώς Χρησιμοποιείς το OpenClaw με Godot

### Τρόπος 1: Μέσω Web Chat (εύκολο)

1. Άνοιξε το OpenClaw στο browser (ή όπου το έχεις)
2. Πες μου:
   > "Άνοιξε το Godot project μου και φτιάξε έναν Player με WASD movement"
3. Το OpenClaw στέλνει εντολές στον Godot και σου απαντάει με αποτελέσματα

### Τρόπος 2: Μέσω Discord/Telegram (αν έχεις συνδέσει)

Αν έχεις συνδέσει το OpenClaw σε κάποιο channel, γράφεις εκεί κανονικά.

---

## Παράδειγμα Πλήρους Workflow

### Σενάριο: "Φτιάξε μου ένα platformer"

**Εσύ (στο OpenClaw chat):**
> Φτιάξε μου έναν Player CharacterBody2D με:
> - Sprite2D (προσωρινό texture)
> - CollisionShape2D (rectangle)
> - Script με WASD + Space για jump

**OpenClaw → Godot:**
```json
{
  "method": "tools/call",
  "params": {
    "name": "create_scene",
    "arguments": {"scene_name": "Player", "root_type": "CharacterBody2D"}
  }
}
```

**Godot:** (φτιάχνει το scene)

**OpenClaw → Godot:**
```json
{
  "name": "add_node",
  "arguments": {
    "parent_path": ".",
    "node_name": "Sprite2D",
    "node_type": "Sprite2D"
  }
}
```

**Godot:** (προσθέτει Sprite2D)

...κλπ μέχρι να ολοκληρωθεί...

**Εσύ (βλέπεις):**
> ✅ Δημιουργήθηκε ο Player!
> - Scene: `res://Player.tscn`
> - Root: CharacterBody2D
> - Προστέθηκαν: Sprite2D, CollisionShape2D
> - Script με movement προστέθηκε
>
> Θέλεις να το τρέξουμε να δεις αν δουλεύει;

---

## Πού Είναι τα Αρχεία (File Structure)

```
MyGodotGame/                          ← Το project σου
├── addons/
│   └── openclaw_bridge/              ← 🔌 ΤΟ PLUGIN
│       ├── plugin.gd                 ← Entry point
│       ├── openclaw_bridge.gd        ← Ο server (400+ γραμμές)
│       └── plugin.cfg                ← Config
├── Player.tscn                       ← Δημιουργείται από OpenClaw
├── Player.gd                         ← Script που έγραψε το OpenClaw
└── ...

~/.openclaw/skills/godot-engine/      ← OpenClaw skill (system)
    ├── SKILL.md
    └── scripts/godot_mcp_server.py
```

---

## Troubleshooting

### "Connection refused" στο test.sh

**Πρόβλημα:** Ο Godot δεν ακούει στο port 7450

**Λύσεις:**
1. Είναι ανοιχτός ο Godot Editor;
2. Είναι ενεργοποιημένο το plugin; (Project Settings → Plugins)
3. Δες το Output panel στον Godot - έχει errors;
4. Μήπως το port 7450 είναι δεσμευμένο;
   ```bash
   # Έλεγξε τι ακούει στο 7450:
   lsof -i :7450
   ```

### Το plugin δεν εμφανίζεται στο Godot

**Πρόβλημα:** Δεν έγινε σωστά το copy

**Λύση:**
```bash
# Χειροκίνητα:
cp -r godot-openclaw-bridge/addons/openclaw_bridge /path/to/your/project/addons/
```

Μετά restart τον Godot Editor.

### Το VS Code δεν αναγνωρίζει GDScript

Εγκατέστησε το extension:
- **Godot Tools** (geequlim.godot-tools)
- Ή **GDScript** (Razoric.gdscript)

---

## Σύνοψη

| Βήμα | Ενέργεια | Πού |
|------|----------|-----|
| 1 | `git clone` | Terminal |
| 2 | `./setup.sh <project-path>` | Terminal |
| 3 | Ενεργοποίηση plugin | Godot Editor |
| 4 | `./test.sh` | Terminal |
| 5 | Δίνεις εντολές | OpenClaw Chat |
| 6 | Βλέπεις αποτελέσματα | Godot Editor |

---

**Θέλεις να σου γράψω κάποιο συγκεκριμένο script ή να φτιάξω κάποιο feature στο plugin;**