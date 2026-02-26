<#
.SYNOPSIS
    FlowState (Go Edition) Installer for Windows PowerShell
.DESCRIPTION
    Installs the FlowState workflow configuration into a target Go project.
    Supports development mode (symlinks) and production mode (copy).
.PARAMETER TargetDir
    The target directory to install into. Defaults to current directory.
.PARAMETER Dev
    If set, uses symlinks instead of copying files.
.EXAMPLE
    .\install.ps1 -TargetDir "C:\Projects\MyGoApp"
.EXAMPLE
    .\install.ps1 -Dev
#>

param (
    [string]$TargetDir = "",
    [switch]$Dev
)

$ErrorActionPreference = "Stop"

# --- Colors ---
$Green = [ConsoleColor]::Green
$Blue = [ConsoleColor]::Blue
$Yellow = [ConsoleColor]::Yellow
$Red = [ConsoleColor]::Red
$Reset = [ConsoleColor]::Gray

function Write-Color {
    param(
        [string]$Message,
        [ConsoleColor]$Color = $Reset
    )
    Write-Host $Message -ForegroundColor $Color
}

# --- Configuration ---
$PluginName = "FlowState (Go)"
$DefaultProfile = "go"
$ScriptRoot = $PSScriptRoot
if (-not $ScriptRoot) { $ScriptRoot = Get-Location }

# --- Target Selection ---
if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    Write-Color "Where would you like to install $PluginName?" $Blue
    Write-Host "  1) Current Directory ($(Get-Location))"
    Write-Host "  2) Specify a different project path"
    
    $choice = Read-Host "Your choice [1/2]"
    
    if ($choice -eq "2") {
        # Folder Browser Dialog
        Add-Type -AssemblyName System.Windows.Forms
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Select Project Directory for FlowState Installation"
        
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $TargetDir = $folderBrowser.SelectedPath
        } else {
            $TargetDir = Read-Host "Enter project path"
        }
    } else {
        $TargetDir = Get-Location
    }
}

# Resolve absolute path
$TargetDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetDir)

if (-not (Test-Path $TargetDir)) {
    Write-Color "Error: Directory '$TargetDir' does not exist." $Red
    exit 1
}

$ClaudeRoot = Join-Path $TargetDir ".claude"

Write-Color "Target set to: $TargetDir" $Green
if ($Dev) {
    Write-Color "Running in DEV MODE (Symlinks enabled)" $Yellow
}

# --- Helper Functions ---

function Backup-File {
    param([string]$Path)
    if (Test-Path $Path) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backup = "$Path.backup.$timestamp"
        Copy-Item $Path $backup -Force
        Write-Color "  ⚠️  Backed up: $(Split-Path $Path -Leaf)" $Yellow
    }
}

