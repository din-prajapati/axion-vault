@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================
::  Axion - Vault Setup (Windows)
::  Double-click this file OR run from Command Prompt.
::  No PowerShell policy, no admin, no installs needed.
:: ============================================================

:: Move to vault root (two levels up from this script)
cd /d "%~dp0..\.."
set "VAULT=%CD%"
set "META=%VAULT%\99 - Meta\00 - Settings"
set "OBS=%VAULT%\.obsidian"
set "CFG=%META%\02 - Plugin Configs"
set "REG=%META%\axion-plugins.json"

echo.
echo ============================================
echo   AXION - Vault Setup
echo ============================================
echo   Vault: %VAULT%
echo.

if not exist "%REG%" (
    echo [ERROR] axion-plugins.json not found.
    echo         Run this from vault root.
    goto :end
)

:: -- 1. Create .obsidian folders -------------------------------
echo [1/7] Creating .obsidian directories...
mkdir "%OBS%\snippets" 2>nul
mkdir "%OBS%\plugins"  2>nul
mkdir "%OBS%\themes"   2>nul
echo       Done.

:: -- 2. Apply plugin configs ------------------------------------
echo.
echo [2/7] Applying plugin configs...
call :apply_config "periodic-notes"          "%CFG%\periodic-notes.json" "Periodic Notes"
call :apply_config "obsidian-style-settings" "%CFG%\style-settings.json" "Style Settings"
call :apply_config "obsidian-icon-folder"    "%CFG%\icon-folders.json"   "Iconize"

:: -- 3. Remix Icons (for folder icons) --------------------------
echo.
echo [3/7] Installing Remix Icons pack...
set "ICONS=%OBS%\icons\remix-icons"
if not exist "%ICONS%\home-line.svg" (
    mkdir "%ICONS%" 2>nul
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
     "$url='https://github.com/Remix-Design/RemixIcon/releases/download/v4.9.1/RemixIcon_Svg_v4.9.1.zip';" ^
     "$tmp='%TEMP%\RemixIcon';$dst='%ICONS%';" ^
     "if(!(Test-Path $dst)){New-Item -ItemType Directory -Force -Path $dst|Out-Null};" ^
     "Invoke-WebRequest $url -OutFile ($tmp+'.zip') -UseBasicParsing;" ^
     "Expand-Archive -Path ($tmp+'.zip') -DestinationPath $tmp -Force;" ^
     "$r=Get-ChildItem $tmp -Directory|Select-Object -First 1;" ^
     "$src=Join-Path $r.FullName 'icons';if(!(Test-Path $src)){$src=Join-Path $tmp 'icons'};if(!(Test-Path $src)){$src=$tmp};" ^
     "Get-ChildItem $src -Recurse -Filter '*.svg' -EA 0|ForEach-Object{Copy-Item $_.FullName $dst -Force};" ^
     "Remove-Item ($tmp+'.zip') -Force;Remove-Item $tmp -Recurse -Force;"
    echo       Remix Icons - OK
) else (
    echo       Remix Icons - already installed
)

:: -- 4. CSS snippet ---------------------------------------------
echo.
echo [4/7] Installing CSS snippet...
set "SNIPPET=%META%\01 - Preloaded Classes\Colored Sidebar Items.css"
if exist "%SNIPPET%" (
    copy /Y "%SNIPPET%" "%OBS%\snippets\Colored Sidebar Items.css" >nul
    echo       Colored Sidebar Items - OK
) else (
    echo       [WARN] Snippet not found
)

:: -- 5. appearance.json -----------------------------------------
echo.
echo [5/7] Writing appearance.json...
set "APPR=%OBS%\appearance.json"
if not exist "%APPR%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$a=@{cssTheme='Vauxhall';enabledCssSnippets=@('Colored Sidebar Items');fontFamily='JetBrains Mono Nerd Font Mono';monospaceFontFamily='JetBrains Mono Nerd Font Mono';baseFontSize=15};$a|ConvertTo-Json|Set-Content '%APPR%' -Encoding UTF8"
    echo       Written.
) else (
    echo       Already exists - skipping.
)

