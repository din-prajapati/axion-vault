# Install JetBrains Mono Nerd Font on Windows
# Run from vault root: powershell -ExecutionPolicy Bypass -File "99 - Meta\00 - Settings\install-jetbrains-mono-nerd-font.ps1"
# May require "Run as Administrator" for system-wide install

$ErrorActionPreference = "Stop"
$FontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
$TmpDir = Join-Path $env:TEMP "JetBrainsMonoNerdFont_$(Get-Random)"
$TmpZip = Join-Path $TmpDir "JetBrainsMono.zip"

Write-Host ""
Write-Host "JetBrains Mono Nerd Font Installer" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Check if already installed
$fontsPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Fonts)
$existingFont = Get-ChildItem $fontsPath -Filter "JetBrainsMonoNerdFontMono*.ttf" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($existingFont) {
    Write-Host "JetBrains Mono Nerd Font appears already installed at: $fontsPath" -ForegroundColor Green
    Write-Host "Restart Obsidian if fonts don't render correctly." -ForegroundColor Yellow
    exit 0
}

New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

try {
    Write-Host "Downloading JetBrains Mono Nerd Font..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $FontUrl -OutFile $TmpZip -UseBasicParsing -TimeoutSec 60
    
    Write-Host "Extracting..." -ForegroundColor Cyan
    Expand-Archive -Path $TmpZip -DestinationPath $TmpDir -Force
    
    $fontFiles = Get-ChildItem $TmpDir -Recurse -Include "*.ttf", "*.otf" | Where-Object { $_.Name -match "JetBrainsMono" -and $_.Name -notmatch "Windows" }
    
    if ($fontFiles.Count -eq 0) {
        $fontFiles = Get-ChildItem $TmpDir -Recurse -Include "*.ttf", "*.otf"
    }
    
    if ($fontFiles.Count -eq 0) {
        Write-Host "No font files found in archive." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Installing $($fontFiles.Count) font files..." -ForegroundColor Cyan
    
    $installed = 0
    foreach ($font in $fontFiles) {
        try {
            $dest = Join-Path $fontsPath $font.Name
            Copy-Item $font.FullName $dest -Force -ErrorAction Stop
            $installed++
        } catch {
            Write-Host "  Need admin for system install. Opening fonts folder for manual install..." -ForegroundColor Yellow
            explorer.exe (Split-Path $font.FullName)
            Write-Host ""
            Write-Host "Double-click each .ttf file and click 'Install' to install for current user." -ForegroundColor Yellow
            exit 0
        }
    }
    
    Write-Host ""
    Write-Host "Installed $installed fonts to $fontsPath" -ForegroundColor Green
    Write-Host "Restart Obsidian (and any other apps) to use the new font." -ForegroundColor Yellow
    
} finally {
    Remove-Item $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
