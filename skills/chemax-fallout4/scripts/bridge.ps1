# chemax — Fallout 4 auto-bridge (Windows)
# Runs in the background. Watches chemax.txt for new commands and
# sends them to the game console automatically via keystrokes.
#
# Usage: powershell -File bridge.ps1
#        (started automatically by setup, or run manually)
#
# How it works:
#   1. Watches chemax.txt for changes
#   2. When new commands appear:
#      - Focuses the Fallout 4 window
#      - Opens the console (~)
#      - Types each command + Enter
#      - Closes the console (~)
#      - Clears the file
#   3. Loops forever until you close it

param(
    [int]$PollIntervalMs = 500
)

# --- Win32 API for SendInput (works with DirectInput games) ---
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class NativeInput {
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT {
        public uint type;
        public INPUTUNION u;
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct INPUTUNION {
        [FieldOffset(0)] public KEYBDINPUT ki;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT {
        public ushort wVk;
        public ushort wScan;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

    [DllImport("user32.dll")]
    public static extern IntPtr SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern uint MapVirtualKey(uint uCode, uint uMapType);

    public const uint INPUT_KEYBOARD = 1;
    public const uint KEYEVENTF_SCANCODE = 0x0008;
    public const uint KEYEVENTF_KEYUP = 0x0002;

    public static void SendScanCode(ushort scanCode) {
        INPUT[] inputs = new INPUT[2];

        // Key down
        inputs[0].type = INPUT_KEYBOARD;
        inputs[0].u.ki.wScan = scanCode;
        inputs[0].u.ki.dwFlags = KEYEVENTF_SCANCODE;

        // Key up
        inputs[1].type = INPUT_KEYBOARD;
        inputs[1].u.ki.wScan = scanCode;
        inputs[1].u.ki.dwFlags = KEYEVENTF_SCANCODE | KEYEVENTF_KEYUP;

        SendInput(2, inputs, Marshal.SizeOf(typeof(INPUT)));
    }

    public static void SendChar(char c) {
        INPUT[] inputs = new INPUT[2];

        inputs[0].type = INPUT_KEYBOARD;
        inputs[0].u.ki.wScan = (ushort)c;
        inputs[0].u.ki.dwFlags = 0x0004; // KEYEVENTF_UNICODE

        inputs[1].type = INPUT_KEYBOARD;
        inputs[1].u.ki.wScan = (ushort)c;
        inputs[1].u.ki.dwFlags = 0x0004 | KEYEVENTF_KEYUP;

        SendInput(2, inputs, Marshal.SizeOf(typeof(INPUT)));
    }
}
"@

# --- Config ---
$ConfigFile = Join-Path $HOME ".chemax\fallout4.json"
if (-not (Test-Path $ConfigFile)) {
    Write-Host "error: run setup.ps1 first" -ForegroundColor Red
    exit 1
}

$config = Get-Content $ConfigFile | ConvertFrom-Json
$batchFile = $config.batchFile
$gameDir = $config.gameDir

if (-not $batchFile -or -not (Test-Path (Split-Path $batchFile))) {
    Write-Host "error: invalid batch file path in config" -ForegroundColor Red
    exit 1
}

# Ensure batch file exists
if (-not (Test-Path $batchFile)) {
    New-Item -ItemType File -Path $batchFile -Force | Out-Null
}

# Scan code for tilde/grave key (opens Bethesda console)
$TILDE_SCAN = 0x29

# --- Functions ---
function Find-Fallout4Window {
    $proc = Get-Process -Name "Fallout4" -ErrorAction SilentlyContinue
    if ($proc -and $proc.MainWindowHandle -ne [IntPtr]::Zero) {
        return $proc.MainWindowHandle
    }
    return [IntPtr]::Zero
}

function Send-ConsoleCommand {
    param([string]$Command)

    $hwnd = Find-Fallout4Window
    if ($hwnd -eq [IntPtr]::Zero) {
        Write-Host "  fallout 4 not running, skipping" -ForegroundColor Yellow
        return $false
    }

    # Focus the game window
    [NativeInput]::ShowWindow($hwnd, 9)  # SW_RESTORE
    [NativeInput]::SetForegroundWindow($hwnd) | Out-Null
    Start-Sleep -Milliseconds 100

    # Open console
    [NativeInput]::SendScanCode($TILDE_SCAN)
    Start-Sleep -Milliseconds 200

    # Type the command character by character
    foreach ($char in $Command.ToCharArray()) {
        [NativeInput]::SendChar($char)
        Start-Sleep -Milliseconds 10
    }

    Start-Sleep -Milliseconds 50

    # Press Enter (scan code 0x1C)
    [NativeInput]::SendScanCode(0x1C)
    Start-Sleep -Milliseconds 100

    # Close console
    [NativeInput]::SendScanCode($TILDE_SCAN)

    return $true
}

# --- Main loop ---
Write-Host ""
Write-Host "chemax bridge running" -ForegroundColor Green
Write-Host "  watching: $batchFile" -ForegroundColor Gray
Write-Host "  polling:  every ${PollIntervalMs}ms" -ForegroundColor Gray
Write-Host "  press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

$lastLength = 0

while ($true) {
    Start-Sleep -Milliseconds $PollIntervalMs

    if (-not (Test-Path $batchFile)) { continue }

    $content = Get-Content $batchFile -Raw -ErrorAction SilentlyContinue
    if (-not $content -or $content.Trim().Length -eq 0) { continue }

    # New commands detected
    $commands = $content.Trim() -split "`n" | Where-Object { $_.Trim().Length -gt 0 }

    Write-Host "$(Get-Date -Format 'HH:mm:ss') received $($commands.Count) command(s)" -ForegroundColor Cyan

    foreach ($cmd in $commands) {
        $cmd = $cmd.Trim()
        if ($cmd.Length -eq 0) { continue }

        Write-Host "  > $cmd" -ForegroundColor White
        $ok = Send-ConsoleCommand -Command $cmd

        if ($ok) {
            Write-Host "    done" -ForegroundColor Green
        }

        # Small delay between commands
        Start-Sleep -Milliseconds 300
    }

    # Clear the file after executing
    Set-Content -Path $batchFile -Value ""
}
