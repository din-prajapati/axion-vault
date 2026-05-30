# ════════════════════════════════════════════════════════════
#  ANTRIKSH — Vault bootstrap (Phase 0 / EP-0.1)
#  Run from anywhere in PowerShell (Git required):
#    powershell -ExecutionPolicy Bypass -File "path\to\ANTRIKSH-SETUP.ps1"
#
#  Defaults: bare repo D:\Dinesh\DCloud\GITDrive\Repos\antriksh.git
#            work tree  D:\Dinesh\DCloud\OneDrive\[05] VAULTS\ANTRIKSH  (Obsidian opens this folder)
#  Seeds: copies AXION vault folder tree + .obsidian (from this repo) unless 99 - Meta already exists
#          (use -ForceSeedFromAxion to re-copy). Excludes .git, .cursor, .codacy.
#  Idempotent: safe to run multiple times.
#
#  Windows Security (if you see "Protected folder" / Defender notifications):
#  - Controlled Folder Access can block writes to OneDrive/Documents. Allow: powershell.exe,
#    robocopy.exe, git.exe, Obsidian.exe (Windows Security > Virus & threat protection >
#    Ransomware protection > Allow an app through Controlled folder access).
#  - A lone "+" in the terminal is usually not an error (diff/continuation/rendering); look for
#    "[err]" lines or a non-zero exit code to confirm failure.
# ════════════════════════════════════════════════════════════

[CmdletBinding()]
param(
    [string] $BareGitDir = "D:\Dinesh\DCloud\GITDrive\Repos\antriksh.git",
    [string] $WorkTree   = "D:\Dinesh\DCloud\OneDrive\[05] VAULTS\ANTRIKSH",
    [string] $AxionVaultRoot = "",
    [switch] $SkipSeedFromAxion,
    [switch] $ForceSeedFromAxion,
    [switch] $SkipProfile
)

$ErrorActionPreference = "Stop"

# Phase 0 contract (GAUNTLET env overlay):
# - If env keys are set, they define the canonical bare repo + work tree locations.
# - CLI parameters still win if explicitly provided to this script.
if ($env:ANTRIKSH_BARE_REPO -and -not $PSBoundParameters.ContainsKey('BareGitDir')) {
    $BareGitDir = $env:ANTRIKSH_BARE_REPO
}
if ($env:ANTRIKSH_WORKTREE -and -not $PSBoundParameters.ContainsKey('WorkTree')) {
    $WorkTree = $env:ANTRIKSH_WORKTREE
}

function Write-Ok    { param($msg) Write-Host "[ok]   $msg" -ForegroundColor Green }
function Write-Info  { param($msg) Write-Host "[info] $msg" -ForegroundColor Cyan }
function Write-Warn  { param($msg) Write-Host "[warn] $msg" -ForegroundColor Yellow }
function Write-Err   { param($msg) Write-Host "[err]  $msg" -ForegroundColor Red }
function Write-Step  { param($msg) Write-Host "`n--- $msg" -ForegroundColor Magenta }

function Test-GitAvailable {
    try {
        $null = & git --version 2>&1
        return $true
    } catch {
        return $false
    }
}

function Get-AntrikshGitignoreContent {
    @'
# ANTRIKSH vault — binary attachments (Git tracks notes, not blobs)
_attachments/**/*.png
_attachments/**/*.jpg
_attachments/**/*.jpeg
_attachments/**/*.gif
_attachments/**/*.webp
_attachments/**/*.bmp
_attachments/**/*.ico
_attachments/**/*.pdf
_attachments/**/*.mp4
_attachments/**/*.mov
_attachments/**/*.webm
_attachments/**/*.mkv
_attachments/**/*.mp3
_attachments/**/*.wav
_attachments/**/*.zip
_attachments/**/*.7z
_attachments/**/*.rar

# OneDrive / sync conflict copies
**/* (conflicted copy)*

# Obsidian volatile / machine-local
.obsidian/workspace
.obsidian/workspace.json
.obsidian/workspaces.json
.obsidian/cache
.obsidian/graph.json
.obsidian/starred.json
.obsidian/bookmarks.json
.obsidian/recent-files-obsidian.json
.obsidian/plugins/*/data.json

# OS / editor
.DS_Store
.DS_Store?
._*
Thumbs.db
ehthumbs.db
Desktop.ini
*.swp
*.swo
*~

# Secrets
**/secrets.*
**/.secrets
.env
.env.local
.env.*.local
'@
}

