#!/usr/bin/env bash
# ============================================================
# kms-clip-process.sh — Axion Clipping Processor
#
# Transforms a raw _Clippings note into a typed Axion note:
#   1. Reads axion-clip-schema.json for type→template mapping
#   2. Sends raw content to Claude or Gemini for classification
#   3. Rewrites frontmatter + content body from schema
#   4. Sets status: "Ready for Review" → appears in review.base
#   5. Moves note to the correct vault folder
#
# Usage:
#   ./kms-clip-process.sh --file "path/to/clipping.md"
#   ./kms-clip-process.sh --all          # process all unprocessed clips
#   ./kms-clip-process.sh --all --dry-run # preview without writing
#
# Dependencies: bash, jq, curl
# Config:       axion-clip-schema.json (same directory as this script)
# ============================================================

set -euo pipefail

# ── Paths ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_FILE="$SCRIPT_DIR/axion-clip-schema.json"

# Resolve vault root: two levels up from 08 - Integration/_scripts/
VAULT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# ── Validate schema file exists ──────────────────────────────
if [[ ! -f "$SCHEMA_FILE" ]]; then
  echo "❌  Schema not found: $SCHEMA_FILE" >&2
  echo "    Expected: axion-clip-schema.json in the same folder as this script." >&2
  exit 1
fi

# ── Config from schema ───────────────────────────────────────
CLIPPINGS_INBOX=$(jq -r '.clippings_inbox' "$SCHEMA_FILE")
CLASSIFICATION_PROMPT=$(jq -r '.llm.classification_prompt' "$SCHEMA_FILE")
ALLOWED_TYPES=$(jq -r '.allowed_types[]' "$SCHEMA_FILE")

# ── Runtime flags ────────────────────────────────────────────
FILE=""
PROCESS_ALL=false
DRY_RUN=false
TOOL="${KMS_DEFAULT_TOOL:-claude}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)    FILE="$2";      shift 2 ;;
    --all)     PROCESS_ALL=true; shift ;;
    --dry-run) DRY_RUN=true;   shift ;;
    --tool)    TOOL="$2";      shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# ── Helpers ──────────────────────────────────────────────────

log()  { echo "  $*"; }
ok()   { echo "✅  $*"; }
warn() { echo "⚠️   $*" >&2; }
err()  { echo "❌  $*" >&2; exit 1; }

# Validate that a value is in the allowed_types list
validate_type() {
  local t="$1"
  if ! echo "$ALLOWED_TYPES" | grep -qx "$t"; then
    warn "LLM returned unknown type '$t' — falling back to fleeting"
    echo "fleeting"
  else
    echo "$t"
  fi
}

# Resolve folder for a type + resource_format
resolve_folder() {
  local type="$1" format="$2"
  local folder
  # Check for format-specific folder override first
  folder=$(jq -r \
    --arg t "$type" --arg f "$format" \
    '.type_schemas[$t].folder_by_format[$f] // .type_schemas[$t].folder_default' \
    "$SCHEMA_FILE")
  echo "$folder"
}

# Read a schema field for a type
schema_field() {
  local type="$1" field="$2"
  jq -r --arg t "$type" --arg f "$field" '.type_schemas[$t][$f]' "$SCHEMA_FILE"
}

# ── LLM Classification ───────────────────────────────────────
classify_with_claude() {
  local content="$1"
  local api_key="${ANTHROPIC_API_KEY:-}"
  local model="${CLAUDE_MODEL:-claude-haiku-4-20250514}"

  [[ -z "$api_key" ]] && err "ANTHROPIC_API_KEY is not set."

  local user_msg
  user_msg="$(printf '%s\n\n---\n\n## Raw Clipping Content\n\n%s' \
    "$CLASSIFICATION_PROMPT" "$content")"

  local response
  response=$(curl -s https://api.anthropic.com/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: $api_key" \
    -H "anthropic-version: 2023-06-01" \
    -d "$(jq -n \
      --arg model "$model" \
      --argjson max 1024 \
      --arg msg "$user_msg" \
      '{model: $model, max_tokens: $max, messages: [{role:"user", content: $msg}]}'
    )")

  local api_error
  api_error=$(echo "$response" | jq -r '.error.message // empty')
  [[ -n "$api_error" ]] && err "Claude API error: $api_error"

  echo "$response" | jq -r '.content[0].text'
}

