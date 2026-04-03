# 🤝 Contributing to Godot OpenClaw Bridge

Thank you for your interest in contributing! This document will help you get started.

---

## 🚀 Quick Start

### 1. Fork and Clone

```bash
# Fork on GitHub, then:
git clone https://github.com/YOUR_USERNAME/godot-openclaw-bridge.git
cd godot-openclaw-bridge
```

### 2. Development Setup

You'll need:
- Godot 4.x
- Python 3.8+
- A test Godot project

### 3. Test Your Changes

```bash
# Run the bridge
python godot_bridge_v3.py

# Run tests
python test_v3.py
```

---

## 🎯 Ways to Contribute

### 🐛 Report Bugs

If you find a bug, please open an issue with:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- Godot version
- Plugin version

### 💡 Suggest Features

Open an issue with the "feature request" label:
- Describe the use case
- Explain why it's useful
- Suggest implementation (optional)

### 📝 Improve Documentation

- Fix typos
- Add examples
- Translate README
- Improve clarity

### 🔧 Add Commands

Want to add a new Godot command?

1. Add to `openclaw_bridge_v3.gd`:
```gdscript
# Add to _execute_tool match statement
"my_new_command": result = _my_new_command(params)

# Add to _get_tool_definitions()
{"name": "my_new_command", "description": "...", "inputSchema": {...}}

# Implement
func _my_new_command(params: Dictionary) -> Dictionary:
    # Your code here
    return {"success": true}
```

2. Add to `godot_bridge_v3.py`:
```python
def _cmd_my_new_command(self, params):
    return self._call_godot_fast("my_new_command", {...})
```

3. Update documentation

4. Add tests

---

## 📋 Code Style

### GDScript
- Use tabs for indentation
- snake_case for functions/variables
- PascalCase for classes
- Document public functions

### Python
- PEP 8 compliant
- Type hints where helpful
- Docstrings for functions

---

## 🧪 Testing

Before submitting PR:

1. Test in Godot 4.x
2. Run `python test_v3.py`
3. Test edge cases
4. Verify scripts attach correctly

---

## 📝 Commit Messages

Use clear, descriptive commits:

```
feat: add undo/redo commands
fix: script reload in editor
docs: improve README examples
test: add batch command tests
```

---

## 🔄 Pull Request Process

1. **Create a branch**: `git checkout -b feature/my-feature`
2. **Make changes**: Edit, test, commit
3. **Push**: `git push origin feature/my-feature`
4. **Open PR**: Describe what and why
5. **Review**: Address feedback
6. **Merge**: We'll merge when ready

---

## 🎖️ Recognition

Contributors will be:
- Listed in README
- Mentioned in release notes
- Added to CONTRIBUTORS.md

---

## 💬 Questions?

- Open a [GitHub Discussion](https://github.com/pavlos1323456/godot-openclaw-bridge/discussions)
- Comment on existing issues
- Reach out on social media

---

**Thank you for making Godot OpenClaw Bridge better!** 🎮
