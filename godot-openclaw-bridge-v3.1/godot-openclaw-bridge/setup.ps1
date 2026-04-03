# Setup script for Godot OpenClaw Bridge (Windows PowerShell)
param(
    [Parameter(Mandatory=$true)]
    [string]$GodotProject
)

Write-Host "Godot OpenClaw Bridge Setup"
Write-Host "==========================="
Write-Host ""

if (-not (Test-Path $GodotProject)) {
    Write-Host "ERROR: Directory $GodotProject does not exist"
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Godot Project: $GodotProject"
Write-Host ""

# Step 1: Copy Godot plugin
Write-Host "Step 1/3: Installing Godot plugin..."
$AddonsDir = Join-Path $GodotProject "addons"
New-Item -ItemType Directory -Force -Path $AddonsDir | Out-Null

$SourcePlugin = Join-Path $ScriptDir "addons\openclaw_bridge"
$DestPlugin = Join-Path $AddonsDir "openclaw_bridge"

if (Test-Path $DestPlugin) {
    Remove-Item -Recurse -Force $DestPlugin
}
Copy-Item -Recurse -Force $SourcePlugin $DestPlugin

Write-Host "OK - Plugin copied to $DestPlugin"
Write-Host ""
Write-Host "IMPORTANT: Open Godot Editor and enable the plugin:"
Write-Host "  Project -> Project Settings -> Plugins -> OpenClaw Bridge [Enable]"
Write-Host ""

# Step 2: Install OpenClaw skill
Write-Host "Step 2/3: Installing OpenClaw skill..."
$OpenClawSkills = Join-Path $env:USERPROFILE ".openclaw\skills"
New-Item -ItemType Directory -Force -Path $OpenClawSkills | Out-Null

$SourceSkill = Join-Path $ScriptDir "openclaw-skill\godot-engine"
$DestSkill = Join-Path $OpenClawSkills "godot-engine"

if (Test-Path $DestSkill) {
    Remove-Item -Recurse -Force $DestSkill
}
Copy-Item -Recurse -Force $SourceSkill $DestSkill

Write-Host "OK - Skill installed to $DestSkill"
Write-Host ""

# Step 3: Done
Write-Host "Step 3/3: Setup complete"
Write-Host ""

# Check connection
Write-Host "Testing connection to Godot..."
try {
    $response = Invoke-RestMethod -Uri "http://localhost:7450/health" -Method GET -TimeoutSec 2
    Write-Host "OK - Godot plugin is running!"
} catch {
    Write-Host "NOTE: Godot plugin not detected on localhost:7450"
    Write-Host "      Make sure to:"
    Write-Host "      1. Open your Godot project"
    Write-Host "      2. Enable the OpenClaw Bridge plugin"
}

Write-Host ""
Write-Host "==========================="
Write-Host "Setup complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Open Godot Editor"
Write-Host "2. Enable the plugin in Project Settings"
Write-Host "3. Restart OpenClaw to load the new skill"
Write-Host "4. Ask OpenClaw: Create a new 2D player scene"
Write-Host ""
Write-Host "See README.md for more info"