classify_with_gemini() {
  local content="$1"
  local api_key="${GEMINI_API_KEY:-}"
  local model="${GEMINI_MODEL:-gemini-2.0-flash}"

  [[ -z "$api_key" ]] && err "GEMINI_API_KEY is not set."

  local full_prompt
  full_prompt="$(printf '%s\n\n---\n\n## Raw Clipping Content\n\n%s' \
    "$CLASSIFICATION_PROMPT" "$content")"

  local endpoint="https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${api_key}"

  local response
  response=$(curl -s "$endpoint" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg text "$full_prompt" \
      '{contents: [{parts: [{text: $text}]}]}'
    )")

  local api_error
  api_error=$(echo "$response" | jq -r '.error.message // empty')
  [[ -n "$api_error" ]] && err "Gemini API error: $api_error"

  echo "$response" | jq -r '.candidates[0].content.parts[0].text'
}

classify() {
  local content="$1"
  case "$TOOL" in
    claude) classify_with_claude "$content" ;;
    gemini) classify_with_gemini "$content" ;;
    *) err "Unknown tool: $TOOL (use claude or gemini)" ;;
  esac
}

# ── Frontmatter builder ──────────────────────────────────────
# Reads field definitions from schema, substitutes {{token}} placeholders,
# and emits a YAML frontmatter block.
build_frontmatter() {
  local type="$1"
  local title="$2" url="$3" date="$4"
  local llm_json="$5"   # full LLM classification JSON

  # Helper: resolve a field value — either static, a {{token}}, or {{llm:key}}
  resolve_field() {
    local raw="$1"
    case "$raw" in
      "{{title}}")          echo "$title" ;;
      "{{url}}")            echo "$url" ;;
      "{{date}}")           echo "$date" ;;
      "IDEA - {{title}}")   echo "IDEA - $title" ;;
      "{{llm:"*)
        local key="${raw//\{\{llm:/}"
        key="${key//\}\}/}"
        echo "$llm_json" | jq -r --arg k "$key" '.[$k] // ""'
        ;;
      *)                    echo "$raw" ;;
    esac
  }

  local fm="---"$'\n'

  # Iterate over frontmatter_fields keys in schema order
  while IFS= read -r field_key; do
    local raw_val
    raw_val=$(jq -r --arg t "$type" --arg k "$field_key" \
      '.type_schemas[$t].frontmatter_fields[$k]' "$SCHEMA_FILE")

    # Arrays (tags, cssclasses) — emit as YAML list
    if echo "$raw_val" | jq -e 'type == "array"' &>/dev/null 2>&1; then
      fm+="${field_key}:"$'\n'
      while IFS= read -r item; do
        fm+="  - ${item}"$'\n'
      done < <(echo "$raw_val" | jq -r '.[]')
    else
      local resolved
      resolved=$(resolve_field "$raw_val")
      # Quote string values that aren't booleans/numbers
      case "$field_key" in
        type|status) fm+="${field_key}: ${resolved}"$'\n' ;;
        *)
          if [[ -z "$resolved" ]]; then
            fm+="${field_key}: \"\""$'\n'
          else
            fm+="${field_key}: \"${resolved}\""$'\n'
          fi
          ;;
      esac
    fi
  done < <(jq -r --arg t "$type" '.type_schemas[$t].frontmatter_fields | keys_unsorted[]' "$SCHEMA_FILE")

  fm+="---"
  echo "$fm"
}

