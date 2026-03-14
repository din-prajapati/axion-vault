#!/usr/bin/env bash
# ============================================================
# kms-ask.sh — Cloud KMS universal AI router
# Routes to Claude or Gemini based on --tool flag or env var.
#
# Usage:
#   ./kms-ask.sh --tool claude  --file "note.md" --prompt "..."
#   ./kms-ask.sh --tool gemini  --file "note.md"
#   echo "prompt" | ./kms-ask.sh          # uses KMS_DEFAULT_TOOL
#
# Set default tool:
#   export KMS_DEFAULT_TOOL=claude         # or gemini
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL="${KMS_DEFAULT_TOOL:-claude}"
PASSTHROUGH_ARGS=()

# ── Strip --tool flag, pass rest through ─────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool) TOOL="$2"; shift 2 ;;
    *)      PASSTHROUGH_ARGS+=("$1"); shift ;;
  esac
done

# ── Route ────────────────────────────────────────────────────
case "$TOOL" in
  claude)
    exec "$SCRIPT_DIR/kms-claude.sh" "${PASSTHROUGH_ARGS[@]+"${PASSTHROUGH_ARGS[@]}"}"
    ;;
  gemini)
    exec "$SCRIPT_DIR/kms-gemini.sh" "${PASSTHROUGH_ARGS[@]+"${PASSTHROUGH_ARGS[@]}"}"
    ;;
  *)
    echo "❌  Unknown tool: $TOOL  (use 'claude' or 'gemini')" >&2
    exit 1
    ;;
esac
