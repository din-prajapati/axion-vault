# Install Remix Icons for Iconize plugin
# Run from vault root or from this script's folder
# Usage: powershell -ExecutionPolicy Bypass -File install-remix-icons.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VaultRoot = Resolve-Path (Join-Path $ScriptDir "..\..")
$IconsDir = Join-Path $VaultRoot ".obsidian\icons\remix-icons"
$Url = "https://github.com/Remix-Design/RemixIcon/releases/download/v4.9.1/RemixIcon_Svg_v4.9.1.zip"
$TmpDir = Join-Path $env:TEMP "RemixIcon_$(Get-Random)"
$TmpZip = Join-Path $TmpDir "remix.zip"

if (Test-Path (Join-Path $IconsDir "map-2-line.svg")) {
    Write-Host "Remix Icons already installed at $IconsDir"
    exit 0
}

Write-Host "Downloading Remix Icons..."
New-Item -ItemType Directory -Force -Path $IconsDir | Out-Null
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

try {
    Invoke-WebRequest -Uri $Url -OutFile $TmpZip -UseBasicParsing -TimeoutSec 30
    Write-Host "Extracting..."
    Expand-Archive -Path $TmpZip -DestinationPath $TmpDir -Force
    # Handle both structures: zip/RemixIcon_Svg_xxx/icons/... or zip/icons/...
    $SrcIcons = $null
    $RootFolder = Get-ChildItem $TmpDir -Directory | Select-Object -First 1
    if ($RootFolder) {
        $Candidate = Join-Path $RootFolder.FullName "icons"
        if (Test-Path $Candidate) { $SrcIcons = $Candidate }
    }
    if (-not $SrcIcons) { $SrcIcons = Join-Path $TmpDir "icons" }
    if (-not (Test-Path $SrcIcons)) {
        # Fallback: copy any .svg from zip
        $SrcIcons = $TmpDir
    }
    $svgs = Get-ChildItem $SrcIcons -Recurse -Filter "*.svg" -ErrorAction SilentlyContinue
    if ($svgs) {
        foreach ($f in $svgs) { Copy-Item $f.FullName $IconsDir -Force }
        Write-Host "Installed $($svgs.Count) icons (flat structure for Iconize)"
    } else {
        Write-Error "No SVG files found in zip. Try: Obsidian Settings > Iconize > Browse icon packs > Remix Icons"
    }
} finally {
    Remove-Item $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Done! Restart Obsidian to apply."
exit 0