function Smart-Merge-Json {
    param([string]$Src, [string]$Dest)
    
    try {
        $srcJson = Get-Content $Src -Raw | ConvertFrom-Json
        
        if (Test-Path $Dest) {
            $destJson = Get-Content $Dest -Raw | ConvertFrom-Json
        } else {
            $destJson = @{}
        }

        # Deep merge logic (simplified: src overrides dest for top-level keys)
        # For a true deep merge in PS, we'd need a recursive function.
        # Here we use a simple approach: iterate src properties and set in dest.
        # Note: PS objects from JSON are PSCustomObject.
        
        # To do this properly without complex recursion, let's rely on the fact that
        # specific config files usually don't need deep merging of arrays, just keys.
        
        # Actually, for robustness, let's just use the Python script if available, 
        # or fallback to a simple merge.
        # Since Python is a prerequisite for the plugin skills anyway:
        
        if (Get-Command python -ErrorAction SilentlyContinue) {
            python -c "
import sys, json, os

src_path = r'$Src'
dest_path = r'$Dest'

try:
    with open(src_path, 'r', encoding='utf-8') as f:
        src_data = json.load(f)
    
    if os.path.exists(dest_path):
        with open(dest_path, 'r', encoding='utf-8') as f:
            dest_data = json.load(f)
    else:
        dest_data = {}

    def deep_update(d, u):
        for k, v in u.items():
            if isinstance(v, dict):
                d[k] = deep_update(d.get(k, {}), v)
            else:
                d[k] = v
        return d
    
    # We want dest to override src (wait, install.sh says dest overrides src? 
    # Let's check install.sh logic: 'merged = src_data.copy(); deep_update(merged, dest_data)'
    # This means DEST (existing user config) overrides SRC (plugin default). 
    # Yes, preserving user config is correct.
    
    merged = src_data.copy()
    deep_update(merged, dest_data)
    
    with open(dest_path, 'w', encoding='utf-8') as f:
        json.dump(merged, f, indent=2, ensure_ascii=False)
except Exception as e:
    sys.exit(1)
"
            if ($LASTEXITCODE -eq 0) {
                Write-Color "  ✅ Merged (JSON): $(Split-Path $Dest -Leaf)" $Green
            } else {
                Write-Color "  ❌ Merge failed (JSON). Overwriting..." $Red
                Copy-Item $Src $Dest -Force
            }
        } else {
             # Fallback: Overwrite if no python
             Write-Color "  ⚠️  Python not found. Overwriting JSON..." $Yellow
             Copy-Item $Src $Dest -Force
        }

    } catch {
        Write-Color "  ❌ Error merging JSON: $_" $Red
    }
}

function Smart-Merge-Text {
    param([string]$Src, [string]$Dest)
    
    if (-not (Test-Path $Dest)) {
        Copy-Item $Src $Dest -Force
        return
    }
    
    $srcLines = Get-Content $Src
    $destContent = Get-Content $Dest -Raw
    
    $newLines = @()
    foreach ($line in $srcLines) {
        if (-not [string]::IsNullOrWhiteSpace($line) -and -not $destContent.Contains($line.Trim())) {
            $newLines += $line
        }
    }
    
    if ($newLines.Count -gt 0) {
        Add-Content -Path $Dest -Value "`n# --- FlowState Merged Content ---"
        Add-Content -Path $Dest -Value $newLines
        Write-Color "  ✅ Merged (Text): $(Split-Path $Dest -Leaf)" $Green
    } else {
        Write-Color "  ⏭️  No new lines to merge" $Yellow
    }
}

$ConflictStrategy = "ask"