:: -- 6. community-plugins.json ----------------------------------
echo.
echo [6/7] Writing community-plugins.json...
set "CPJSON=%OBS%\community-plugins.json"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$r=Get-Content '%REG%' -Raw|ConvertFrom-Json;$r.community_plugins_enabled|ConvertTo-Json|Set-Content '%CPJSON%' -Encoding UTF8"
echo       Done.

:: -- 7. Download plugins from GitHub -----------------------------
echo.
echo [7/7] Downloading plugins from GitHub...
echo       This may take a minute...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$obs='%OBS%';" ^
 "$reg=Get-Content '%REG%' -Raw|ConvertFrom-Json;" ^
 "$core=$reg.plugins|Where-Object{$_.tier -eq 'core'};" ^
 "foreach($p in $core){" ^
 "$dir=$obs+'\plugins\'+$p.id;" ^
 "New-Item -ItemType Directory -Force -Path $dir|Out-Null;" ^
 "if(Test-Path($dir+'\main.js')){Write-Host('  SKIP '+$p.name+' - already installed') -f Gray;continue;}" ^
 "Write-Host('  GET  '+$p.name) -f Cyan;" ^
 "$tag='';" ^
 "try{$rel=Invoke-RestMethod('https://api.github.com/repos/'+$p.repo+'/releases/latest') -Headers @{'User-Agent'='Axion'} -TimeoutSec 8;$tag=$rel.tag_name;}catch{}" ^
 "$bases=@();" ^
 "if($tag){$bases+='https://github.com/'+$p.repo+'/releases/download/'+$tag;}" ^
 "$bases+='https://raw.githubusercontent.com/'+$p.repo+'/master';" ^
 "$bases+='https://raw.githubusercontent.com/'+$p.repo+'/main';" ^
 "$ok=$false;" ^
 "foreach($base in $bases){" ^
 "try{" ^
 "Invoke-WebRequest($base+'/main.js') -OutFile($dir+'\main.js') -UseBasicParsing -TimeoutSec 15;" ^
 "Invoke-WebRequest($base+'/manifest.json') -OutFile($dir+'\manifest.json') -UseBasicParsing -TimeoutSec 10;" ^
 "try{Invoke-WebRequest($base+'/styles.css') -OutFile($dir+'\styles.css') -UseBasicParsing -TimeoutSec 8;}catch{}" ^
 "Write-Host('  OK   '+$p.name) -f Green;$ok=$true;break;" ^
 "}catch{Remove-Item($dir+'\main.js') -Force -EA SilentlyContinue;}}" ^
 "if(-not $ok){Write-Host('  FAIL '+$p.name+' - install manually via Community Plugins') -f Yellow;}}"

:: -- Done -------------------------------------------------------
echo.
echo ============================================
echo   Setup Complete
echo ============================================
echo.
echo   NEXT STEPS IN OBSIDIAN:
echo.
echo   1. Restart Obsidian
echo   2. Settings - Appearance - Themes - Browse
echo      Search Vauxhall - Install and Enable
echo   3. Settings - Templater - User scripts folder:
echo      99 - Meta\00 - Settings\00 - Scripts\
echo   4. Wire QuickAdd macros (see quickadd-config.md)
echo   5. Add API keys to Windows Environment Variables:
echo      ANTHROPIC_API_KEY = sk-ant-...
echo      GEMINI_API_KEY    = AIza...
echo.
echo   Open Home.md to start.
echo.
goto :end

:apply_config
set "pid=%~1"
set "src=%~2"
set "lbl=%~3"
if exist "%src%" (
    mkdir "%OBS%\plugins\%pid%" 2>nul
    copy /Y "%src%" "%OBS%\plugins\%pid%\data.json" >nul
    echo       %lbl% - OK
) else (
    echo       [WARN] %lbl% - config not found
)
exit /b

:end
echo.
pause