# ── Content body builder ─────────────────────────────────────
build_content_body() {
  local type="$1"
  local title="$2" url="$3"
  local llm_json="$4"
  local raw_content="$5"

  local body="# ${title}"$'\n\n'

  local section_count
  section_count=$(jq -r --arg t "$type" '.type_schemas[$t].content_sections | length' "$SCHEMA_FILE")

  for ((i=0; i<section_count; i++)); do
    local heading source style value
    heading=$(jq -r --arg t "$type" --argjson i "$i" \
      '.type_schemas[$t].content_sections[$i].heading' "$SCHEMA_FILE")
    source=$(jq -r --arg t "$type" --argjson i "$i" \
      '.type_schemas[$t].content_sections[$i].source' "$SCHEMA_FILE")
    style=$(jq -r --arg t "$type" --argjson i "$i" \
      '.type_schemas[$t].content_sections[$i].style // ""' "$SCHEMA_FILE")
    value=$(jq -r --arg t "$type" --argjson i "$i" \
      '.type_schemas[$t].content_sections[$i].value // ""' "$SCHEMA_FILE")

    body+="## ${heading}"$'\n'

    case "$source" in
      llm:*)
        local llm_key="${source#llm:}"
        local llm_val
        llm_val=$(echo "$llm_json" | jq -r --arg k "$llm_key" '.[$k] // ""')
        if [[ "$style" == "blockquote" ]]; then
          body+="> ${llm_val}"$'\n'
        else
          body+="${llm_val}"$'\n'
        fi
        ;;

      raw)
        body+="${raw_content}"$'\n'
        ;;

      static)
        # Substitute {{title}} and {{url}} in static values
        local resolved_val="${value//\{\{title\}\}/$title}"
        resolved_val="${resolved_val//\{\{url\}\}/$url}"
        body+="${resolved_val}"$'\n'
        ;;

      dataview)
        body+="\`\`\`dataview"$'\n'
        body+="${value}"$'\n'
        body+="\`\`\`"$'\n'
        ;;
    esac

    body+=$'\n'
  done

  echo "$body"
}

