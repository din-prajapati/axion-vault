#!/usr/bin/env bash
# ============================================================
# Cloud KMS — Vault Activator
# Run once from inside the vault root directory:
#   cd /path/to/your/vault && bash "99 - Meta/00 - Settings/SETUP.sh"
# ============================================================

set -e
VAULT_ROOT="$(pwd)"
META="99 - Meta/00 - Settings"
OBSIDIAN_DIR=".obsidian"

echo "🔵 Cloud KMS Setup — starting from: $VAULT_ROOT"
echo ""

# ── 1. Create .obsidian dirs ────────────────────────────────
mkdir -p "$OBSIDIAN_DIR/snippets"
mkdir -p "$OBSIDIAN_DIR/plugins/periodic-notes"
mkdir -p "$OBSIDIAN_DIR/plugins/style-settings"
echo "✅ .obsidian directories created"

# ── 2. CSS snippet — Colored Sidebar Items ──────────────────
SNIPPET_SRC="$META/01 - Preloaded Classes/Colored Sidebar Items.css"
if [ -f "$SNIPPET_SRC" ]; then
  cp "$SNIPPET_SRC" "$OBSIDIAN_DIR/snippets/Colored Sidebar Items.css"
  echo "✅ CSS snippet copied → .obsidian/snippets/"
else
  echo "⚠️  Snippet not found: $SNIPPET_SRC"
fi

# ── 3. Periodic Notes plugin config ────────────────────────
PNOTES_SRC="$META/02 - Plugin Configs/periodic-notes.json"
if [ -f "$PNOTES_SRC" ]; then
  cp "$PNOTES_SRC" "$OBSIDIAN_DIR/plugins/periodic-notes/data.json"
  echo "✅ Periodic Notes config installed"
else
  echo "⚠️  Periodic Notes config not found: $PNOTES_SRC"
fi

# ── 4. Style Settings config ────────────────────────────────
SS_SRC="$META/02 - Plugin Configs/style-settings.json"
if [ -f "$SS_SRC" ]; then
  cp "$SS_SRC" "$OBSIDIAN_DIR/plugins/style-settings/data.json"
  echo "✅ Style Settings config installed (Indigo · Standard · Gradient Cyan/Purple)"
else
  echo "⚠️  Style Settings config not found: $SS_SRC"
fi

# ── 5. Enable CSS snippets in appearance.json ───────────────
APPEARANCE="$OBSIDIAN_DIR/appearance.json"
if [ -f "$APPEARANCE" ]; then
  echo "ℹ️  appearance.json exists — manually enable 'Colored Sidebar Items' in Obsidian settings."
else
  cat > "$APPEARANCE" << 'JSON'
{
  "cssTheme": "Vauxhall",
  "enabledCssSnippets": ["Colored Sidebar Items"],
  "fontFamily": "JetBrains Mono Nerd Font Mono",
  "monospaceFontFamily": "JetBrains Mono Nerd Font Mono"
}
JSON
  echo "✅ appearance.json written (Vauxhall theme · JetBrains Mono)"
fi

echo ""
echo "─────────────────────────────────────────────────────────"
echo "🟢 Setup complete. Next steps (manual in Obsidian):"
echo ""
echo "  1. Settings → Community Plugins → install:"
echo "     • Periodic Notes"
echo "     • Smart Connections (Phase 2)"
echo ""
echo "  2. Settings → Appearance → CSS Snippets:"
echo "     • Enable: Colored Sidebar Items"
echo ""
echo "  3. Settings → Style Settings → verify:"
echo "     • Base color: Indigo"
echo "     • Intensity: Standard"
echo "     • Headers: Gradient Cyan/Purple"
echo ""
echo "  4. Periodic Notes → point paths match:"
echo "     Daily   → 06 - Daily/Daily"
echo "     Weekly  → 06 - Daily/Weekly"
echo "     Monthly → 06 - Daily/Monthly"
echo "─────────────────────────────────────────────────────────"
