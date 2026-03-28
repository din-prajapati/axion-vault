# Fix Remix Icons structure for Iconize plugin
# Iconize only loads SVGs directly in the pack folder (no recursion).
# This script: 1) Flattens remix-icons (moves SVGs from subfolders to root)
#              2) Moves boxicons/font-awesome out of remix-icons if nested

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VaultRoot = Resolve-Path (Join-Path $ScriptDir "..\..")
$IconsRoot = Join-Path $VaultRoot ".obsidian\icons"
$RemixDir = Join-Path $IconsRoot "remix-icons"

if (-not (Test-Path $RemixDir)) {
    Write-Host "remix-icons folder not found. Run install-remix-icons.ps1 first."
    exit 1
}

Write-Host "Flattening remix-icons (Iconize needs SVGs directly in folder)..."
$svgs = Get-ChildItem $RemixDir -Recurse -Filter "*.svg" | Where-Object { $_.DirectoryName -ne $RemixDir }
$moved = 0
foreach ($f in $svgs) {
    $dest = Join-Path $RemixDir $f.Name
    Move-Item $f.FullName $dest -Force
    $moved++
}

Write-Host "Moved $moved SVG files to remix-icons root."

# Move misplaced packs (boxicons, font-awesome) out of remix-icons
$packsToMove = @("boxicons", "font-awesome-brands", "font-awesome-solid")
foreach ($pack in $packsToMove) {
    $nested = Join-Path $RemixDir $pack
    if (Test-Path $nested) {
        $dest = Join-Path $IconsRoot $pack
        if (-not (Test-Path $dest)) {
            Move-Item $nested $dest -Force
            Write-Host "Moved $pack to .obsidian/icons/"
        } else {
            Remove-Item $nested -Recurse -Force
            Write-Host "Removed duplicate $pack from remix-icons"
        }
    }
}

# Remove empty category folders
Get-ChildItem $RemixDir -Directory | ForEach-Object {
    if ((Get-ChildItem $_.FullName -Recurse -Force | Measure-Object).Count -eq 0) {
        Remove-Item $_.FullName -Force
    }
}

$finalCount = (Get-ChildItem $RemixDir -Filter "*.svg").Count
Write-Host "Done. remix-icons now has $finalCount SVGs at root level."
Write-Host "Restart Obsidian to apply."