# ── Process a single file ────────────────────────────────────
process_file() {
  local input_file="$1"

  [[ ! -f "$input_file" ]] && err "File not found: $input_file"

  log "Processing: $(basename "$input_file")"

  # ── Extract fields from raw clipping frontmatter ──────────
  local raw_title raw_url raw_captured raw_status raw_type
  raw_title=$(grep -m1 '^title:' "$input_file" | sed 's/^title: *//;s/^"//;s/"$//' || true)
  raw_url=$(grep -m1 '^source:' "$input_file" | sed 's/^source: *//;s/^"//;s/"$//' || true)
  raw_captured=$(grep -m1 '^captured:' "$input_file" | sed 's/^captured: *//;s/^"//;s/"$//' || true)
  raw_status=$(grep -m1 '^status:' "$input_file" | sed 's/^status: *//;s/^"//;s/"$//' || true)
  raw_type=$(grep -m1 '^type:' "$input_file" | sed 's/^type: *//;s/^"//;s/"$//' || true)

  # Skip if already processed (not a raw clipping)
  if [[ "$raw_type" != "clipping" ]]; then
    warn "Skipping '$(basename "$input_file")' — type is '$raw_type', not 'clipping'"
    return 0
  fi

  # Skip if already in review or beyond
  if [[ "$raw_status" == "Ready for Review" || "$raw_status" == "Reference" ]]; then
    warn "Skipping '$(basename "$input_file")' — already processed (status: $raw_status)"
    return 0
  fi

  local today
  today=$(date +%Y-%m-%d)
  local date="${raw_captured:-$today}"
  local title="${raw_title:-$(basename "$input_file" .md)}"

  # ── Extract raw body content (everything after second ---) ─
  local raw_content
  raw_content=$(awk 'BEGIN{fm=0} /^---/{fm++; next} fm>=2{print}' "$input_file")

  # ── Classify via LLM ──────────────────────────────────────
  log "Classifying via $TOOL..."
  local llm_raw_response
  llm_raw_response=$(classify "$raw_content")

  # Strip markdown fences if model wrapped the JSON anyway
  local llm_json
  llm_json=$(echo "$llm_raw_response" | sed '/^```/d')

  # Validate JSON
  if ! echo "$llm_json" | jq -e . &>/dev/null; then
    warn "LLM returned invalid JSON for '$(basename "$input_file")' — falling back to fleeting"
    llm_json='{"type":"fleeting","resource_format":"","resource_topic":"","scope":"","author":"","genre":"","area":"","key_takeaways":"","summary":"","central_thesis":"","key_ideas":"","angle_hook":""}'
  fi

  # ── Resolve type + folder ─────────────────────────────────
  local raw_type_llm format
  raw_type_llm=$(echo "$llm_json" | jq -r '.type // "fleeting"')
  local final_type
  final_type=$(validate_type "$raw_type_llm")

  format=$(echo "$llm_json" | jq -r '.resource_format // ""')
  local destination_folder
  destination_folder=$(resolve_folder "$final_type" "$format")

  log "  type:   $final_type"
  log "  format: ${format:-(none)}"
  log "  folder: $destination_folder"

  # ── Build output note ─────────────────────────────────────
  local frontmatter
  frontmatter=$(build_frontmatter "$final_type" "$title" "$raw_url" "$date" "$llm_json")

  local content_body
  content_body=$(build_content_body "$final_type" "$title" "$raw_url" "$llm_json" "$raw_content")

  local output_note="${frontmatter}"$'\n\n'"${content_body}"

  # ── Destination path ──────────────────────────────────────
  local dest_dir="$VAULT_ROOT/$destination_folder"
  local filename
  filename=$(basename "$input_file")
  # Prefix content ideas with "IDEA - " if not already
  if [[ "$final_type" == "content" && "$filename" != IDEA\ * ]]; then
    filename="IDEA - $filename"
  fi
  local dest_file="$dest_dir/$filename"

  if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo "── DRY RUN: $(basename "$input_file") ──────────────────────"
    echo "  destination: $dest_file"
    echo "── Frontmatter preview ──"
    echo "$frontmatter" | head -20
    echo ""
    return 0
  fi

  # ── Write + move ──────────────────────────────────────────
  mkdir -p "$dest_dir"
  echo "$output_note" > "$dest_file"

  # Remove the original clipping only after successful write
  if [[ "$dest_file" != "$input_file" ]]; then
    rm "$input_file"
  fi

  ok "$(basename "$filename")  →  $destination_folder"
}

# ── Main ─────────────────────────────────────────────────────
if [[ "$PROCESS_ALL" == true ]]; then
  INBOX_PATH="$VAULT_ROOT/$CLIPPINGS_INBOX"
  [[ ! -d "$INBOX_PATH" ]] && err "Clippings inbox not found: $INBOX_PATH"

  files=("$INBOX_PATH"/*.md)
  if [[ ${#files[@]} -eq 0 || ! -f "${files[0]}" ]]; then
    echo "No .md files found in $CLIPPINGS_INBOX"
    exit 0
  fi

  echo "Processing ${#files[@]} clipping(s) from $CLIPPINGS_INBOX..."
  echo ""
  for f in "${files[@]}"; do
    process_file "$f"
  done
  echo ""
  echo "Done. Open review.base in Obsidian to approve processed notes."

elif [[ -n "$FILE" ]]; then
  process_file "$FILE"
  echo "Done. Open review.base in Obsidian to approve."

else
  echo "Usage:"
  echo "  $0 --file <path/to/clipping.md>"
  echo "  $0 --all"
  echo "  $0 --all --dry-run"
  echo ""
  echo "Options:"
  echo "  --tool claude|gemini   Override LLM (default: \$KMS_DEFAULT_TOOL or claude)"
  echo "  --dry-run              Preview output without writing or moving files"
  exit 1
fi
