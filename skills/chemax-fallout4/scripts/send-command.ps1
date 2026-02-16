# chemax — Fallout 4 send command (Windows)
# Reads config from setup, sends command via the configured bridge.
#
# Usage: powershell -File send-command.ps1 "player.additem f 1000"

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Command
)

$ConfigFile = Join-Path $HOME ".chemax\fallout4.json"

# --- Load config ---
if (-not (Test-Path $ConfigFile)) {
    Write-Host "error: chemax not set up. run setup.ps1 first" -ForegroundColor Red
    Write-Host "  powershell -File ~/.claude/skills/chemax-fallout4/scripts/setup.ps1" -ForegroundColor Yellow
    exit 1
}

$config = Get-Content $ConfigFile | ConvertFrom-Json

# --- Send via configured method ---
if ($config.bridgeMethod -eq "http") {
    $url = "http://$($config.httpHost):$($config.httpPort)/command"
    try {
        Invoke-WebRequest -Uri $url -Method POST -Body $Command `
            -ContentType "text/plain" -TimeoutSec 3 -ErrorAction Stop | Out-Null
        Write-Host "executed: $Command"
    } catch {
        # HTTP failed — fall back to batch
        Add-Content -Path $config.batchFile -Value $Command
        Write-Host "bridge down — queued: $Command"
        Write-Host "in-game: bat chemax"
    }
} else {
    # Batch mode — write to game directory
    Add-Content -Path $config.batchFile -Value $Command
    Write-Host "queued: $Command"
    Write-Host "in-game: open console (~) and type: bat chemax"
}
