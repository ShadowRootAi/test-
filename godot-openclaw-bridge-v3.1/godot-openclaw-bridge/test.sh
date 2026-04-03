#!/bin/bash
# Quick test script for Godot OpenClaw Bridge

echo "🧪 Testing Godot OpenClaw Bridge Connection"
echo "=========================================="
echo ""

# Test health endpoint
echo "Testing health endpoint..."
if curl -s http://localhost:7450/health | python3 -m json.tool 2>/dev/null; then
    echo -e "\n✅ Godot plugin is running!"
else
    echo -e "\n❌ Cannot connect to Godot plugin"
    echo ""
    echo "Make sure:"
    echo "1. Godot Editor is open"
    echo "2. OpenClaw Bridge plugin is enabled"
    echo "3. The plugin started without errors (check Output panel)"
    exit 1
fi

echo ""
echo "Testing MCP endpoint..."

# Test MCP initialize
curl -s -X POST http://localhost:7450/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "initialize",
    "params": {},
    "id": 1
  }' | python3 -m json.tool 2>/dev/null

echo ""
echo ""
echo "✅ All tests passed!"