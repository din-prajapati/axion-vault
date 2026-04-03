#!/usr/bin/env bash
# ============================================================
# kms-gemini.sh — Axion → Gemini CLI bridge
# Usage:
#   echo "your prompt" | ./kms-gemini.sh
#   ./kms-gemini.sh --file "path/to/note.md" --prompt "Analyse this"
#   ./kms-gemini.sh --file "path/to/note.md"   # uses default prompt
# ============================================================

set -euo pipefail

# ── Config ──────────────────────────────────────────────────
MODEL="${GEMINI_MODEL:-gemini-2.0-flash}"
API_KEY="${GEMINI_API_KEY:-}"

# ── Defaults ─────────────────────────────────────────────────
FILE=""
PROMPT=""
SYSTEM_PROMPT="You are a knowledgeable assistant integrated into a personal knowledge management vault (Axion). \
Vault notes use PARA-adjacent structure: Projects, Areas, Resources, Permanent notes. \
Frontmatter fields include: type, status, priority, area, deadline, tags. \
Be concise. Format responses in Markdown."

# ── Arg parsing ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)   FILE="$2";   shift 2 ;;
    --prompt) PROMPT="$2"; shift 2 ;;
    --model)  MODEL="$2";  shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# ── Validate ─────────────────────────────────────────────────
if [[ -z "$API_KEY" ]]; then
  echo "❌  GEMINI_API_KEY is not set." >&2
  echo "    Add to ~/.zshrc: export GEMINI_API_KEY=\"AIza...\"" >&2
  exit 1
fi

# ── Build prompt ─────────────────────────────────────────────
FULL_PROMPT="$SYSTEM_PROMPT\n\n"

if [[ -n "$FILE" ]]; then
  [[ ! -f "$FILE" ]] && { echo "❌  File not found: $FILE" >&2; exit 1; }
  FULL_PROMPT+="$(printf '## Vault Note\n\n```markdown\n%s\n```\n\n' "$(cat "$FILE")")"
fi

if [[ -n "$PROMPT" ]]; then
  FULL_PROMPT+="$PROMPT"
elif ! [ -t 0 ]; then
  FULL_PROMPT+=$(cat)
else
  FULL_PROMPT+="Summarise this note concisely. Extract key ideas, action items, and any open questions."
fi

# ── Call Gemini API ──────────────────────────────────────────
ENDPOINT="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_KEY}"

RESPONSE=$(curl -s "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg text "$FULL_PROMPT" \
    '{ contents: [{ parts: [{ text: $text }] }] }'
  )")

# ── Extract & print ──────────────────────────────────────────
ERROR=$(echo "$RESPONSE" | jq -r '.error.message // empty')
if [[ -n "$ERROR" ]]; then
  echo "❌  API error: $ERROR" >&2; exit 1
fi

echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text'
