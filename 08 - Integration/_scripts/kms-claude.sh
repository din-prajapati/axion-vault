#!/usr/bin/env bash
# ============================================================
# kms-claude.sh — Axion → Claude CLI bridge
# Usage:
#   echo "your prompt" | ./kms-claude.sh
#   ./kms-claude.sh --file "path/to/note.md" --prompt "Summarise this"
#   ./kms-claude.sh --file "path/to/note.md"   # uses default prompt
# ============================================================

set -euo pipefail

# ── Config ──────────────────────────────────────────────────
MODEL="${CLAUDE_MODEL:-claude-sonnet-4-20250514}"
MAX_TOKENS="${CLAUDE_MAX_TOKENS:-2048}"
API_KEY="${ANTHROPIC_API_KEY:-}"

# ── Defaults ─────────────────────────────────────────────────
FILE=""
PROMPT=""
SYSTEM_PROMPT="You are a knowledgeable assistant integrated into a personal knowledge management vault (Axion). \
Vault notes use PARA-adjacent structure: Projects, Areas, Resources, Permanent notes. \
Frontmatter fields include: type, status, priority, area, deadline, tags. \
Be concise. Format responses in Markdown. Use the note context provided."

# ── Arg parsing ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)    FILE="$2";   shift 2 ;;
    --prompt)  PROMPT="$2"; shift 2 ;;
    --model)   MODEL="$2";  shift 2 ;;
    --system)  SYSTEM_PROMPT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# ── Validate ─────────────────────────────────────────────────
if [[ -z "$API_KEY" ]]; then
  echo "❌  ANTHROPIC_API_KEY is not set." >&2
  echo "    Add to ~/.zshrc: export ANTHROPIC_API_KEY=\"sk-ant-...\"" >&2
  exit 1
fi

# ── Build user message ───────────────────────────────────────
USER_MSG=""

if [[ -n "$FILE" ]]; then
  if [[ ! -f "$FILE" ]]; then
    echo "❌  File not found: $FILE" >&2; exit 1
  fi
  NOTE_CONTENT=$(cat "$FILE")
  USER_MSG="$(printf '## Vault Note\n\n```markdown\n%s\n```\n\n' "$NOTE_CONTENT")"
fi

# Prompt from arg, or from stdin, or default
if [[ -n "$PROMPT" ]]; then
  USER_MSG+="$PROMPT"
elif ! [ -t 0 ]; then
  STDIN=$(cat)
  USER_MSG+="$STDIN"
else
  USER_MSG+="Summarise this note concisely. Extract key ideas, action items, and any open questions."
fi

# ── Call Anthropic API ───────────────────────────────────────
RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d "$(jq -n \
    --arg model    "$MODEL" \
    --argjson max  "$MAX_TOKENS" \
    --arg system   "$SYSTEM_PROMPT" \
    --arg user_msg "$USER_MSG" \
    '{
      model:      $model,
      max_tokens: $max,
      system:     $system,
      messages:   [{ role: "user", content: $user_msg }]
    }'
  )")

# ── Extract & print ──────────────────────────────────────────
ERROR=$(echo "$RESPONSE" | jq -r '.error.message // empty')
if [[ -n "$ERROR" ]]; then
  echo "❌  API error: $ERROR" >&2; exit 1
fi

echo "$RESPONSE" | jq -r '.content[0].text'