function Safe-Install {
    param([string]$Src, [string]$Dest)
    
    $SrcItem = Get-Item $Src
    $IsDir = $SrcItem.PSIsContainer
    
    if (-not (Test-Path (Split-Path $Dest))) {
        New-Item -ItemType Directory -Path (Split-Path $Dest) -Force | Out-Null
    }

    if ($Dev) {
        # Symlink
        if (Test-Path $Dest) {
            if ((Get-Item $Dest).Target -eq $Src) { return } # Already linked
            Backup-File $Dest
            Remove-Item $Dest -Recurse -Force
        }
        New-Item -ItemType SymbolicLink -Path $Dest -Target $Src | Out-Null
        Write-Color "  🔗 Symlinked $(Split-Path $Src -Leaf)" $Green
    } else {
        # Copy
        if (Test-Path $Dest) {
            if ($IsDir) {
                # Merge Directory
                Get-ChildItem $Src | ForEach-Object {
                    Safe-Install $_.FullName (Join-Path $Dest $_.Name)
                }
            } else {
                # File Conflict
                if ((Get-FileHash $Src).Hash -eq (Get-FileHash $Dest).Hash) {
                    Write-Color "  ⏭️  Skipping identical: $(Split-Path $Dest -Leaf)" $Yellow
                } else {
                    $action = ""
                    if ($global:ConflictStrategy -eq "overwrite_all") { $action = "overwrite" }
                    elseif ($global:ConflictStrategy -eq "skip_all") { $action = "skip" }
                    elseif ($global:ConflictStrategy -eq "backup_all") { $action = "backup" }
                    elseif ($global:ConflictStrategy -eq "merge_all") { $action = "merge" }
                    else {
                        Write-Host ""
                        Write-Color "⚠️  Conflict: $(Split-Path $Dest -Leaf) exists and differs." $Red
                        $choices = "&Overwrite", "&Skip", "&Backup", "&Merge", "Overwrite &All", "Skip A&ll", "Backup All", "Merge All"
                        $choice = $Host.UI.PromptForChoice("Conflict Resolution", "Choose an action", $choices, 1)
                        
                        switch ($choice) {
                            0 { $action = "overwrite" }
                            1 { $action = "skip" }
                            2 { $action = "backup" }
                            3 { $action = "merge" }
                            4 { $global:ConflictStrategy = "overwrite_all"; $action = "overwrite" }
                            5 { $global:ConflictStrategy = "skip_all"; $action = "skip" }
                            6 { $global:ConflictStrategy = "backup_all"; $action = "backup" }
                            7 { $global:ConflictStrategy = "merge_all"; $action = "merge" }
                        }
                    }
                    
                    switch ($action) {
                        "overwrite" { Copy-Item $Src $Dest -Force; Write-Color "  ✅ Overwritten: $(Split-Path $Dest -Leaf)" $Green }
                        "skip" { Write-Color "  ⏭️  Skipped: $(Split-Path $Dest -Leaf)" $Yellow }
                        "backup" { Backup-File $Dest; Copy-Item $Src $Dest -Force; Write-Color "  ✅ Updated (with backup): $(Split-Path $Dest -Leaf)" $Green }
                        "merge" {
                            if ($Dest -like "*.json") { Smart-Merge-Json $Src $Dest }
                            else { Smart-Merge-Text $Src $Dest }
                        }
                    }
                }
            }
        } else {
            if ($IsDir) {
                Copy-Item $Src $Dest -Recurse -Force
            } else {
                Copy-Item $Src $Dest -Force
            }
            Write-Color "  ✅ Installed $(Split-Path $Src -Leaf)" $Green
        }
    }
}

# --- Installation Steps ---

Write-Color "🚀 Installing Core Components..." $Blue

# 1. Install .claude/ contents
if (-not (Test-Path $ClaudeRoot)) { New-Item -ItemType Directory -Path $ClaudeRoot -Force | Out-Null }

Get-ChildItem (Join-Path $ScriptRoot ".claude") | ForEach-Object {
    if ($_.Name -ne "profiles") {
        Safe-Install $_.FullName (Join-Path $ClaudeRoot $_.Name)
    }
}

# 2. Install Go Profile
Write-Host ""
Write-Color "📦 Installing Go Development Profile..." $Blue

$ProfileDir = Join-Path $ScriptRoot ".claude\profiles\$DefaultProfile"

if (Test-Path (Join-Path $ProfileDir ".claude")) {
    Get-ChildItem (Join-Path $ProfileDir ".claude") | ForEach-Object {
        if ($_.PSIsContainer) {
            Safe-Install $_.FullName (Join-Path $ClaudeRoot $_.Name)
        } else {
            Safe-Install $_.FullName (Join-Path $ClaudeRoot $_.Name)
        }
    }
}

Safe-Install (Join-Path $ProfileDir "CLAUDE.md") (Join-Path $TargetDir "CLAUDE.md")
Safe-Install (Join-Path $ProfileDir "Makefile") (Join-Path $TargetDir "Makefile")

Write-Host ""
Write-Color "✅ Installation Complete!" $Green
Write-Host "----------------------------------------"
Write-Host "Project: $TargetDir"
Write-Host "Mode:    $(if ($Dev) { "Development (Symlinks)" } else { "Production (Copies)" })"
Write-Host "Profile: Go"
Write-Host "----------------------------------------"
Write-Host "To get started:"
Write-Host "1. cd $TargetDir"
Write-Host "2. Run: /optimize-prompt (to test the workflow)"
