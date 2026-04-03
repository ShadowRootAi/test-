# OpenClaw + Godot Integration Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER REQUEST                              │
│         "Create a player scene with WASD movement"               │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                    OPENCLAW (MCP Client)                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────┐  │
│  │ godot-engine │───▶│ MCP Client  │───▶│ JSON-RPC over HTTP  │  │
│  │    skill     │    │  (stdio)    │    │   localhost:7450    │  │
│  └─────────────┘    └─────────────┘    └─────────────────────┘  │
└───────────────────────┬─────────────────────────────────────────┘
                        │ HTTP POST /mcp
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GODOT EDITOR PLUGIN                           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────┐  │
│  │ HTTP Server │───▶│ JSON-RPC    │───▶│  Tool Handlers      │  │
│  │  port 7450  │    │  Router     │    │  (GDScript)         │  │
│  └─────────────┘    └─────────────┘    └─────────────────────┘  │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                     GODOT EDITOR API                             │
│  - Scene tree manipulation                                       │
│  - Node creation/removal                                         │
│  - Property editing                                              │
│  - Script management                                             │
│  - File I/O                                                      │
│  - Play/stop game                                                │
└─────────────────────────────────────────────────────────────────┘
```

## Communication Protocol

### JSON-RPC Request Format
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "add_node",
    "arguments": {
      "parent_path": ".",
      "node_name": "Player",
      "node_type": "CharacterBody2D"
    }
  },
  "id": 1
}
```

### Response Format
```json
{
  "jsonrpc": "2.0",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"success\": true, \"node_path\": \"/root/Player\"}"
      }
    ]
  },
  "id": 1
}
```

## Security Considerations

- **Localhost only**: Server binds to 127.0.0.1:7450
- **No authentication**: Designed for local development only
- **Code execution**: Can write and execute GDScript
- **File access**: Full access to project files

## Error Handling

Connection errors return:
```json
{
  "jsonrpc": "2.0",
  "error": {
    "code": -32000,
    "message": "Cannot connect to Godot: [Errno 111] Connection refused"
  },
  "id": 1
}
```

## Port Configuration

Default: **7450**

To change, edit in `openclaw_bridge.gd`:
```gdscript
const PORT = 7450  # Change this
```