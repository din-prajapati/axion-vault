# Rename Remix Icon files from kebab-case to PascalCase for Iconize
# Iconize expects "Map2Line.svg" but Remix uses "map-2-line.svg"
# Run: powershell -ExecutionPolicy Bypass -File rename-remix-icons-for-iconize.ps1

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VaultRoot = Resolve-Path (Join-Path $ScriptDir "..\..")
$RemixDir = Join-Path $VaultRoot ".obsidian\icons\remix-icons"

if (-not (Test-Path $RemixDir)) {
    Write-Host "remix-icons folder not found."
    exit 1
}

function KebabToPascal($name) {
    $base = $name -replace '\.svg$',''
    $parts = $base -split '[_-]'
    ($parts | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }) -join '' + ".svg"
}

$files = Get-ChildItem $RemixDir -Filter "*.svg"
$renamed = 0
foreach ($f in $files) {
    $pascal = KebabToPascal $f.Name
    if ($f.Name -ne $pascal) {
        $target = Join-Path $RemixDir $pascal
        if (-not (Test-Path $target)) {
            Rename-Item $f.FullName $pascal -ErrorAction SilentlyContinue
            if ($?) { $renamed++ }
        }
    }
}
Write-Host "Renamed $renamed files. Restart Obsidian."
