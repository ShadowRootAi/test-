# 🚀 60-Second Quick Start

**Δεν χρειάζεται να ξέρεις προγραμματισμό.** Ακολούθησε αυτά τα 3 βήματα.

---

## ✅ Βήμα 1: Κατέβασμα (10 δευτερόλεπτα)

```bash
git clone https://github.com/pavlos1323456/godot-openclaw-bridge.git
```

*Δεν έχεις git;* Πάτα το πράσινο κουμπί "Code" → "Download ZIP" στο GitHub.

---

## ✅ Βήμα 2: Βάλε το στο Godot (30 δευτερόλεπτα)

1. **Άνοιξε το Godot** (οποιοδήποτε project)
2. **Αντέγραψε** τον φάκελο:
   ```bash
   # Windows:
   xcopy /E /I godot-openclaw-bridge\addons\openclaw_bridge YourProject\addons\
   
   # Ή απλά drag & drop στο Godot
   ```
3. **Project → Project Settings → Plugins**
4. **Ενεργοποίησε το** "OpenClaw Bridge"

Θα δεις: `[OpenClaw v3] MCP server on port 7450`

✅ **Τέλος!** Το plugin είναι έτοιμο.

---

## ✅ Βήμα 3: Τρέξε το (20 δευτερόλεπτα)

```bash
# Άνοιξε terminal/cmd

cd godot-openclaw-bridge
python godot_bridge_v3.py
```

Θα δεις:
```
🎮 Godot Bridge v3.0 - ULTRA-FAST MODE
⚡ HTTP Server: http://localhost:8080
```

---

## 🧪 Τεστάρισμα (Προαιρετικό)

Άνοιξε browser και πήγαινε σε:
```
http://localhost:8080/?cmd=status
```

Αν δεις JSON με το όνομα του project σου → **Δουλεύει!** 🎉

---

## 📱 Σύνδεσε το Telegram Bot σου

Αντικατέστησε το URL στο bot σου:

```python
# ΠΡΙΝ:
GODOT_URL = "http://localhost:8080/"

# ΜΕΤΑ - τίποτα! Το ίδιο είναι.
# Απλά τρέχει πιο γρήγορα τώρα.
```

---

## ❓ Προβλήματα;

| Πρόβλημα | Λύση |
|----------|------|
| "python not found" | Κατέβασε Python από python.org |
| "Port 7450 in use" | Κλείσε και ξαναάνοιξε το Godot |
| "Connection refused" | Βεβαιώσου ότι το plugin είναι enabled |

---

## 🎮 Τι μπορείς να κάνεις τώρα;

Πες στο bot σου:
- *"Φτιάξε μου έναν Player με WASD"*
- *"Πρόσθεσε έναν εχθρό"*
- *"Τρέξε το παιχνίδι"*

Και το Godot θα κάνει τα πάντα **αυτόματα**!

---

## 📚 Θέλεις περισσότερα;

- [Πλήρες Setup Guide](SETUP_GUIDE.md) - Λεπτομερείς οδηγίες
- [Παραδείγματα](EXAMPLES.md) - Έτοιμα scripts
- [Αναβάθμιση από v2](UPGRADE_TO_V3.md) - Αν έχεις παλιά έκδοση

---

**⏱️ Σύνολο χρόνος: 60 δευτερόλεπτα**

*"Ήταν τόσο εύκολο;"* - Ναι. 🎯
