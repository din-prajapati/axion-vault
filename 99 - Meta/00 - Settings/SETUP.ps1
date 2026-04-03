# ════════════════════════════════════════════════════════════
#  Axion — Vault Setup Script (Windows)
#  Run from vault root in PowerShell:
#    cd "C:\path\to\your\vault"
#    .\99 - Meta\00 - Settings\SETUP.ps1
#
#  Requirements: Windows 10/11 with PowerShell 5.1+
#  No external tools needed — uses built-in PowerShell only
# ════════════════════════════════════════════════════════════

$ErrorActionPreference = "Stop"

# ── Colours ──────────────────────────────────────────────────
function Write-Ok    { param($msg) Write-Host "✅  $msg" -ForegroundColor Green }
function Write-Info  { param($msg) Write-Host "ℹ️   $msg" -ForegroundColor Cyan }
function Write-Warn  { param($msg) Write-Host "⚠️   $msg" -ForegroundColor Yellow }
function Write-Err   { param($msg) Write-Host "❌  $msg" -ForegroundColor Red }
function Write-Step  { param($msg) Write-Host "`n── $msg" -ForegroundColor Magenta }

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        AXION — Vault Setup v5.1          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Validate vault root ───────────────────────────────────────
$VAULT_ROOT    = Get-Location
$META          = "99 - Meta\00 - Settings"
$OBSIDIAN_DIR  = ".obsidian"
$PLUGIN_REG    = "$META\axion-plugins.json"
$CONFIG_DIR    = "$META\02 - Plugin Configs"

if (-not (Test-Path $PLUGIN_REG)) {
    Write-Err "axion-plugins.json not found."
    Write-Err "Run this script from inside your vault folder."
    exit 1
}

# ── Load plugin registry ──────────────────────────────────────
$Registry = Get-Content $PLUGIN_REG -Raw | ConvertFrom-Json
Write-Ok "axion-plugins.json loaded"

# ── 1. Create .obsidian dirs ──────────────────────────────────
Write-Step "1. Directory structure"

