#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════
#  Axion — Vault Setup Script v5.1
#  Run from vault root:
#    cd /path/to/your/vault
#    bash "99 - Meta/00 - Settings/SETUP.sh"
# ════════════════════════════════════════════════════════════

set -e

VAULT_ROOT="$(pwd)"
META="99 - Meta/00 - Settings"
OBSIDIAN_DIR=".obsidian"
PLUGIN_REGISTRY="$META/axion-plugins.json"
CONFIG_DIR="$META/02 - Plugin Configs"

GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'

log_ok()   { echo -e "${GREEN}✅  $1${NC}"; }
log_info() { echo -e "${BLUE}ℹ️   $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️   $1${NC}"; }
log_step() { echo -e "\n${CYAN}── $1${NC}"; }

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        AXION — Vault Setup v5.1          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# ── Dependency check ─────────────────────────────────────────
for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo -e "${RED}❌  $cmd required. Install: brew install $cmd${NC}"; exit 1
  fi
done
log_ok "curl + jq found"

if [ ! -f "$PLUGIN_REGISTRY" ]; then
  echo -e "${RED}❌  Run from vault root. axion-plugins.json not found.${NC}"; exit 1
fi

# ── 1. Dirs ───────────────────────────────────────────────────
log_step "1. Creating .obsidian directories"
mkdir -p "$OBSIDIAN_DIR/snippets" "$OBSIDIAN_DIR/plugins" "$OBSIDIAN_DIR/themes"
log_ok "Directories ready"

# ── 2. Install plugins ────────────────────────────────────────
log_step "2. Installing core plugins from axion-plugins.json"

while IFS='|' read -r PLUGIN_ID REPO PLUGIN_NAME; do
  PLUGIN_DIR="$OBSIDIAN_DIR/plugins/$PLUGIN_ID"
  mkdir -p "$PLUGIN_DIR"

  if [ -f "$PLUGIN_DIR/main.js" ]; then
    log_info "$PLUGIN_NAME — already installed, skipping"
    continue
  fi

  echo -e "  📦 ${CYAN}$PLUGIN_NAME${NC}"

  # Try latest release first
  TAG=$(curl -sf "https://api.github.com/repos/$REPO/releases/latest" \
        | jq -r '.tag_name // empty' 2>/dev/null || echo "")

  if [ -n "$TAG" ]; then
    BASE="https://github.com/$REPO/releases/download/$TAG"
  else
    BASE=""
  fi

  INSTALLED=false

  # Try release download → fallback to master/main branch
  for URL_BASE in "$BASE" \
    "https://raw.githubusercontent.com/$REPO/master" \
    "https://raw.githubusercontent.com/$REPO/main"; do

    [ -z "$URL_BASE" ] && continue

    if curl -sf "$URL_BASE/main.js" -o "$PLUGIN_DIR/main.js" 2>/dev/null && \
       curl -sf "$URL_BASE/manifest.json" -o "$PLUGIN_DIR/manifest.json" 2>/dev/null; then
      curl -sf "$URL_BASE/styles.css" -o "$PLUGIN_DIR/styles.css" 2>/dev/null || true
      log_ok "$PLUGIN_NAME installed"
      INSTALLED=true
      break
    fi
  done

  if [ "$INSTALLED" = false ]; then
    log_warn "$PLUGIN_NAME — auto-install failed. Install manually via Community Plugins."
    rm -f "$PLUGIN_DIR/main.js" 2>/dev/null
  fi

done < <(jq -r '.plugins[] | select(.tier == "core") | .id + "|" + .repo + "|" + .name' "$PLUGIN_REGISTRY")

# ── 3. Plugin configs ─────────────────────────────────────────
log_step "3. Applying plugin configurations (incl. Iconize folder icons)"

apply_config() {
  local ID="$1" SRC="$2" LABEL="$3"
  if [ -f "$SRC" ]; then
    mkdir -p "$OBSIDIAN_DIR/plugins/$ID"
    cp "$SRC" "$OBSIDIAN_DIR/plugins/$ID/data.json"
    log_ok "$LABEL"
  else
    log_warn "$LABEL — config not found: $SRC"
  fi
}

apply_config "periodic-notes"        "$CONFIG_DIR/periodic-notes.json"  "Periodic Notes config"
apply_config "obsidian-style-settings" "$CONFIG_DIR/style-settings.json" "Style Settings (Vauxhall Indigo)"
apply_config "obsidian-icon-folder"  "$CONFIG_DIR/icon-folders.json"    "Iconize (folder icons)"