function Get-AntrikshProfileBlock {
    param(
        [string] $GitDir,
        [string] $Tree
    )
    $gd = $GitDir.Replace("'", "''")
    $wt = $Tree.Replace("'", "''")
    $tpl = @'
function Global:antriksh {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]] $GitArgs
    )
    & git --git-dir='__GITDIR__' --work-tree='__WORKTREE__' @GitArgs
}
'@
    return $tpl.Replace('__GITDIR__', $gd).Replace('__WORKTREE__', $wt)
}

function Get-AntrikshGitignoreAppendBlock {
    @'

# --- ANTRIKSH attachments (not in all AXION branches; added by ANTRIKSH-SETUP.ps1) ---
_attachments/**/*.png
_attachments/**/*.jpg
_attachments/**/*.jpeg
_attachments/**/*.gif
_attachments/**/*.webp
_attachments/**/*.bmp
_attachments/**/*.ico
_attachments/**/*.pdf
_attachments/**/*.mp4
_attachments/**/*.mov
_attachments/**/*.webm
_attachments/**/*.mkv
_attachments/**/*.mp3
_attachments/**/*.wav
_attachments/**/*.zip
_attachments/**/*.7z
_attachments/**/*.rar
'@
}

function Invoke-AxionSeedRobocopy {
    param(
        [string] $Source,
        [string] $Dest
    )
    $robocopy = Join-Path $env:windir "System32\robocopy.exe"
    if (-not (Test-Path -LiteralPath $robocopy)) {
        throw "robocopy.exe not found at $robocopy"
    }
    & $robocopy $Source $Dest /E /COPY:DAT /DCOPY:DAT /R:2 /W:2 /NFL /NDL /NJH /NJS /NP /XD .git .cursor .codacy
    $code = $LASTEXITCODE
    if ($code -ge 8) {
        throw "robocopy failed with exit code $code (8+ = error; see robocopy docs)"
    }
}