$dirs = @(
    "$OBSIDIAN_DIR\snippets",
    "$OBSIDIAN_DIR\plugins",
    "$OBSIDIAN_DIR\themes"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Write-Ok ".obsidian directories ready"

# ── 2. Install core plugins ───────────────────────────────────
Write-Step "2. Installing core plugins"

$corePlugins = $Registry.plugins | Where-Object { $_.tier -eq "core" }

foreach ($plugin in $corePlugins) {
    $pluginDir = "$OBSIDIAN_DIR\plugins\$($plugin.id)"
    New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null

    if (Test-Path "$pluginDir\main.js") {
        Write-Info "$($plugin.name) already installed — skipping"
        continue
    }

    Write-Host "  📦 $($plugin.name)" -ForegroundColor Cyan

    # Get latest release tag from GitHub API
    $releaseUrl = "https://api.github.com/repos/$($plugin.repo)/releases/latest"
    $tag = $null

    try {
        $headers = @{ "User-Agent" = "Axion-Setup" }
        $release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers -TimeoutSec 10
        $tag = $release.tag_name
    } catch {
        # no release found — will try raw branch
    }

    $installed = $false
    $tryUrls = @()

    if ($tag) {
        $tryUrls += "https://github.com/$($plugin.repo)/releases/download/$tag"
    }
    $tryUrls += "https://raw.githubusercontent.com/$($plugin.repo)/master"
    $tryUrls += "https://raw.githubusercontent.com/$($plugin.repo)/main"

    foreach ($base in $tryUrls) {
        try {
            Invoke-WebRequest "$base/main.js"       -OutFile "$pluginDir\main.js"       -UseBasicParsing -TimeoutSec 15
            Invoke-WebRequest "$base/manifest.json" -OutFile "$pluginDir\manifest.json" -UseBasicParsing -TimeoutSec 10
            try {
                Invoke-WebRequest "$base/styles.css" -OutFile "$pluginDir\styles.css"   -UseBasicParsing -TimeoutSec 10
            } catch { }
            Write-Ok "$($plugin.name) installed"
            $installed = $true
            break
        } catch {
            # try next URL
            Remove-Item "$pluginDir\main.js" -Force -ErrorAction SilentlyContinue
            Remove-Item "$pluginDir\manifest.json" -Force -ErrorAction SilentlyContinue
        }
    }

    if (-not $installed) {
        Write-Warn "$($plugin.name) — auto-install failed. Install manually via Community Plugins."
    }
}

# ── 3. Apply plugin configs ───────────────────────────────────
Write-Step "3. Plugin configurations"

function Apply-Config {
    param($PluginId, $ConfigFile, $Label)
    if (Test-Path $ConfigFile) {
        $dest = "$OBSIDIAN_DIR\plugins\$PluginId"
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        Copy-Item $ConfigFile "$dest\data.json" -Force
        Write-Ok "$Label"
    } else {
        Write-Warn "$Label — config not found: $ConfigFile"
    }
}

Apply-Config "periodic-notes"          "$CONFIG_DIR\periodic-notes.json"  "Periodic Notes config"
Apply-Config "obsidian-style-settings" "$CONFIG_DIR\style-settings.json"  "Style Settings (Vauxhall Indigo)"
Apply-Config "obsidian-icon-folder"    "$CONFIG_DIR\icon-folders.json"    "Iconize (folder icons)"

# ── 4. CSS snippet ────────────────────────────────────────────
Write-Step "4. CSS snippets"

$snippet = "$META\01 - Preloaded Classes\Colored Sidebar Items.css"
if (Test-Path $snippet) {
    Copy-Item $snippet "$OBSIDIAN_DIR\snippets\Colored Sidebar Items.css" -Force
    Write-Ok "Colored Sidebar Items snippet installed"
} else {
    Write-Warn "Snippet not found: $snippet"
}

# ── 5. appearance.json ────────────────────────────────────────
Write-Step "5. Appearance (Vauxhall theme)"

$appearancePath = "$OBSIDIAN_DIR\appearance.json"

if (Test-Path $appearancePath) {
    $appearance = Get-Content $appearancePath -Raw | ConvertFrom-Json
    $snippets = @($appearance.enabledCssSnippets) + @("Colored Sidebar Items") | Select-Object -Unique
    $appearance.enabledCssSnippets = $snippets
    $appearance | Add-Member -NotePropertyName "fontFamily" -NotePropertyValue "JetBrains Mono Nerd Font Mono" -Force
    $appearance | Add-Member -NotePropertyName "interfaceFontFamily" -NotePropertyValue "JetBrains Mono Nerd Font Mono" -Force
    $appearance | Add-Member -NotePropertyName "textFontFamily" -NotePropertyValue "JetBrains Mono Nerd Font Mono" -Force
    $appearance | Add-Member -NotePropertyName "monospaceFontFamily" -NotePropertyValue "JetBrains Mono Nerd Font Mono" -Force
    $appearance | Add-Member -NotePropertyName "baseFontSize" -NotePropertyValue 15 -Force
    $appearance | ConvertTo-Json -Depth 10 | Set-Content $appearancePath -Encoding UTF8
    Write-Ok "appearance.json — snippet + JetBrains Mono"
} else {
    $appearanceContent = @{
        cssTheme             = "Vauxhall"
        enabledCssSnippets   = @("Colored Sidebar Items")
        fontFamily           = "JetBrains Mono Nerd Font Mono"
        interfaceFontFamily  = "JetBrains Mono Nerd Font Mono"
        textFontFamily       = "JetBrains Mono Nerd Font Mono"
        monospaceFontFamily  = "JetBrains Mono Nerd Font Mono"
        baseFontSize         = 15
    } | ConvertTo-Json -Depth 5
    Set-Content $appearancePath $appearanceContent -Encoding UTF8
    Write-Ok "appearance.json written (Vauxhall · JetBrains Mono)"
}

# ── 6. community-plugins.json ─────────────────────────────────
Write-Step "6. Enabling plugins"

$enabledPlugins = $Registry.community_plugins_enabled
$enabledPlugins | ConvertTo-Json | Set-Content "$OBSIDIAN_DIR\community-plugins.json" -Encoding UTF8
Write-Ok "community-plugins.json written ($($enabledPlugins.Count) plugins enabled)"

# ── Done ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Setup Complete 🟢                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Manual steps remaining:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Restart Obsidian"
Write-Host "  2. Settings → Appearance → Themes → Browse → install Vauxhall"
Write-Host "  3. Settings → Templater → User scripts folder:"
Write-Host "       99 - Meta\00 - Settings\00 - Scripts\"
Write-Host "  4. Wire QuickAdd macros → see quickadd-config.md"
Write-Host "  5. Add API keys to System Environment Variables:"
Write-Host "       ANTHROPIC_API_KEY = sk-ant-..."
Write-Host "       GEMINI_API_KEY    = AIza..."
Write-Host ""
Write-Host "Open Home.md to start." -ForegroundColor Green
Write-Host ""