# ── 4. Remix Icons (folder icons) ───────────────────────────────
log_step "4. Remix Icons pack"
ICONS_DIR="$OBSIDIAN_DIR/icons/remix-icons"
REMIX_ZIP="https://github.com/Remix-Design/RemixIcon/releases/download/v4.9.1/RemixIcon_Svg_v4.9.1.zip"
if [ ! -f "$ICONS_DIR/home-line.svg" ]; then
  mkdir -p "$ICONS_DIR"
  TMP_ZIP="/tmp/RemixIcon_$$.zip"
  TMP_EXT="/tmp/RemixIcon_extract_$$"
  if curl -sfL "$REMIX_ZIP" -o "$TMP_ZIP"; then
    rm -rf "$TMP_EXT"
    mkdir -p "$TMP_EXT"
    unzip -q -o "$TMP_ZIP" -d "$TMP_EXT" 2>/dev/null
    SRC_ICONS=$(find "$TMP_EXT" -type d -name "icons" 2>/dev/null | head -1)
    if [ -n "$SRC_ICONS" ] && [ -d "$SRC_ICONS" ]; then
      find "$SRC_ICONS" -name "*.svg" -exec cp {} "$ICONS_DIR/" \;
    fi
    rm -rf "$TMP_ZIP" "$TMP_EXT"
  else
    rm -f "$TMP_ZIP"
  fi
  [ -f "$ICONS_DIR/home-line.svg" ] && log_ok "Remix Icons installed" || log_warn "Remix Icons — download failed"
else
  log_info "Remix Icons — already installed"
fi

# ── 5. CSS snippets ───────────────────────────────────────────
log_step "5. CSS snippets"
SNIPPET="$META/01 - Preloaded Classes/Colored Sidebar Items.css"
[ -f "$SNIPPET" ] && cp "$SNIPPET" "$OBSIDIAN_DIR/snippets/Colored Sidebar Items.css" \
  && log_ok "Colored Sidebar Items" || log_warn "Snippet not found"

# ── 6. appearance.json ────────────────────────────────────────
log_step "6. Appearance (Vauxhall theme)"
APPEARANCE="$OBSIDIAN_DIR/appearance.json"
if [ -f "$APPEARANCE" ]; then
  UPDATED=$(jq '.enabledCssSnippets = ((.enabledCssSnippets // []) + ["Colored Sidebar Items"] | unique)' "$APPEARANCE")
  echo "$UPDATED" > "$APPEARANCE"
  log_ok "appearance.json — snippet entry added"
else
  cat > "$APPEARANCE" << 'JSON'
{
  "cssTheme": "Vauxhall",
  "enabledCssSnippets": ["Colored Sidebar Items"],
  "fontFamily": "JetBrains Mono Nerd Font Mono",
  "monospaceFontFamily": "JetBrains Mono Nerd Font Mono",
  "baseFontSize": 15
}
JSON
  log_ok "appearance.json written"
fi

# ── 7. community-plugins.json ─────────────────────────────────
log_step "7. Enabling plugins"
jq '.community_plugins_enabled' "$PLUGIN_REGISTRY" > "$OBSIDIAN_DIR/community-plugins.json"
PLUGIN_COUNT=$(jq '.community_plugins_enabled | length' "$PLUGIN_REGISTRY")
log_ok "community-plugins.json — $PLUGIN_COUNT plugins enabled"

# ── 8. CLI script permissions ─────────────────────────────────
log_step "8. CLI scripts"
[ -d "08 - Integration/_scripts" ] && \
  chmod +x "08 - Integration/_scripts/"*.sh 2>/dev/null && \
  log_ok "Scripts executable" || log_warn "Scripts dir not found"

# ── Summary ───────────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         Setup Complete 🟢                ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Manual steps remaining:${NC}"
echo ""
echo "  1. Restart Obsidian"
echo "  2. Settings → Appearance → Themes → Browse → install Vauxhall"
echo "  3. Settings → Templater → User scripts folder:"
echo "       99 - Meta/00 - Settings/00 - Scripts/"
echo "  4. Wire QuickAdd macros → see quickadd-config.md"
echo "  5. ~/.zshrc → add ANTHROPIC_API_KEY + GEMINI_API_KEY"
echo ""
echo -e "${GREEN}Open Home.md to start.${NC}"
echo ""
