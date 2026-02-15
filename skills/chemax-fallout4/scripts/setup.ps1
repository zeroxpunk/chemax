# chemax — Fallout 4 setup (Windows)
# Run once after install. Finds the game, installs the bridge, saves config.
#
# Usage: powershell -File setup.ps1

$ConfigDir = Join-Path $HOME ".chemax"
$ConfigFile = Join-Path $ConfigDir "fallout4.json"

Write-Host ""
Write-Host "chemax — Fallout 4 setup" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Find Fallout 4 ---

function Find-GameDir {
    # Check saved config first
    if (Test-Path $ConfigFile) {
        $config = Get-Content $ConfigFile | ConvertFrom-Json
        if ($config.gameDir -and (Test-Path $config.gameDir)) {
            return $config.gameDir
        }
    }

    $searchPaths = @()

    # --- Steam ---
    # Parse Steam library folders (finds ALL Steam library locations)
    $steamConfigs = @(
        "C:\Program Files (x86)\Steam\steamapps\libraryfolders.vdf"
        "C:\Program Files\Steam\steamapps\libraryfolders.vdf"
    )
    foreach ($steamConfig in $steamConfigs) {
        if (Test-Path $steamConfig) {
            $content = Get-Content $steamConfig -Raw
            $matches = [regex]::Matches($content, '"path"\s+"([^"]+)"')
            foreach ($m in $matches) {
                $libPath = $m.Groups[1].Value -replace '\\\\', '\'
                $searchPaths += Join-Path $libPath "steamapps\common\Fallout 4"
            }
        }
    }
    $searchPaths += "C:\Program Files (x86)\Steam\steamapps\common\Fallout 4"
    $searchPaths += "C:\Program Files\Steam\steamapps\common\Fallout 4"

    # --- GOG ---
    $searchPaths += "C:\GOG Games\Fallout 4"
    $searchPaths += "C:\Program Files (x86)\GOG Galaxy\Games\Fallout 4"
    # GOG Galaxy: check registry for install path
    $gogReg = "HKLM:\SOFTWARE\WOW6432Node\GOG.com\Games\1998527297"
    if (Test-Path $gogReg -ErrorAction SilentlyContinue) {
        $gogPath = (Get-ItemProperty $gogReg -ErrorAction SilentlyContinue).path
        if ($gogPath) { $searchPaths += $gogPath }
    }

    # --- Epic Games Store ---
    $searchPaths += "C:\Program Files\Epic Games\Fallout4"
    $searchPaths += "C:\Program Files\Epic Games\Fallout 4"

    # --- Microsoft Store / Xbox ---
    $xboxPath = "$env:LOCALAPPDATA\Packages"
    if (Test-Path $xboxPath) {
        $fo4Xbox = Get-ChildItem $xboxPath -Directory -Filter "*Fallout4*" -ErrorAction SilentlyContinue
        foreach ($d in $fo4Xbox) { $searchPaths += $d.FullName }
    }
    $searchPaths += "C:\XboxGames\Fallout 4\Content"

    # --- Common custom locations across all drives ---
    foreach ($drive in @("C:", "D:", "E:", "F:", "G:")) {
        $searchPaths += "$drive\Steam\steamapps\common\Fallout 4"
        $searchPaths += "$drive\SteamLibrary\steamapps\common\Fallout 4"
        $searchPaths += "$drive\Games\Fallout 4"
        $searchPaths += "$drive\Games\Fallout4"
        $searchPaths += "$drive\Fallout 4"
        $searchPaths += "$drive\Fallout4"
        $searchPaths += "$drive\GOG Games\Fallout 4"
        $searchPaths += "$drive\Epic Games\Fallout 4"
    }

    foreach ($p in $searchPaths) {
        if (Test-Path $p) {
            return $p
        }
    }
    return $null
}

$gameDir = Find-GameDir

if (-not $gameDir) {
    Write-Host "could not auto-detect Fallout 4 installation" -ForegroundColor Yellow
    $gameDir = Read-Host "enter the full path to your Fallout 4 folder"
    if (-not (Test-Path $gameDir)) {
        Write-Host "error: path does not exist: $gameDir" -ForegroundColor Red
        exit 1
    }
}

Write-Host "  found: $gameDir" -ForegroundColor Green

# --- Step 2: Set up batch file ---

$batchFile = Join-Path $gameDir "chemax.txt"
if (-not (Test-Path $batchFile)) {
    New-Item -ItemType File -Path $batchFile -Force | Out-Null
}
Write-Host "  batch: $batchFile" -ForegroundColor Green

# --- Step 3: Save config ---

if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

$config = @{
    gameDir = $gameDir
    batchFile = $batchFile
} | ConvertTo-Json

Set-Content -Path $ConfigFile -Value $config

Write-Host ""
Write-Host "setup complete" -ForegroundColor Green

# --- Step 4: Start the bridge ---

$bridgeScript = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "bridge.ps1"

Write-Host ""
Write-Host "starting bridge..." -ForegroundColor Cyan
Write-Host "  the bridge watches chemax.txt and auto-sends commands to the game" -ForegroundColor Gray
Write-Host "  keep this window open while playing" -ForegroundColor Gray
Write-Host ""
Write-Host "how to use:" -ForegroundColor Cyan
Write-Host "  1. launch Fallout 4"
Write-Host "  2. open Claude Code and type what you want"
Write-Host "  3. alt-tab back to the game — it's already done"
Write-Host ""

& $bridgeScript
