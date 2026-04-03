# Test script for Godot OpenClaw Bridge (Windows PowerShell)

Write-Host "🧪 Testing Godot OpenClaw Bridge Connection" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Test health endpoint
Write-Host "Testing health endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:7450/health" -Method GET -TimeoutSec 5
    $response | ConvertTo-Json
    Write-Host ""
    Write-Host "✅ Godot plugin is running!" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "❌ Cannot connect to Godot plugin" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "1. Godot Editor is open" -ForegroundColor Yellow
    Write-Host "2. OpenClaw Bridge plugin is enabled" -ForegroundColor Yellow
    Write-Host "3. Check Output panel in Godot for errors" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Testing MCP endpoint..." -ForegroundColor Cyan

# Test MCP initialize
$body = @{
    jsonrpc = "2.0"
    method = "initialize"
    params = @{}
    id = 1
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:7450/mcp" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5
    $response | ConvertTo-Json
    Write-Host ""
    Write-Host "✅ All tests passed!" -ForegroundColor Green
} catch {
    Write-Host "❌ MCP test failed" -ForegroundColor Red
    Write-Host $_.Exception.Message
}