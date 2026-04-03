# Godot OpenClaw Bridge v3.0

## 🎉 What's New

### ⚡ Ultra-Fast Performance
- **Connection pooling** - 2-3x faster responses
- **Batch operations** - Multiple commands in one call
- **Optimized for local development**

### 🔧 Bug Fixes
- **Script reload fixed** - Scripts now appear immediately in editor
- **Better verification** - Know when things actually work

### 🎮 New Features
- Duplicate, reparent, rename nodes
- Undo/redo support
- Script verification
- Batch command support

---

## 📦 Files Included

```
📁 addons/openclaw_bridge/
   ├── plugin.cfg          # Plugin configuration
   ├── plugin.gd           # Plugin entry point
   └── openclaw_bridge_v3.gd  # Main plugin (NEW)

📁 root/
   ├── godot_bridge_v3.py     # HTTP Bridge (NEW)
   ├── test_v3.py             # Test suite
   ├── QUICKSTART.md          # 60-second setup
   ├── UPGRADE_TO_V3.md       # Migration guide
   └── README.md              # Full documentation
```

---

## 🚀 Installation

### Option 1: Download ZIP
1. Download `Source code (zip)` below
2. Extract `addons/openclaw_bridge` to your Godot project
3. Enable plugin in Project Settings

### Option 2: Git Clone
```bash
git clone https://github.com/pavlos1323456/godot-openclaw-bridge.git
cd godot-openclaw-bridge
python godot_bridge_v3.py
```

---

## 🧪 Quick Test

```bash
# Terminal 1
python godot_bridge_v3.py

# Terminal 2  
curl "http://localhost:8080/?cmd=status"
```

---

## 📚 Documentation

- [QUICKSTART.md](QUICKSTART.md) - 60 second setup
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed guide
- [EXAMPLES.md](EXAMPLES.md) - Code examples
- [ARCHITECTURE.md](ARCHITECTURE.md) - How it works

---

## 🙏 Thanks

Thanks to everyone who starred, forked, and contributed!

**Full Changelog**: Compare with v2.1.0