function Remove-AntrikshObsidianVolatile {
    param([string] $VaultRoot)
    $relative = @(
        '.obsidian\workspace',
        '.obsidian\workspace.json',
        '.obsidian\workspaces.json',
        '.obsidian\graph.json',
        '.obsidian\starred.json',
        '.obsidian\bookmarks.json',
        '.obsidian\recent-files-obsidian.json',
        '.obsidian\cache'
    )
    foreach ($rel in $relative) {
        $p = Join-Path $VaultRoot $rel
        if (Test-Path -LiteralPath $p) {
            Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Ensure-AntrikshGitignoreAppend {
    param([string] $VaultRoot)
    $giPath = Join-Path $VaultRoot ".gitignore"
    if (-not (Test-Path -LiteralPath $giPath)) {
        return
    }
    $raw = Get-Content -LiteralPath $giPath -Raw -ErrorAction SilentlyContinue
    if ($raw -and $raw.Contains('_attachments/**/*.png')) {
        return
    }
    Add-Content -LiteralPath $giPath -Value (Get-AntrikshGitignoreAppendBlock) -Encoding UTF8
}

function Ensure-AntrikshGitignoreConflictCopies {
    param([string] $VaultRoot)
    $giPath = Join-Path $VaultRoot ".gitignore"
    if (-not (Test-Path -LiteralPath $giPath)) {
        return
    }
    $raw = Get-Content -LiteralPath $giPath -Raw -ErrorAction SilentlyContinue
    if ($raw -and $raw.Contains('(conflicted copy)')) {
        return
    }
    Add-Content -LiteralPath $giPath -Value @'

# OneDrive / sync conflict copies
**/* (conflicted copy)*
'@ -Encoding UTF8
}

function Write-ProfileFileUtf8Bom {
    param(
        [string] $FilePath,
        [string] $Content
    )
    # Do not normalize with GetFullPath — OneDrive paths can break after resolution.
    $dir = Split-Path -Parent $FilePath
    if ($dir) {
        [void][System.IO.Directory]::CreateDirectory($dir)
    }
    $enc = New-Object System.Text.UTF8Encoding $true
    [System.IO.File]::WriteAllText($FilePath, $Content, $enc)
}

function Get-AntrikshProfileFallbackPath {
    $root = Join-Path $env:LOCALAPPDATA "Antriksh"
    [void][System.IO.Directory]::CreateDirectory($root)
    return (Join-Path $root "antriksh-git-wrapper.ps1")
}

Write-Host ""
Write-Host "ANTRIKSH Vault Bootstrap (Phase 0)" -ForegroundColor Cyan
Write-Host ""
Write-Info "Phases: 1=Git  2=Bare repo  3=Work tree  4=Seed AXION  5=.gitignore  6=Profile  7=Smoke test  8=Done"
Write-Host ""

if (-not (Test-GitAvailable)) {
    Write-Err "Git is not on PATH. Install Git for Windows and re-run."
    Write-Err "Stopped at phase 1 (Git preflight). Nothing after this ran."
    exit 1
}

Write-Info "[Phase 1/8] Git OK"

# Normalize paths (no trailing slash for git-dir; work tree OK either way)
$BareGitDir = $BareGitDir.TrimEnd('\', '/')
$WorkTree   = $WorkTree.TrimEnd('\', '/')

Write-Info "Bare repo:  $BareGitDir"
Write-Info "Work tree:  $WorkTree"

# Resolve AXION product vault (this script lives in 99 - Meta/00 - Settings)
$resolvedAxion = $AxionVaultRoot.Trim()
if ([string]::IsNullOrWhiteSpace($resolvedAxion)) {
    $resolvedAxion = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
}
$resolvedAxion = $resolvedAxion.TrimEnd('\', '/')

Write-Info "[Phase 2/8] Bare Git repository"

# --- Parent of bare repo path (created if missing) ---
$bareParent = Split-Path -Parent $BareGitDir
if ($bareParent -and -not (Test-Path -LiteralPath $bareParent)) {
    Write-Step "Creating Git repos parent: $bareParent"
    [void][System.IO.Directory]::CreateDirectory($bareParent)
    Write-Ok "Created $bareParent"
}

# --- Bare repository ---
if (Test-Path -LiteralPath (Join-Path $BareGitDir "HEAD")) {
    Write-Ok "Bare repo already exists - skipping git init --bare"
} else {
    Write-Step "Initializing bare repo"
    if (Test-Path -LiteralPath $BareGitDir) {
        $children = Get-ChildItem -LiteralPath $BareGitDir -Force -ErrorAction SilentlyContinue
        if ($children) {
            Write-Err "Path exists but is not a bare repo: $BareGitDir"
            Write-Err "Stopped at phase 2 (bare repo). Fix path or remove non-Git content."
            exit 1
        }
    }
    [void][System.IO.Directory]::CreateDirectory($BareGitDir)
    & git init --bare $BareGitDir
    if ($LASTEXITCODE -ne 0) {
        Write-Err "git init --bare failed."
        Write-Err "Stopped at phase 2 (bare repo)."
        exit $LASTEXITCODE
    }
    Write-Ok "Bare repo initialized"
}

# Ensure core.bare is true (idempotent)
& git --git-dir=$BareGitDir config core.bare true
if ($LASTEXITCODE -ne 0) {
    Write-Err "Could not set core.bare"
    Write-Err "Stopped at phase 2 (bare repo config)."
    exit $LASTEXITCODE
}

# Record work tree on bare repo for operators (custom key; avoids mutating core.bare semantics)
$wtForConfig = $WorkTree -replace '\\', '/'
& git --git-dir=$BareGitDir config antriksh.workTree $wtForConfig 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Could not set antriksh.workTree (optional)."
}

Write-Info "[Phase 3/8] ANTRIKSH vault folder (Git work tree)"

# --- Working tree directory (vault root: .NET API so [05] is never treated as a wildcard) ---
Write-Step "ANTRIKSH vault folder (Git work tree)"
try {
    [void][System.IO.Directory]::CreateDirectory($WorkTree)
} catch {
    Write-Err "Could not create vault folder: $WorkTree"
    Write-Err "Stopped at phase 3 (work tree). Check path, permissions, Controlled Folder Access."
    throw
}
if (Test-Path -LiteralPath $WorkTree) {
    Write-Ok "Vault root ready: $WorkTree"
} else {
    Write-Err "Vault folder missing after create: $WorkTree"
    Write-Err "Stopped at phase 3 (work tree)."
    exit 1
}

Write-Info "[Phase 4/8] Seed from AXION (or skip)"

# --- Seed folder tree + Obsidian config from AXION product vault ---
$seedMarker = Join-Path $WorkTree "99 - Meta"
$copiedVaultFromAxion = $false
if (-not $SkipSeedFromAxion) {
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedAxion "99 - Meta"))) {
        Write-Err "AXION vault root invalid (missing 99 - Meta): $resolvedAxion"
        Write-Err "Pass -AxionVaultRoot 'C:\path\to\axion-vault-product' if this script was copied elsewhere."
        Write-Err "Stopped at phase 4 (seed)."
        exit 1
    }
    $axFull = [System.IO.Path]::GetFullPath($resolvedAxion)
    $wtFull = [System.IO.Path]::GetFullPath($WorkTree)
    if ($axFull.Equals($wtFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Err "Work tree cannot be the same folder as the AXION product vault."
        Write-Err "Stopped at phase 4 (seed)."
        exit 1
    }
    Write-Info "AXION seed source: $resolvedAxion"
    if ((Test-Path -LiteralPath $seedMarker) -and -not $ForceSeedFromAxion) {
        Write-Warn 'ANTRIKSH already contains 99 - Meta - skipping robocopy (no overwrite). Use -ForceSeedFromAxion to re-copy from AXION.'
    } else {
        Write-Step 'Copy AXION vault into ANTRIKSH (structure and .obsidian; excludes .git, .cursor, .codacy)'
        try {
            Invoke-AxionSeedRobocopy -Source $resolvedAxion -Dest $WorkTree
        } catch {
            Write-Err $_.Exception.Message
            Write-Err "Stopped at phase 4 (robocopy seed). Check Defender / disk space / paths."
            exit 1
        }
        Remove-AntrikshObsidianVolatile -VaultRoot $WorkTree
        [void][System.IO.Directory]::CreateDirectory((Join-Path $WorkTree "_attachments"))
        Write-Ok "Volatile Obsidian UI files removed in ANTRIKSH; _attachments folder ensured"
        $copiedVaultFromAxion = $true
    }
} else {
    Write-Info 'SkipSeedFromAxion: not copying from AXION (folder layout and .obsidian you must manage yourself).'
}

Write-Info "[Phase 5/8] .gitignore"

# --- .gitignore in ANTRIKSH ---
Write-Step ".gitignore in work tree"
$giPath = Join-Path $WorkTree ".gitignore"
$desired = Get-AntrikshGitignoreContent
if ($copiedVaultFromAxion -and (Test-Path -LiteralPath $giPath)) {
    Write-Ok "Keeping AXION product .gitignore (robocopy); only ANTRIKSH extras appended if missing"
} elseif (-not (Test-Path -LiteralPath $giPath)) {
    Set-Content -LiteralPath $giPath -Value $desired -Encoding UTF8
    Write-Ok "Created .gitignore (minimal ANTRIKSH template)"
} else {
    $firstLine = Get-Content -LiteralPath $giPath -TotalCount 1 -ErrorAction SilentlyContinue
    if ($firstLine -match 'Obsidian System') {
        Write-Ok ".gitignore is AXION product style - leaving in place"
    } else {
        $current = Get-Content -LiteralPath $giPath -Raw -ErrorAction SilentlyContinue
        $normCurrent = if ($current) {
            $t = $current.TrimStart([char]0xFEFF)
            ($t -replace "`r`n", "`n").TrimEnd()
        } else { "" }
        $normDesired = ($desired -replace "`r`n", "`n").TrimEnd()
        if ($normCurrent -eq $normDesired) {
            Write-Ok ".gitignore already matches minimal template - unchanged"
        } else {
            Copy-Item -LiteralPath $giPath -Destination "$giPath.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
            Set-Content -LiteralPath $giPath -Value $desired -Encoding UTF8
            Write-Ok ".gitignore updated to minimal template (previous saved as .bak)"
        }
    }
}

Ensure-AntrikshGitignoreAppend -VaultRoot $WorkTree
Ensure-AntrikshGitignoreConflictCopies -VaultRoot $WorkTree
if ((Test-Path -LiteralPath $giPath) -and (Get-Content -LiteralPath $giPath -Raw).Contains('_attachments/**/*.png')) {
    Write-Ok ".gitignore includes ANTRIKSH _attachments rules"
}

Write-Info "[Phase 6/8] PowerShell profile (skip with -SkipProfile)"

# --- PowerShell profile: antriksh ---
if (-not $SkipProfile) {
    Write-Step "PowerShell profile (antriksh)"
    if ([string]::IsNullOrWhiteSpace($PROFILE)) {
        Write-Err "`$PROFILE is empty; cannot install antriksh. Re-run in PowerShell or use -SkipProfile."
        Write-Err "Stopped at phase 6 (profile)."
        exit 1
    }
    $profileDir = Split-Path -Parent $PROFILE
    # VS Code / OneDrive: parent folder often does not exist until created; Set-Content fails with "Could not find file" if we skip this.
    try {
        [void][System.IO.Directory]::CreateDirectory($profileDir)
    } catch {
        Write-Err "Could not create profile directory: $profileDir"
        Write-Err "Stopped at phase 6 (profile). Check Controlled Folder Access on Documents."
        throw
    }
    if (-not (Test-Path -LiteralPath $profileDir)) {
        Write-Err "Profile directory missing after create: $profileDir"
        Write-Err "Stopped at phase 6 (profile)."
        exit 1
    }
    Write-Ok "Profile directory ready: $profileDir"

    $markerStart = "# --- ANTRIKSH vault git wrapper (ANTRIKSH-SETUP.ps1) ---"
    $markerEnd   = "# --- end ANTRIKSH ---"
    $block       = Get-AntrikshProfileBlock -GitDir $BareGitDir -Tree $WorkTree

    $newBody = "$markerStart`n$($block.Trim())`n$markerEnd"
    $profileWritten = $false
    $profileFallbackFile = $null

    if (-not (Test-Path -LiteralPath $PROFILE)) {
        try {
            Write-ProfileFileUtf8Bom -FilePath $PROFILE -Content $newBody
            $profileWritten = $true
            Write-Ok "Created `$PROFILE and added antriksh"
        } catch {
            Write-Warn "Could not write `$PROFILE (OneDrive / Controlled Folder Access often blocks this path)."
            Write-Warn $_.Exception.Message
        }
    } else {
        try {
            $profPath = if (Test-Path -LiteralPath $PROFILE) { (Get-Item -LiteralPath $PROFILE).FullName } else { $PROFILE }
            $profRaw = [System.IO.File]::ReadAllText($profPath)
            if ($profRaw -match [regex]::Escape($markerStart)) {
                $pattern = '(?s)' + [regex]::Escape($markerStart) + '.*?' + [regex]::Escape($markerEnd)
                $updated = $profRaw -replace $pattern, ($markerStart + "`n" + $block.Trim() + "`n" + $markerEnd)
                Write-ProfileFileUtf8Bom -FilePath $PROFILE -Content $updated.TrimEnd()
                Write-Ok "Updated existing antriksh block in `$PROFILE"
            } else {
                $appended = $profRaw.TrimEnd() + "`n$markerStart`n$($block.Trim())`n$markerEnd"
                Write-ProfileFileUtf8Bom -FilePath $PROFILE -Content $appended
                Write-Ok "Appended antriksh to `$PROFILE"
            }
            $profileWritten = $true
        } catch {
            Write-Warn "Could not update `$PROFILE."
            Write-Warn $_.Exception.Message
        }
    }

    if (-not $profileWritten) {
        $fallback = Get-AntrikshProfileFallbackPath
        $profileFallbackFile = $fallback
        $escapedPath = $fallback.Replace("'", "''")
        $dotLine = ". '$escapedPath'"
        $fallbackContent = @"
# ANTRIKSH git wrapper (fallback - primary `$PROFILE was not writable; written by ANTRIKSH-SETUP.ps1)
$($block.Trim())
# Add to your profile:  $dotLine
"@
        try {
            Write-ProfileFileUtf8Bom -FilePath $fallback -Content $fallbackContent
            Write-Ok "Wrote antriksh wrapper to (outside OneDrive): $fallback"
            Write-Warn "Add this one line to your PowerShell profile ($PROFILE):"
            Write-Warn "  $dotLine"
        } catch {
            Write-Err "Could not write profile or fallback: $fallback"
            Write-Err $_.Exception.Message
            Write-Err "Stopped at phase 6 (profile). Try -SkipProfile or allow PowerShell in Windows Security."
            exit 1
        }
    }

    Write-Info "Profile target: $PROFILE"
    if ($profileFallbackFile) {
        Write-Info "antriksh function is in fallback file; dot-source it from your profile (see warning above)."
    } else {
        Write-Info "Open a new PowerShell window for antriksh to load, or run: . `$PROFILE"
    }
} else {
    Write-Warn "Phase 6 skipped: -SkipProfile (antriksh not installed to `$PROFILE)."
}

Write-Info "[Phase 7/8] Git smoke test"

# --- Smoke test ---
Write-Step "Verify git --git-dir / --work-tree"
& git --git-dir=$BareGitDir --work-tree=$WorkTree status --short 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Warn "git status returned exit $LASTEXITCODE (normal if no commits yet)."
} else {
    Write-Ok "git status OK"
}

Write-Host ""
Write-Info "[Phase 8/8] Finished"
Write-Host "=== ANTRIKSH bootstrap complete ===" -ForegroundColor Green
Write-Host "(Exit code 0 = script finished all phases it was asked to run.)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Next steps (manual / after script):" -ForegroundColor Cyan
Write-Host ('  1. New terminal (or:  . $PROFILE  ) then run:  antriksh status')
Write-Host ('  2. Obsidian: File -> Open folder as vault -> ' + $WorkTree)
Write-Host '  3. Open Obsidian on ANTRIKSH; if plugins are missing, run from vault root:  .\99 - Meta\00 - Settings\SETUP.ps1'
Write-Host '  4. Optional: Remotely Save plugin for mobile; keep ONE Obsidian instance per device.'
Write-Host '  5. First commit:  antriksh add .  then  antriksh commit -m "init: ANTRIKSH vault"'
Write-Host '  6. GitHub: create private repo, then:  antriksh remote add origin {your-url}  then  antriksh push -u origin main'
Write-Host ""
Write-Host "Parameters (override defaults):" -ForegroundColor DarkGray
Write-Host '  -BareGitDir  -WorkTree  -AxionVaultRoot  -SkipSeedFromAxion  -ForceSeedFromAxion  -SkipProfile'
Write-Host ""
