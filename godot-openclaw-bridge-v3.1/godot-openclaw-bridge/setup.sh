#!/bin/bash
# Setup script for Godot OpenClaw Bridge

echo "🔌 Godot OpenClaw Bridge - Setup"
echo "================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Godot project path is provided
GODOT_PROJECT="$1"

if [ -z "$GODOT_PROJECT" ]; then
    echo -e "${YELLOW}Usage: ./setup.sh /path/to/your/godot/project${NC}"
    echo ""
    echo "Please provide the path to your Godot project."
    exit 1
fi

if [ ! -d "$GODOT_PROJECT" ]; then
    echo -e "${RED}Error: Directory $GODOT_PROJECT does not exist${NC}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📁 Godot Project: $GODOT_PROJECT"
echo ""

# Step 1: Copy Godot plugin
echo "Step 1/3: Installing Godot plugin..."
mkdir -p "$GODOT_PROJECT/addons"
cp -r "$SCRIPT_DIR/addons/openclaw_bridge" "$GODOT_PROJECT/addons/"
echo -e "${GREEN}✓ Plugin copied to $GODOT_PROJECT/addons/openclaw_bridge${NC}"
echo ""
echo "   ⚠️  IMPORTANT: Open Godot Editor and enable the plugin:"
echo "      Project → Project Settings → Plugins → OpenClaw Bridge [Enable]"
echo ""

# Step 2: Install OpenClaw skill
echo "Step 2/3: Installing OpenClaw skill..."
OPENCLAW_SKILLS="$HOME/.openclaw/skills"
mkdir -p "$OPENCLAW_SKILLS"
cp -r "$SCRIPT_DIR/openclaw-skill/godot-engine" "$OPENCLAW_SKILLS/"
echo -e "${GREEN}✓ Skill installed to $OPENCLAW_SKILLS/godot-engine${NC}"
echo ""

# Step 3: Make server script executable
echo "Step 3/3: Setting up MCP server..."
chmod +x "$SCRIPT_DIR/openclaw-skill/godot-engine/scripts/godot_mcp_server.py"
echo -e "${GREEN}✓ MCP server script ready${NC}"
echo ""

# Check if running on localhost
echo "🔍 Testing connection to Godot..."
if curl -s http://localhost:7450/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Godot plugin is running and responding!${NC}"
else
    echo -e "${YELLOW}⚠ Godot plugin not detected on localhost:7450${NC}"
    echo "   Make sure to:"
    echo "   1. Open your Godot project"
    echo "   2. Enable the OpenClaw Bridge plugin"
    echo "   3. The plugin will start automatically on port 7450"
fi

echo ""
echo "================================="
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Open Godot Editor"
echo "2. Enable the plugin in Project Settings"
echo "3. Restart OpenClaw to load the new skill"
echo "4. Ask OpenClaw: 'Create a new 2D player scene with movement'"
echo ""
echo "📖 Documentation: $SCRIPT_DIR/README.md"